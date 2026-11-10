import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const UBERLLM_DEFAULT_BASE_URL = "https://api.uberllm.dev/v1";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-uberllm"
        title="Select UberLLM"
        onPress={() => setType("UberLLM")}
      />
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

describe("UberLLM provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("UberLLM");
  });

  it("should expose the UberLLM default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-uberllm"));

    expect(await screen.findByTestId("type")).toHaveTextContent("UberLLM");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(UBERLLM_DEFAULT_BASE_URL);
  });
});
