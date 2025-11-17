import fs from "node:fs/promises";
import path from "node:path";
import { mw } from "./utils.js";
import { preprocessModule } from "./preprocess-module.js";
import PQueue from "p-queue";

const mw = await Mwbot.init({
  apiUrl: "https://dragdown.wiki/w/api.php",
  credentials: {
    username: process.env.DRAGDOWN_USERNAME,
    password: process.env.DRAGDOWN_PASSWORD,
  },
});

const moduleFilesOnDiskWithModifiedNaming = await fs.readdir("./modules");
// const modulePagesOnDragdown = await mw.prefixSearch("Module:");

const moduleFilesOnDiskWithOriginalNaming = moduleFilesOnDiskWithModifiedNaming
  .map((file) => {
    const ext = path.extname(file);

    if (ext === ".lua" || ext === ".wikitext") {
      return path.parse(file).name;
    }

    return file;
  })
  .map((file) => `Module:${file.replaceAll("__", "/")}`);

const queue = new PQueue({ concurrency: 5 });

for (let i = 0; i < moduleFilesOnDiskWithModifiedNaming.length; i++) {
  queue.add(async () => {
    const page = moduleFilesOnDiskWithOriginalNaming[i];

    const { content: currentContentOnDragdown } = await mw.read(page);

    const currentUnpreprocessedContentOnDisk = await fs.readFile(
      `./modules/${moduleFilesOnDiskWithModifiedNaming[i]}`,
      "utf-8"
    );

    const currentPreprocessedContentOnDisk = preprocessModule(
      currentUnpreprocessedContentOnDisk
    );

    if (
      currentContentOnDragdown.trim() !==
      currentPreprocessedContentOnDisk.trim()
    ) {
      console.log("Updating", page);
      await mw.edit(page, () => ({
        text: currentPreprocessedContentOnDisk,
        bot: true,
        summary: "Auto-update from GitHub",
      }));
    }
  });
}

/**
 * TODO
 * code that updates a specified page on the wiki about the Module:
 * pages that should be deleted / are not contained in the repo anymore.
 */

// const modulePagesOnDragdownThatDontHaveAFile = modulePagesOnDragdown.filter(
//   (page) => !moduleFilesOnDiskWithOriginalNaming.includes(page.title)
// );

await queue.onIdle();

console.log("Done (success)");
