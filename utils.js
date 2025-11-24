import { Mwbot } from "mwbot-ts";
import path from "node:path";
import fs from "node:fs/promises";
import { preprocessModule } from "./preprocess-module.js";

export const mw = await Mwbot.init({
  apiUrl: "https://dragdown.wiki/w/api.php",
  credentials: {
    username: process.env.DRAGDOWN_USERNAME,
    password: process.env.DRAGDOWN_PASSWORD,
  },
});

const addNameSpaceAndPaths = (fileName) => {
  return `Module:${fileName.replaceAll("__", "/")}`;
};

const getNameOnWiki = (fileNameOrPath) => {
  const { base } = path.parse(fileNameOrPath);
  const ext = path.extname(base);

  if (ext === ".lua" || ext === ".wikitext") {
    return addNameSpaceAndPaths(path.parse(base).name);
  }

  return addNameSpaceAndPaths(base);
};

export const updateModule = async (localFilePath) => {
  const page = getNameOnWiki(localFilePath);
  const { content: currentContentOnDragdown } = await mw.read(page);

  const currentUnpreprocessedContentOnDisk = await fs.readFile(
    localFilePath,
    "utf-8"
  );

  const currentPreprocessedContentOnDisk = preprocessModule(
    currentUnpreprocessedContentOnDisk
  );

  if (
    currentContentOnDragdown.trim() !== currentPreprocessedContentOnDisk.trim()
  ) {
    console.log("Updating", page);

    await mw.edit(page, () => ({
      text: currentPreprocessedContentOnDisk,
      bot: true,
      summary: "Auto-update from GitHub",
    }));
  }
};
