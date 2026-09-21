import { render, fireEvent, screen, waitFor } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";
import { discoverLiteLLMModels, proxyRoot, toChatMessages } from "@/context/language-model/litellm";

const LITELLM_DEFAULT_BASE_URL = "http://localhost:4000/v1";

const mockFetch = jest.fn();

jest.mock("expo/fetch", () => ({
  fetch: (...args: unknown[]) => mockFetch(...args),
}));

function jsonResponse(body: unknown, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    json: async () => body,
  } as unknown as Response;
}

const MODEL_INFO = {
  data: [
    { model_name: "claude-sonnet", model_info: { mode: "chat", supports_vision: true } },
    { model_name: "claude-sonnet", model_info: { mode: "chat", supports_vision: true } },
    { model_name: "deepseek-chat", model_info: { mode: "chat", supports_vision: false } },
    { model_name: "text-embedding-3-small", model_info: { mode: "embedding" } },
    { model_name: "gemini-2.5-flash-image", model_info: { mode: "image_generation" } },
  ],
};

function Probe() {
  const { type, setType, baseURL, models, setModel, imagesSupported } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Text testID="models">{(models ?? []).join(",")}</Text>
      <Text testID="images">{String(imagesSupported)}</Text>
      <Button
        testID="select-litellm"
        title="Select LiteLLM"
        onPress={() => setType("LiteLLM")}
      />
      <Button testID="pick-claude" title="Claude" onPress={() => setModel?.("claude-sonnet")} />
      <Button testID="pick-deepseek" title="DeepSeek" onPress={() => setModel?.("deepseek-chat")} />
    </>
  );
}

function renderProbe() {
  return render(
    <LanguageModelProvider>
      <Probe />
    </LanguageModelProvider>
  );
}

beforeEach(() => {
  mockFetch.mockReset();
  mockFetch.mockImplementation(async (url: string) =>
    String(url).endsWith("/model/info") ? jsonResponse(MODEL_INFO) : jsonResponse({ data: [] })
  );
});

describe("LiteLLM provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("LiteLLM");
  });

  it("should expose the LiteLLM default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-litellm"));

    expect(await screen.findByTestId("type")).toHaveTextContent("LiteLLM");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(LITELLM_DEFAULT_BASE_URL);
  });

  it("should list only chat models and enable images per model", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-litellm"));

    await waitFor(() =>
      expect(screen.getByTestId("models")).toHaveTextContent("claude-sonnet,deepseek-chat")
    );
    expect(mockFetch).toHaveBeenCalledWith("http://localhost:4000/model/info", expect.anything());

    fireEvent.press(screen.getByTestId("pick-claude"));
    await waitFor(() => expect(screen.getByTestId("images")).toHaveTextContent("true"));

    fireEvent.press(screen.getByTestId("pick-deepseek"));
    await waitFor(() => expect(screen.getByTestId("images")).toHaveTextContent("false"));
  });
});

describe("discoverLiteLLMModels", () => {
  it("sends the virtual key only when one is set", async () => {
    const fetchImpl = jest.fn(async () => jsonResponse(MODEL_INFO));

    await discoverLiteLLMModels("http://proxy:4000/v1/", "sk-virtual", { "X-Team": "a" }, fetchImpl as any);
    await discoverLiteLLMModels("http://proxy:4000", undefined, {}, fetchImpl as any);

    const calls = fetchImpl.mock.calls as unknown as Array<[string, { headers: Record<string, string> }]>;
    expect(calls[0][0]).toBe("http://proxy:4000/model/info");
    expect(calls[0][1].headers).toEqual({ "X-Team": "a", Authorization: "Bearer sk-virtual" });
    expect(calls[1][1].headers).toEqual({});
  });

  it("falls back to /v1/models when /model/info is not allowed", async () => {
    const fetchImpl = jest
      .fn()
      .mockResolvedValueOnce(jsonResponse({ error: "forbidden" }, 403))
      .mockResolvedValueOnce(jsonResponse({ data: [{ id: "gpt-4.1-mini" }, { id: "" }] }));

    const info = await discoverLiteLLMModels("http://proxy:4000", "sk-scoped", {}, fetchImpl);

    expect(info).toEqual({ models: ["gpt-4.1-mini"], vision: {} });
    expect(fetchImpl.mock.calls[1][0]).toBe("http://proxy:4000/v1/models");
  });

  it("reports an unreachable or unauthorised proxy", async () => {
    const fetchImpl = jest
      .fn()
      .mockRejectedValueOnce(new Error("Network request failed"))
      .mockResolvedValueOnce(jsonResponse({ error: "bad key" }, 401));

    await expect(discoverLiteLLMModels("http://proxy:4000", "sk-bad", {}, fetchImpl)).rejects.toThrow("401");
  });
});

describe("LiteLLM message helpers", () => {
  it("roots admin routes at the proxy, with or without /v1", () => {
    expect(proxyRoot("http://proxy:4000/v1/")).toBe("http://proxy:4000");
    expect(proxyRoot(" https://gw.example.com ")).toBe("https://gw.example.com");
  });

  it("sends attached images as image_url parts only when the model accepts them", () => {
    const messages = [
      { role: "system", content: "Be brief." },
      { role: "user", content: "What is this?", metadata: { images: ["data:image/png;base64,AAAA"] } },
    ] as any;

    expect(toChatMessages(messages, true)[1]).toEqual({
      role: "user",
      content: [
        { type: "text", text: "What is this?" },
        { type: "image_url", image_url: { url: "data:image/png;base64,AAAA" } },
      ],
    });
    expect(toChatMessages(messages, false)[1]).toEqual({ role: "user", content: "What is this?" });
    expect(toChatMessages(messages, true)[0]).toEqual({ role: "system", content: "Be brief." });
  });
});
