import tailwindcss from "tailwindcss";
import autoprefixer from "autoprefixer";

import defaultTheme from "tailwindcss/defaultTheme.js";
import * as kit from "fission-kit";
import tailwindui from "@tailwindcss/ui";


const tailwindConfig = {
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
                mds: "0.9375rem",
                md: "1.0625rem",
            },
            margin: {
                "6px": "6px",
            },
        },

        customForms: theme => ({
            default: {
                input: {
                    borderRadius: theme('borderRadius.lg'),
                    borderColor: kit.colors.gray_300,
                    borderWidth: '2px',
                    '&:focus': {
                        borderColor: theme('colors.purple'),
                        boxShadow: undefined,
                    }
                },
            },
        }),
    },

    plugins: [
        tailwindui,
    ],
};

export default process.env["NODE_ENV"] === "production" ?
    [
        tailwindcss(tailwindConfig),
        autoprefixer,
    ] : [
        tailwindcss(tailwindConfig),
    ];
