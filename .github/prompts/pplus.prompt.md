---
agent: agent
---
this is primarily a lua project.

the main focus is the /modules folder, which contains lua modules from the wiki, which is powered by mediawiki and uses the scribunto extension to run lua code.

you can look at /framework, but don't edit it because it's just for testing the module output and mocking mediawiki functions.

the general focus is on optimizing the lua code. there's a lot of redundant and confusing code that can be simplified.

the goal is to have as few lines of code as possible without massively sacrificing readability.

most "Move Card" modules share a lot of logic.

your task is to optimize "PPlus Move Card" by cross-checking logic with the already mostly optimized "AFQM Move Card" and "Move_Card_Lib.lua" which should only contain shared logic.

to check if a refactor maintains the current logic, you need to run `lua ./scripts/compare-reference-output.lua`. if it runs successfully (outputs "done :)"), the refactor is valid.
if it errors, it will output the error.

if the error is because of output difference between the current rendered module output and the "reference_output", the code will write the output of the erroring configuration to "dump.html".
the error in the terminal will then include what the configuration was (game, character, attack/move) and you can look up that file in the reference_output folder and compare it to dump.html to see what changed.

dump.html is not deleted or overwritten on successful runs, it's only relevant if the current error output is about a mismatch.

to reiterate: your task is to refactor "PPlus Move Card". you can and should try larger and ambitious refactors, as long as the output remains the same. if you find common logic between AFQM and PPlus, move it to Move_Card_Lib.lua.