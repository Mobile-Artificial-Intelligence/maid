import "@testing-library/jest-native/extend-expect";
import { View } from "react-native";
import "react-native-gesture-handler/jestSetup";

jest.mock("expo/fetch", () => {
  // Node 18+ provides fetch globally; if it’s missing, fall back to a stub.
  const f = globalThis.fetch ?? (() => Promise.reject(new Error("global fetch is not defined in Jest")));
  return { fetch: f };
});


jest.mock("@react-native-async-storage/async-storage", () =>
  require("@react-native-async-storage/async-storage/jest/async-storage-mock")
);

jest.mock("react-native-reanimated", () => require("react-native-reanimated/mock"));

beforeAll(() => {
  (View.prototype).measureInWindow = function (
    cb
  ) {
    cb(10, 20, 100, 40);
  };
});
