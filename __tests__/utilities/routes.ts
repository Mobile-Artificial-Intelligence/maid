import RootLayout from "../../app/_layout";
import About from "../../app/about";
import AccountLayout from "../../app/account/_layout";
import Account from "../../app/account/index";
import ChangePassword from "../../app/account/change-password";
import Login from "../../app/account/login";
import Register from "../../app/account/register";
import ResetPassword from "../../app/account/reset-password";
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
  "account/change-password": ChangePassword,
  "account/reset-password": ResetPassword,
  "chat/_layout": ChatLayout,
  "chat/index": Chat,
  "about": About,
  "download": Download,
  "settings": Settings,
};