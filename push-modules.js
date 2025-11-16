import { Mwbot } from "mwbot-ts";

const mw = await Mwbot.init({
  apiUrl: "https://dragdown.wiki/w/api.php",
  credentials: {
    username: process.env.DRAGDOWN_USERNAME,
    password: process.env.DRAGDOWN_PASSWORD,
  },
});

await mw.edit("Module:Waffeln Sandbox", (_previous) => {
  return {
    text: `
return {
	main = function(frame)
        return "deploy successful!"
	end
}
`,
  };
});
