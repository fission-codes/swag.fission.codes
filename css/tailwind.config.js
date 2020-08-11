import defaultTheme from "tailwindcss/defaultTheme.js";
import * as kit from "fission-kit";

export default {
  theme: {
    colors: {
      ...kit.dasherizeObjectKeys(kit.colors),
    },

    fontFamily: {
      ...defaultTheme.fontFamily,

      body: [`"${kit.fonts.body}"`, ...defaultTheme.fontFamily.sans],
      display: [`"${kit.fonts.display}"`, ...defaultTheme.fontFamily.serif],
      mono: [`"${kit.fonts.mono}"`, ...defaultTheme.fontFamily.mono],
    },

    extend: {
      screens: {
        dark: { raw: "(prefers-color-scheme: dark)" },
      },
    },
  },
};
