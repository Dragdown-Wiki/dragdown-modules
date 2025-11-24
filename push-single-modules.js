import { updateModule } from "./utils.js";

/**
 * TODO
 * consider porting this and all other JS code to Lua
 */

await updateModule(process.argv[2]);

console.log("Done (success)");
