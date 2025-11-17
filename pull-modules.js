import fs from "node:fs/promises";
import path from "node:path";
import { mw } from "./utils";

const mw = await Mwbot.init({
  apiUrl: "https://dragdown.wiki/w/api.php",
  credentials: {
    username: process.env.DRAGDOWN_USERNAME,
    password: process.env.DRAGDOWN_PASSWORD,
  },
});

const modulePages = await mw.prefixSearch("Module:");

for (const { title } of modulePages) {
  const { content } = await mw.read(title);
  let fileName = title.slice("Module:".length);

  if (path.extname(title).trim() === "") {
    fileName += fileName.includes("/") ? ".wikitext" : ".lua";
  }

  fs.writeFile(`./modules/${fileName.replaceAll("/", "__")}`, content);
}
