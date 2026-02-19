import { screen } from "expo-router/testing-library";

import renderApp from "../__test_utilities__/render-app";

describe("Maid Routes", () => {
  beforeEach(() => renderApp());

  it("Load Home Screen", async () => {
    const input = await screen.findByTestId("prompt-input");
    expect(input).toBeOnTheScreen();
    expect(input.type).toBe("TextInput");

    const sendButton = await screen.findByTestId("send-button");
    expect(sendButton).toBeOnTheScreen();
    expect(sendButton.type).toBe("View");

    const openDrawerButton = await screen.findByTestId("open-drawer-button");
    expect(openDrawerButton).toBeOnTheScreen();
    expect(openDrawerButton.type).toBe("View");

    const menuButton = await screen.findByTestId("menu-button");
    expect(menuButton).toBeOnTheScreen();
    expect(menuButton.type).toBe("View");
  });
});
