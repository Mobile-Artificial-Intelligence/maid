import { argbFromHex, hexFromArgb, themeFromSourceColor } from "@material/material-color-utilities";

export type Brightness = "light" | "dark";

export interface ColorScheme {
  brightness: Brightness;

  // Primary
  primary: string;
  onPrimary: string;
  primaryContainer: string;
  onPrimaryContainer: string;

  // Secondary
  secondary: string;
  onSecondary: string;
  secondaryContainer: string;
  onSecondaryContainer: string;

  // Tertiary
  tertiary: string;
  onTertiary: string;
  tertiaryContainer: string;
  onTertiaryContainer: string;

  // Error
  error: string;
  onError: string;
  errorContainer: string;
  onErrorContainer: string;

  // Surface & background
  surface: string;
  onSurface: string;
  surfaceVariant: string;
  onSurfaceVariant: string;

  // Utility
  outline: string;
  outlineVariant: string;
  shadow: string;
  scrim: string;

  // Inverse roles
  inverseSurface: string;
  inverseOnSurface: string;
  inversePrimary: string;
}

function enforceDeeperDark(scheme: ColorScheme): ColorScheme {
  if (scheme.brightness !== "dark") return scheme;

  return {
    ...scheme,

    // true dark surfaces
    surface: "#0b0b0c",
    surfaceVariant: "#121316",

    // improve contrast
    inverseSurface: "#e6e6e6",
    outlineVariant: "#2a2b30",

    // darker overlay
    scrim: "#000000",
  };
}

export function createColorScheme(seedColor: string, brightness: Brightness = "light"): ColorScheme {
  const cleanedSeedColor = `#${seedColor.replace(/^#/, '').slice(0, 6)}`;

  const theme = themeFromSourceColor(argbFromHex(cleanedSeedColor));

  const scheme = brightness === "light" ? theme.schemes.light : theme.schemes.dark;

  return enforceDeeperDark({
    brightness,
    primary: hexFromArgb(scheme.primary),
    onPrimary: hexFromArgb(scheme.onPrimary),
    primaryContainer: hexFromArgb(scheme.primaryContainer),
    onPrimaryContainer: hexFromArgb(scheme.onPrimaryContainer),
    secondary: hexFromArgb(scheme.secondary),
    onSecondary: hexFromArgb(scheme.onSecondary),
    secondaryContainer: hexFromArgb(scheme.secondaryContainer),
    onSecondaryContainer: hexFromArgb(scheme.onSecondaryContainer),
    tertiary: hexFromArgb(scheme.tertiary),
    onTertiary: hexFromArgb(scheme.onTertiary),
    tertiaryContainer: hexFromArgb(scheme.tertiaryContainer),
    onTertiaryContainer: hexFromArgb(scheme.onTertiaryContainer),
    error: hexFromArgb(scheme.error),
    onError: hexFromArgb(scheme.onError),
    errorContainer: hexFromArgb(scheme.errorContainer),
    onErrorContainer: hexFromArgb(scheme.onErrorContainer),
    surface: hexFromArgb(scheme.surface),
    onSurface: hexFromArgb(scheme.onSurface),
    surfaceVariant: hexFromArgb(scheme.surfaceVariant),
    onSurfaceVariant: hexFromArgb(scheme.onSurfaceVariant),
    outline: hexFromArgb(scheme.outline),
    outlineVariant: hexFromArgb(scheme.outlineVariant),
    shadow: hexFromArgb(scheme.shadow),
    scrim: hexFromArgb(scheme.scrim),
    inverseSurface: hexFromArgb(scheme.inverseSurface),
    inverseOnSurface: hexFromArgb(scheme.inverseOnSurface),
    inversePrimary: hexFromArgb(scheme.inversePrimary),
  });
}