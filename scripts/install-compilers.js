"use strict";

const fs = require("fs");
const https = require("https");
const path = require("path");

function install(urlStr) {
  console.log("downloading", urlStr);

  const url = new URL(urlStr);
  const filePath = path.join("tmp", path.basename(url.path));
  const fileStream = fs.createWriteStream(filePath);

  const request = https.get(url, (res) => {
    if (res.statusCode != 200) {
      console.error(`failed to fetch [${urlStr}]: ${res.statusCode}`);
      process.exit(2);
    }

    res.pipe(fileStream);
  });

  request.on("error", (err) => {
    console.error(`failed to fetch [${urlStr}]:`, err);
    process.exit(2);
  });

  fileStream.on("error", (err) => {
    console.error(`failed to write file [${filePath}]:`, err);
    process.exit(2);
  });

  fileStream.on("finish", () => {
    fileStream.close(() => {
      console.log(`downloaded [${url}]`);
    });
  });
}

for (const url of process.argv.slice(2)) {
  install(url);
}
