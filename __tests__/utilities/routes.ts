import RootLayout from "../../app/_layout";
import About from "../../app/about";
import AccountLayout from "../../app/account/_layout";
import Account from "../../app/account/index";
import Login from "../../app/account/login";
import Register from "../../app/account/register";
import ChatLayout from "../../app/chat/_layout";
import Chat from "../../app/chat/index";
import Download from "../../app/download";
import Root from "../../app/index";
import Settings from "../../app/settings";

export default {
  "_layout": RootLayout,
  "index": Root,
  "account/_layout": AccountLayout,
  "account/index": Account,
  "account/login": Login,
  "account/register": Register,
  "chat/_layout": ChatLayout,
  "chat/index": Chat,
  "about": About,
  "download": Download,
  "settings": Settings,
};