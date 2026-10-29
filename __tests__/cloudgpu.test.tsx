import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const CLOUDGPU_DEFAULT_BASE_URL = "https://cloudgpu.app/v1";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-cloudgpu"
        title="Select CloudGPU"
        onPress={() => setType("CloudGPU")}
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

describe("CloudGPU provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("CloudGPU");
  });

  it("should expose the CloudGPU default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-cloudgpu"));

    expect(await screen.findByTestId("type")).toHaveTextContent("CloudGPU");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(CLOUDGPU_DEFAULT_BASE_URL);
  });
});
