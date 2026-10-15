import AsyncStorage from "@react-native-async-storage/async-storage";
import { act, renderHook, waitFor } from "@testing-library/react-native";
import * as ReactNative from "react-native";
import useTheme from "../hooks/use-theme";

describe("useTheme", () => {
  beforeEach(async () => {
    jest.clearAllMocks();
    await AsyncStorage.clear();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("follows the system color scheme by default", async () => {
    jest.spyOn(ReactNative, "useColorScheme").mockReturnValue("light");
    const { result } = renderHook(() => useTheme());

    await waitFor(() => expect(AsyncStorage.getItem).toHaveBeenCalledWith("theme_mode"));
    expect(result.current.themeMode).toBe("system");
    expect(result.current.colorScheme.brightness).toBe("light");
  });

  it("uses the stored theme mode over the system color scheme", async () => {
    jest.spyOn(ReactNative, "useColorScheme").mockReturnValue("light");
    await AsyncStorage.setItem("theme_mode", "dark");
    const { result } = renderHook(() => useTheme());

    await waitFor(() => expect(result.current.themeMode).toBe("dark"));
    expect(result.current.colorScheme.brightness).toBe("dark");
  });

  it("ignores an invalid stored theme mode", async () => {
    jest.spyOn(ReactNative, "useColorScheme").mockReturnValue("light");
    await AsyncStorage.setItem("theme_mode", "sepia");
    const { result } = renderHook(() => useTheme());

    await waitFor(() => expect(AsyncStorage.getItem).toHaveBeenCalledWith("theme_mode"));
    expect(result.current.themeMode).toBe("system");
    expect(result.current.colorScheme.brightness).toBe("light");
  });

  it("saves the selected theme mode", async () => {
    jest.spyOn(ReactNative, "useColorScheme").mockReturnValue("dark");
    const { result } = renderHook(() => useTheme());
    await waitFor(() => expect(AsyncStorage.getItem).toHaveBeenCalledWith("theme_mode"));

    act(() => result.current.setThemeMode("light"));

    expect(result.current.colorScheme.brightness).toBe("light");
    await waitFor(async () => expect(await AsyncStorage.getItem("theme_mode")).toBe("light"));
  });
});
