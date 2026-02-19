import { renderRouter, screen } from "expo-router/testing-library";

import RootLayout from "../app/_layout";
import About from "../app/about";
import ChatLayout from "../app/chat/_layout";
import Chat from "../app/chat/index";
import Downloads from "../app/download";
import Root from "../app/index";
import Settings from "../app/settings";

describe("Maid Routes", () => {
  beforeEach(() => {
    renderRouter(
      {
        "_layout": RootLayout,
        "index": Root,
        "chat/_layout": ChatLayout,
        "chat/index": Chat,
        "about": About,
        "downloads": Downloads,
        "settings": Settings,
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
