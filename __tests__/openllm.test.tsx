import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const OPENLLM_DEFAULT_BASE_URL = "https://www.openllm.sh/v1";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-openllm"
        title="Select OpenLLM"
        onPress={() => setType("OpenLLM")}
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

describe("OpenLLM provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("OpenLLM");
  });

  it("should expose the OpenLLM default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-openllm"));

    expect(await screen.findByTestId("type")).toHaveTextContent("OpenLLM");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(OPENLLM_DEFAULT_BASE_URL);
  });
});
