import { fireEvent, renderRouter, screen } from "expo-router/testing-library";
import routes from "./utilities/routes";

describe("Login page", () => {
  beforeEach(() => renderRouter(routes, { initialUrl: "/account/login" }));

  it("should render the login page", async () => {
    const loginPage = await screen.findByTestId("login-page");
    expect(loginPage).toBeOnTheScreen();
    expect(loginPage.type).toBe("View");
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

  it("should accept text in the email input", async () => {
    const emailInput = await screen.findByPlaceholderText("Email");
    fireEvent.changeText(emailInput, "test@example.com");
    expect(emailInput.props.value).toBe("test@example.com");
  });

  it("should accept text in the password input", async () => {
    const passwordInput = await screen.findByPlaceholderText("Password");
    fireEvent.changeText(passwordInput, "password123");
    expect(passwordInput.props.value).toBe("password123");
  });

  it("should navigate to the register page when the register link is pressed", async () => {
    const registerLink = await screen.findByText("Don't have an account? Register");
    fireEvent.press(registerLink);

    const registerPage = await screen.findByTestId("register-page");
    expect(registerPage).toBeOnTheScreen();
  });

  it("should navigate to the reset password page when the forgot password link is pressed", async () => {
    const forgotPasswordLink = await screen.findByText("Forgot password?");
    fireEvent.press(forgotPasswordLink);

    const resetPasswordPage = await screen.findByTestId("reset-password-page");
    expect(resetPasswordPage).toBeOnTheScreen();
  });
});
