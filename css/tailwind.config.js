const defaultTheme = require("tailwindcss/defaultTheme.js");
const kit = require("fission-kit");
const tailwindui = require("@tailwindcss/ui");

module.exports = {
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
