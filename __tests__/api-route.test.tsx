import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const APIRoute_DEFAULT_BASE_URL = "https://global.api-route.com/v1";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-api-route"
        title="Select API Route"
        onPress={() => setType("API Route")}
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

describe("API Route provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("API Route");
  });

  it("should expose the API Route default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-api-route"));

    expect(await screen.findByTestId("type")).toHaveTextContent("API Route");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(APIRoute_DEFAULT_BASE_URL);
  });
});
