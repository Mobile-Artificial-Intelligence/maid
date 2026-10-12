import AsyncStorage from "@react-native-async-storage/async-storage";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM } from "@/context/language-model";

const mockFetch = jest.fn();

jest.mock("expo/fetch", () => ({
  fetch: (...args: unknown[]) => mockFetch(...args),
}));

function Probe() {
  const LLM = useLLM();

  return (
    <>
      <Text testID="type">{LLM.type}</Text>
      <Text testID="apiKey">{LLM.apiKey ?? "undefined"}</Text>
      <Text testID="model">{LLM.model ?? "undefined"}</Text>
      <Text testID="models">{(LLM.models ?? []).join(",")}</Text>
      <Text testID="headers">{JSON.stringify(LLM.headers ?? null)}</Text>
      <Text testID="fields">
        {[
          LLM.setBaseURL && "baseURL",
          LLM.setApiKey && "apiKey",
          LLM.setModel && "model",
          LLM.setHeaders && "headers",
          LLM.pickModelFile && "modelFile",
        ].filter(Boolean).join(",")}
      </Text>
      <Button testID="select-llama" title="Llama" onPress={() => LLM.setType("Llama")} />
      <Button testID="select-ollama" title="Ollama" onPress={() => LLM.setType("Ollama")} />
      <Button testID="select-open-ai" title="Open AI" onPress={() => LLM.setType("Open AI")} />
      <Button testID="select-anthropic" title="Anthropic" onPress={() => LLM.setType("Anthropic")} />
      <Button testID="select-mistral" title="Mistral" onPress={() => LLM.setType("Mistral")} />
      <Button testID="select-deepseek" title="DeepSeek" onPress={() => LLM.setType("DeepSeek")} />
      <Button testID="select-orcarouter" title="OrcaRouter" onPress={() => LLM.setType("OrcaRouter")} />
      <Button testID="set-api-key" title="Set key" onPress={() => LLM.setApiKey?.("sk-openai")} />
    </>
  );
}

// Settings load from storage asynchronously; let them land inside act().
async function renderProbe() {
  render(
    <LanguageModelProvider>
      <Probe />
    </LanguageModelProvider>
  );
  await act(async () => {});
}

async function press(testID: string) {
  await act(async () => {
    fireEvent.press(screen.getByTestId(testID));
  });
}

function modelsResponse(ids: Array<string>) {
  return new Response(JSON.stringify({ object: "list", data: ids.map((id) => ({ id, object: "model" })) }), {
    status: 200,
    headers: { "content-type": "application/json" },
  });
}

beforeEach(async () => {
  await AsyncStorage.clear();
  mockFetch.mockReset();
  mockFetch.mockImplementation(async () => modelsResponse([]));
});

describe("LanguageModelProvider", () => {
  it("exposes only the settings the selected provider uses", async () => {
    await renderProbe();

    const expected: Array<[string, string]> = [
      ["select-llama", "modelFile"],
      ["select-ollama", "baseURL,model,headers"],
      ["select-open-ai", "baseURL,apiKey,model,headers"],
      ["select-mistral", "baseURL,apiKey,model"],
      ["select-deepseek", "apiKey,model,headers"],
    ];

    for (const [button, fields] of expected) {
      await press(button);
      expect(screen.getByTestId("fields")).toHaveTextContent(fields);
    }
  });

  it("saves settings under each provider's storage keys and restores them when reselected", async () => {
    await renderProbe();

    await press("select-open-ai");
    await press("set-api-key");
    expect(screen.getByTestId("apiKey")).toHaveTextContent("sk-openai");
    await waitFor(async () => expect(await AsyncStorage.getItem("open-ai-api-key")).toBe("sk-openai"));

    await press("select-anthropic");
    expect(screen.getByTestId("apiKey")).toHaveTextContent("undefined");
    expect(await AsyncStorage.getItem("anthropic-api-key")).toBeNull();

    await press("select-open-ai");
    await waitFor(() => expect(screen.getByTestId("apiKey")).toHaveTextContent("sk-openai"));
  });

  it("loads settings saved by earlier versions", async () => {
    await AsyncStorage.multiSet([
      ["orcarouter-model", "gpt-4.1-mini"],
      ["orcarouter-headers", JSON.stringify({ "X-Team": "a" })],
    ]);

    await renderProbe();
    await press("select-orcarouter");

    await waitFor(() => expect(screen.getByTestId("model")).toHaveTextContent("gpt-4.1-mini"));
    expect(screen.getByTestId("headers")).toHaveTextContent(JSON.stringify({ "X-Team": "a" }));
  });

  it("connects only the selected provider", async () => {
    await AsyncStorage.multiSet([
      ["language-model-type", "Open AI"],
      ["open-ai-api-key", "sk-openai"],
      ["deepseek-api-key", "sk-deepseek"],
    ]);
    mockFetch.mockImplementation(async (url: string) =>
      modelsResponse(String(url).includes("deepseek") ? ["deepseek-chat"] : ["gpt-4.1"])
    );

    await renderProbe();

    await waitFor(() => expect(screen.getByTestId("models")).toHaveTextContent("gpt-4.1"));
    const requested = () => mockFetch.mock.calls.map(([url]) => String(url));
    expect(requested()).toEqual(["https://api.openai.com/v1/models"]);

    await press("select-deepseek");

    await waitFor(() => expect(screen.getByTestId("models")).toHaveTextContent("deepseek-chat"));
    expect(requested()).toEqual(["https://api.openai.com/v1/models", "https://api.deepseek.com/models"]);
  });
});
