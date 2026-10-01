import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const ATLASCLOUD_DEFAULT_BASE_URL = "https://api.atlascloud.ai/v1";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-atlascloud"
        title="Select AtlasCloud"
        onPress={() => setType("AtlasCloud")}
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

describe("AtlasCloud provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("AtlasCloud");
  });

  it("should expose the AtlasCloud default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-atlascloud"));

    expect(await screen.findByTestId("type")).toHaveTextContent("AtlasCloud");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(ATLASCLOUD_DEFAULT_BASE_URL);
  });
});
