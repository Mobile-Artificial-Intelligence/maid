import "@testing-library/jest-native/extend-expect";

jest.mock("@react-native-async-storage/async-storage", () =>
  require("@react-native-async-storage/async-storage/jest/async-storage-mock")
);

// If you use Reanimated anywhere (or it gets pulled in), this prevents crashes:
jest.mock("react-native-reanimated", () => require("react-native-reanimated/mock"));
