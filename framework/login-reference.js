// just some dependency-less JS mediawiki login code for reference

const token = await fetch(
  "https://dragdown.wiki/w/api.php?action=query&format=json&meta=tokens&type=*"
);

const tokenJson = await token.json();

const loginWithFetch = await fetch("https://dragdown.wiki/w/api.php", {
  method: "POST",
  body: `action=login&lgname=User&lgpassword=${encodeURIComponent(
    "Password"
  )}&lgtoken=${encodeURIComponent(tokenJson.query.tokens.logintoken)}`,
  headers: {
    Cookie: token.headers.get("set-cookie"),
    "Content-Type": "application/x-www-form-urlencoded",
  },
});

const response = await fetch(
  "https://dragdown.wiki/w/api.php?format=json&action=cargoquery",
  {
    headers: {
      Cookie: loginWithFetch.headers.getSetCookie().join(";"),
    },
  }
);

console.log(await response.json());
