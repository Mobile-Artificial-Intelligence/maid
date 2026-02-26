import { fireEvent, renderRouter, screen } from "expo-router/testing-library";
import routes from "./utilities/routes";

describe("Register page", () => {
  beforeEach(() => renderRouter(routes, { initialUrl: "/account/register" }));

  it("should render the register page", async () => {
    const registerPage = await screen.findByTestId("register-page");
    expect(registerPage).toBeOnTheScreen();
    expect(registerPage.type).toBe("View");
  });

  it("should render the username input", async () => {
    const usernameInput = await screen.findByPlaceholderText("Username");
    expect(usernameInput).toBeOnTheScreen();
    expect(usernameInput.type).toBe("TextInput");
  });

  it("should render the email input", async () => {
    const emailInput = await screen.findByPlaceholderText("Email");
    expect(emailInput).toBeOnTheScreen();
    expect(emailInput.type).toBe("TextInput");
  });

  it("should render the password input", async () => {
    const passwordInput = await screen.findByPlaceholderText("Password");
    expect(passwordInput).toBeOnTheScreen();
    expect(passwordInput.type).toBe("TextInput");
  });

  it("should render the confirm password input", async () => {
    const confirmPasswordInput = await screen.findByPlaceholderText("Confirm Password");
    expect(confirmPasswordInput).toBeOnTheScreen();
    expect(confirmPasswordInput.type).toBe("TextInput");
  });

  it("should accept text in the username input", async () => {
    const usernameInput = await screen.findByPlaceholderText("Username");
    fireEvent.changeText(usernameInput, "testuser");
    expect(usernameInput.props.value).toBe("testuser");
  });

  it("should accept text in the email input", async () => {
    const emailInput = await screen.findByPlaceholderText("Email");
    fireEvent.changeText(emailInput, "test@example.com");
    expect(emailInput.props.value).toBe("test@example.com");
  });

  it("should navigate to the login page when the login link is pressed", async () => {
    const loginLink = await screen.findByTestId("login-link");
    fireEvent.press(loginLink);

    const loginPage = await screen.findByTestId("login-page");
    expect(loginPage).toBeOnTheScreen();
  });
});
