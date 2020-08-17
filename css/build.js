import { promises as fs, watch, watchFile } from "fs";
import postcss from "postcss";


const configFile = "./config.js"
const from = "./css/style.css";
const to = "./css/built.css";

async function build() {
    const { default: config } = await import(configFile);
    const input = await fs.readFile(from);
    const result = await postcss(config).process(input, { from, to });
    await fs.writeFile(to, result.css);
}

async function watchAndBuild() {
    await build();

    console.log("Watching for file changes.");

    const rebuild = file => async () => {
        console.log(file + " changed. Rebuilding.");

        await build();

        console.log("Built.");
    }

    watchFile(from, {}, rebuild(from));
    watchFile("./css/config.js", {}, rebuild("./css/config.js"));
}

if (process.argv.find(arg => arg === "--watch") != null) {
    watchAndBuild();
} else {
    build();
}