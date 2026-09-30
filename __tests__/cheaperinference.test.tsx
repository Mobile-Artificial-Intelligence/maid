import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const CHEAPER_INFERENCE_DEFAULT_BASE_URL = "https://api.cheaperinference.com/v1";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-cheaperinference"
        title="Select Cheaper Inference"
        onPress={() => setType("Cheaper Inference")}
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

describe("Cheaper Inference provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("Cheaper Inference");
  });

  it("should expose the Cheaper Inference default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-cheaperinference"));

    expect(await screen.findByTestId("type")).toHaveTextContent("Cheaper Inference");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(CHEAPER_INFERENCE_DEFAULT_BASE_URL);
  });
});
