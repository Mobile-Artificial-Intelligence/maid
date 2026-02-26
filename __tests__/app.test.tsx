import { fireEvent, renderRouter, screen } from "expo-router/testing-library";
import routes from "./utilities/routes";

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

  it("should navigate to the model download page when the download model button is pressed", async () => {
    const modelButton = await screen.findByTestId("model-button");
    fireEvent.press(modelButton);

    const modelPopover = await screen.findByTestId("model-popover");
    expect(modelPopover).toBeOnTheScreen();

    const loadModelButton = await screen.findByTestId("load-model-button");
    expect(loadModelButton).toBeOnTheScreen();
    
    const downloadModelButton = await screen.findByTestId("download-model-button");
    fireEvent.press(downloadModelButton);
    
    const downloadPage = await screen.findByTestId("download-page");
    expect(downloadPage).toBeOnTheScreen();

    const backButton = await screen.findByTestId("back-button");
    fireEvent.press(backButton);

    expect(downloadPage).not.toBeOnTheScreen();

    const chatPage = await screen.findByTestId("chat-page");
    expect(chatPage).toBeOnTheScreen();
  });

  it("should navigate to login when the login button is pressed", async () => {
    const openDrawerButton = await screen.findByTestId("open-drawer-button");
    fireEvent.press(openDrawerButton);
    
    const drawer = await screen.findByTestId("drawer-content");
    expect(drawer).toBeOnTheScreen();
    
    const loginButton = await screen.findByTestId("login-button");
    fireEvent.press(loginButton);
    
    const loginPage = await screen.findByTestId("login-page");
    expect(loginPage).toBeOnTheScreen();

    const backButton = await screen.findByTestId("back-button");
    fireEvent.press(backButton);

    expect(loginPage).not.toBeOnTheScreen();

    const chatPage = await screen.findByTestId("chat-page");
    expect(chatPage).toBeOnTheScreen();
  });

  it("should navigate to register when the register button is pressed", async () => {
    const openDrawerButton = await screen.findByTestId("open-drawer-button");
    fireEvent.press(openDrawerButton);
    
    const drawer = await screen.findByTestId("drawer-content");
    expect(drawer).toBeOnTheScreen();
    
    const registerButton = await screen.findByTestId("register-button");
    fireEvent.press(registerButton);
    
    const registerPage = await screen.findByTestId("register-page");
    expect(registerPage).toBeOnTheScreen();

    const backButton = await screen.findByTestId("back-button");
    fireEvent.press(backButton);

    expect(registerPage).not.toBeOnTheScreen();

    const chatPage = await screen.findByTestId("chat-page");
    expect(chatPage).toBeOnTheScreen();
  });

  it("should show the clear prompt button when text is entered", async () => {
    const input = await screen.findByTestId("prompt-input");
    fireEvent.changeText(input, "Hello");

    const clearButton = await screen.findByTestId("clear-prompt-button");
    expect(clearButton).toBeOnTheScreen();
  });

  it("should clear the prompt input when the clear prompt button is pressed", async () => {
    const input = await screen.findByTestId("prompt-input");
    fireEvent.changeText(input, "Hello");

    const clearButton = await screen.findByTestId("clear-prompt-button");
    fireEvent.press(clearButton);

    expect(clearButton).not.toBeOnTheScreen();
  });

  it("should create a new chat when the new chat button is pressed", async () => {
    const openDrawerButton = await screen.findByTestId("open-drawer-button");
    fireEvent.press(openDrawerButton);

    const newChatButton = await screen.findByTestId("new-chat-button");
    fireEvent.press(newChatButton);

    const chatButton = await screen.findByTestId("chat-button-0");
    expect(chatButton).toBeOnTheScreen();
  });

  it("should clear all chats when the clear chats button is pressed", async () => {
    const openDrawerButton = await screen.findByTestId("open-drawer-button");
    fireEvent.press(openDrawerButton);

    const newChatButton = await screen.findByTestId("new-chat-button");
    fireEvent.press(newChatButton);

    const chatButton = await screen.findByTestId("chat-button-0");
    expect(chatButton).toBeOnTheScreen();

    const clearChatsButton = await screen.findByTestId("clear-chats-button");
    fireEvent.press(clearChatsButton);

    expect(chatButton).not.toBeOnTheScreen();
  });

  it("should open the menu popover when the menu button is pressed", async () => {
    const menuButton = await screen.findByTestId("menu-button");
    fireEvent.press(menuButton);
    
    const menuPopover = await screen.findByTestId("menu-popover");
    expect(menuPopover).toBeOnTheScreen();
  });

  it("should navigate to settings when the settings button in the menu popover is pressed", async () => {
    const menuButton = await screen.findByTestId("menu-button");
    fireEvent.press(menuButton);

    const menuPopover = await screen.findByTestId("menu-popover");
    expect(menuPopover).toBeOnTheScreen();
    
    const settingsButton = await screen.findByTestId("settings-button");
    fireEvent.press(settingsButton);
    
    const settingsPage = await screen.findByTestId("settings-page");
    expect(settingsPage).toBeOnTheScreen();

    const backButton = await screen.findByTestId("back-button");
    fireEvent.press(backButton);

    expect(settingsPage).not.toBeOnTheScreen();

    const chatPage = await screen.findByTestId("chat-page");
    expect(chatPage).toBeOnTheScreen();
  });

  it("should navigate to about when the about button in the menu popover is pressed", async () => {
    const menuButton = await screen.findByTestId("menu-button");
    fireEvent.press(menuButton);

    const menuPopover = await screen.findByTestId("menu-popover");
    expect(menuPopover).toBeOnTheScreen();
    
    const aboutButton = await screen.findByTestId("about-button");
    fireEvent.press(aboutButton);
    
    const aboutPage = await screen.findByTestId("about-page");
    expect(aboutPage).toBeOnTheScreen();

    const backButton = await screen.findByTestId("back-button");
    fireEvent.press(backButton);

    expect(aboutPage).not.toBeOnTheScreen();

    const chatPage = await screen.findByTestId("chat-page");
    expect(chatPage).toBeOnTheScreen();
  });
});
