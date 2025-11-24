/**
 * TODO / ideas
 * - consider adding `require("strict")` to the top of every module
 *    https://www.mediawiki.org/wiki/Extension:Scribunto/Lua_reference_manual#strict
 */

/**
 * preprocessing allows us to remove "Module:" when using require,
 * enabling intellisense/autocomplete for them.
 * with the preprocessing we add this back when we update the files.
 */
export const preprocessModule = (luaString) => {
  const requiresPrefixedWithModule = luaString.replace(
    /require\(\s*['"]([^'"]+)['"]\s*\)/g,
    (match, requiredModuleName) => {
      if (
        requiredModuleName === "libraryUtil" ||
        requiredModuleName === "strict"
      ) {
        return match;
      }

      // Preserve the original quote type
      const quote = match.includes('"') ? '"' : "'";

      if (requiredModuleName.startsWith("pl.")) {
        const penlightSubmodule = requiredModuleName.slice("pl.".length)
        const firstUpper = penlightSubmodule[0].toUpperCase() + penlightSubmodule.slice(1)
        return `require(${quote}Module:Penlight_${firstUpper}${quote})`
      }

      return `require(${quote}Module:${requiredModuleName}${quote})`;
    }
  );

  return requiresPrefixedWithModule;
};
