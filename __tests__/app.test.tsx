import { screen } from "expo-router/testing-library";

import renderApp from "../__test_utilities__/render-app";

describe("Chat page", () => {
  beforeEach(() => renderApp());

  it("should render the chat page", async () => {
    const chatPage = await screen.findByTestId("chat-page");
    expect(chatPage).toBeOnTheScreen();
    expect(chatPage.type).toBe("View");
  });

  it("should render the prompt input", async () => {
    const input = await screen.findByTestId("prompt-input");
    expect(input).toBeOnTheScreen();
    expect(input.type).toBe("TextInput");
  });

  it("should render the send button", async () => {
    const sendButton = await screen.findByTestId("send-button");
    expect(sendButton).toBeOnTheScreen();
    expect(sendButton.type).toBe("View");
  });

  it("should render the open drawer button", async () => {
    const openDrawerButton = await screen.findByTestId("open-drawer-button");
    expect(openDrawerButton).toBeOnTheScreen();
    expect(openDrawerButton.type).toBe("View");
  });

  it("should render the menu button", async () => {
    const menuButton = await screen.findByTestId("menu-button");
    expect(menuButton).toBeOnTheScreen();
    expect(menuButton.type).toBe("View");
  });
});
