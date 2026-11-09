import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const STANDARD_COMPUTE_DEFAULT_BASE_URL = "https://api.stdcmpt.com/v1";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-standard-compute"
        title="Select Standard Compute"
        onPress={() => setType("Standard Compute")}
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

describe("Standard Compute provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("Standard Compute");
  });

  it("should expose the Standard Compute default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-standard-compute"));

    expect(await screen.findByTestId("type")).toHaveTextContent("Standard Compute");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(STANDARD_COMPUTE_DEFAULT_BASE_URL);
  });
});
