import { renderRouter } from "expo-router/testing-library";

import RootLayout from "../app/_layout";
import About from "../app/about";
import AccountLayout from "../app/account/_layout";
import Account from "../app/account/index";
import Login from "../app/account/login";
import Register from "../app/account/register";
import ChatLayout from "../app/chat/_layout";
import Chat from "../app/chat/index";
import Downloads from "../app/download";
import Root from "../app/index";
import Settings from "../app/settings";

function renderApp() {
  renderRouter(
    {
      "_layout": RootLayout,
      "index": Root,
      "account/_layout": AccountLayout,
      "account/index": Account,
      "account/login": Login,
      "account/register": Register,
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
}

export default renderApp;