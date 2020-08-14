import defaultTheme from "tailwindcss/defaultTheme.js";
import * as kit from "fission-kit";
import tailwindui from "@tailwindcss/ui";

export default {
  purge: [
    './src/*.elm',
    './src/**/*.elm',
  ],

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
      fontSize: {
        md: "1.0625rem",
      },
    },
  },

  plugins: [
    tailwindui,
  ],
};
