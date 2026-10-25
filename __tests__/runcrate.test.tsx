import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const RUNCRATE_DEFAULT_BASE_URL = "https://api.runcrate.ai/v1";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-runcrate"
        title="Select Runcrate"
        onPress={() => setType("Runcrate")}
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

describe("Runcrate provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("Runcrate");
  });

  it("should expose the Runcrate default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-runcrate"));

    expect(await screen.findByTestId("type")).toHaveTextContent("Runcrate");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(RUNCRATE_DEFAULT_BASE_URL);
  });
});
