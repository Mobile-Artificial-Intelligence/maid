import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";
import { LLMMAN_DEFAULT_BASE_URL } from "@/context/language-model/llmman";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-llmman"
        title="Select llmman"
        onPress={() => setType("llmman")}
      />
    </>
  );
}

describe("llmman provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("llmman");
  });

  it("should expose the llmman default base URL when selected", async () => {
    render(
      <LanguageModelProvider>
        <Probe />
      </LanguageModelProvider>
    );

    fireEvent.press(screen.getByTestId("select-llmman"));

    expect(await screen.findByTestId("type")).toHaveTextContent("llmman");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(LLMMAN_DEFAULT_BASE_URL);
  });
});
