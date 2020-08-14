import { promises as fs, watchFile } from "fs";
import postcss from "postcss";

import tailwindcss from "tailwindcss";
import autoprefixer from "autoprefixer";

import defaultTheme from "tailwindcss/defaultTheme.js";
import * as kit from "fission-kit";
import tailwindui from "@tailwindcss/ui";


// CONFIG


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
                md: "1.0625rem",
            },
        },
    },

    plugins: [
        tailwindui,
    ],
};


const plugins = process.env["NODE_ENV"] === "production" ?
    [
        tailwindcss(tailwindConfig),
        autoprefixer,
    ] : [
        tailwindcss(tailwindConfig),
    ];


// THE BUILD ITSELF


const from = "./css/style.css";
const to = "./css/built.css";

async function build() {
    const input = await fs.readFile(from);
    const result = await postcss(plugins).process(input, { from, to });
    await fs.writeFile(to, result.css);
}

async function watchAndBuild() {
    await build();

    console.log("Watching for file changes.");

    watchFile(from, {}, async () => {
        console.log(from + " changed. Rebuilding.");

        await build();

        console.log("Built.");
    });
}

if (process.argv.find(arg => arg === "--watch") != null) {
    watchAndBuild();
} else {
    build();
}