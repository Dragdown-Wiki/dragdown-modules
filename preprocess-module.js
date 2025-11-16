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
    /require\(['"]([^'"]+)['"]\)/g,
    (match, requiredModuleName) => {
      if (
        requiredModuleName === "libraryUtil" ||
        requiredModuleName === "strict" ||
        requiredModuleName.startsWith("Module:")
      ) {
        return match;
      }
      // Preserve the original quote type
      const quote = match.includes('"') ? '"' : "'";
      return `require(${quote}Module:${requiredModuleName}${quote})`;
    }
  );

  return requiresPrefixedWithModule;
};
