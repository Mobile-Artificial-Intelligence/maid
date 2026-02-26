import { fireEvent, renderRouter, screen } from "expo-router/testing-library";
import routes from "./utilities/routes";

describe("Account page", () => {
  beforeEach(() => renderRouter(routes, { initialUrl: "/account" }));

  it("should render the account page", async () => {
    const accountPage = await screen.findByTestId("account-page");
    expect(accountPage).toBeOnTheScreen();
    expect(accountPage.type).toBe("View");
  });

  it("should render the logout button", async () => {
    const logoutButton = await screen.findByTestId("logout-button");
    expect(logoutButton).toBeOnTheScreen();
  });

  it("should render the change password button", async () => {
    const changePasswordButton = await screen.findByTestId("change-password-button");
    expect(changePasswordButton).toBeOnTheScreen();
  });

  it("should render the delete account button", async () => {
    const deleteAccountButton = await screen.findByTestId("delete-account-button");
    expect(deleteAccountButton).toBeOnTheScreen();
  });

  it("should show the delete confirmation when the delete account button is pressed", async () => {
    const deleteAccountButton = await screen.findByTestId("delete-account-button");
    fireEvent.press(deleteAccountButton);

    const confirmModal = await screen.findByTestId("delete-confirm-modal");
    expect(confirmModal).toBeOnTheScreen();
  });

  it("should hide the delete confirmation when the cancel button is pressed", async () => {
    const deleteAccountButton = await screen.findByTestId("delete-account-button");
    fireEvent.press(deleteAccountButton);

    const confirmModal = await screen.findByTestId("delete-confirm-modal");
    expect(confirmModal).toBeOnTheScreen();

    const cancelButton = await screen.findByTestId("delete-cancel-button");
    fireEvent.press(cancelButton);

    expect(confirmModal).not.toBeOnTheScreen();
  });

  it("should navigate to the change password page when the change password button is pressed", async () => {
    const changePasswordButton = await screen.findByTestId("change-password-button");
    fireEvent.press(changePasswordButton);

    const changePasswordPage = await screen.findByTestId("change-password-page");
    expect(changePasswordPage).toBeOnTheScreen();
  });
});
