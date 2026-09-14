import { render, fireEvent, screen } from "@testing-library/react-native";
import { Button, Text } from "react-native";
import { LanguageModelProvider, useLLM, LanguageModelTypes } from "@/context/language-model";

const DAOXE_DEFAULT_BASE_URL = "https://api.daoxe.com/v1";

function Probe() {
  const { type, setType, baseURL } = useLLM();

  return (
    <>
      <Text testID="type">{type}</Text>
      <Text testID="baseURL">{baseURL ?? "undefined"}</Text>
      <Button
        testID="select-daoxe"
        title="Select DaoXE"
        onPress={() => setType("DaoXE")}
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

describe("DaoXE provider", () => {
  it("should be a registered language model type", () => {
    expect(LanguageModelTypes).toContain("DaoXE");
  });

  it("should expose the DaoXE default base URL when selected", async () => {
    renderProbe();

    fireEvent.press(screen.getByTestId("select-daoxe"));

    expect(await screen.findByTestId("type")).toHaveTextContent("DaoXE");
    expect(screen.getByTestId("baseURL")).toHaveTextContent(DAOXE_DEFAULT_BASE_URL);
  });
});
