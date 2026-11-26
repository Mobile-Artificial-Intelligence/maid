import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const MARTLLM_DEFAULT_BASE_URL = "https://api.martllm.com/v1";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-martllm"
        title="Select MartLLM"
        onPress={() => setType("MartLLM")}
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

describe("MartLLM provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("MartLLM");
  });

  it("should expose the MartLLM default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-martllm"));

    expect(await screen.findByTestId("type")).toHaveTextContent("MartLLM");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(MARTLLM_DEFAULT_BASE_URL);
  });
});
