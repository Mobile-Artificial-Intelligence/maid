import { fireEvent, renderRouter, screen } from "expo-router/testing-library";
import routes from "../__test-utilities__/routes";

describe("Chat page", () => {
  beforeEach(() => renderRouter(routes, { initialUrl: "/chat" }));

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

  it("should open the drawer when the open drawer button is pressed", async () => {
    const openDrawerButton = await screen.findByTestId("open-drawer-button");
    fireEvent.press(openDrawerButton);
    
    const drawer = await screen.findByTestId("drawer-content");
    expect(drawer).toBeOnTheScreen();
  });

  it("should open the menu popover when the menu button is pressed", async () => {
    const menuButton = await screen.findByTestId("menu-button");
    fireEvent.press(menuButton);
    
    const menuPopover = await screen.findByTestId("menu-popover");
    expect(menuPopover).toBeOnTheScreen();
  });
});
