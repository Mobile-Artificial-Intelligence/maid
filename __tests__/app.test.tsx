import { screen } from "expo-router/testing-library";

import renderApp from "../__test_utilities__/render-app";

describe("Maid Routes", () => {
  beforeEach(() => renderApp());

  it("loads chat and shows the prompt input", async () => {
    const input = await screen.findByTestId("prompt-input");
    expect(input).toBeOnTheScreen();
    expect(input.type).toBe("TextInput");
  });
});
