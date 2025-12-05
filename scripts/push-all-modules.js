import fs from "node:fs/promises";
import path from "node:path";
import PQueue from "p-queue";
import { updateModule } from "../framework/utils.js";

/**
 * TODO
 * consider porting this and all other JS code to Lua
 */

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
    await updateModule(page)
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
