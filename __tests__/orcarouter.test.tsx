import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const ORCAROUTER_DEFAULT_BASE_URL = "https://api.orcarouter.ai/v1";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-orcarouter"
        title="Select OrcaRouter"
        onPress={() => setType("OrcaRouter")}
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

describe("OrcaRouter provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("OrcaRouter");
  });

  it("should expose the OrcaRouter default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-orcarouter"));

    expect(await screen.findByTestId("type")).toHaveTextContent("OrcaRouter");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(ORCAROUTER_DEFAULT_BASE_URL);
  });
});
