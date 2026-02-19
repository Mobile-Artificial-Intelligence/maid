import { renderRouter, screen } from "expo-router/testing-library";

import RootLayout from "../app/_layout";
import Chat from "../app/chat/index";
import Index from "../app/index";

describe("Maid Routes", () => {
  beforeEach(() => {
    renderRouter(
      {
        "_layout": RootLayout,
        "index": Index,
        "chat/index": Chat,
      },
      {
        initialUrl: "/",
      }
    );
  });

  it("loads chat and shows the prompt input", async () => {
    const input = await screen.findByTestId("prompt-input");
    expect(input).toBeOnTheScreen();
    expect(input.type).toBe("TextInput");
  });
});
