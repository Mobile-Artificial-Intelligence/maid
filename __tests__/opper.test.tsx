import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const OPPER_DEFAULT_BASE_URL = "https://api.opper.ai/v3/compat";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-opper"
        title="Select Opper"
        onPress={() => setType("Opper")}
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

describe("Opper provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("Opper");
  });

  it("should expose the Opper default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-opper"));

    expect(await screen.findByTestId("type")).toHaveTextContent("Opper");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(OPPER_DEFAULT_BASE_URL);
  });
});
