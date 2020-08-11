import "./css/built.css";

import { Elm } from "./src/Main.elm";
import pagesInit from "elm-pages";

pagesInit({
  mainElmModule: Elm.Main,
});
