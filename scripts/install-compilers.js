"use strict";

const fs = require("fs");
const http = require("http");
const os = require("os");
const path = require("path");

const outdir = fs.mkdtempSync(path.join(os.tmpdir(), "xc-installers-"));
console.log(`downloading installers to [${outdir}]`);

function install(urlStr) {
  console.log(`downloading [${urlStr}]`);

  const url = new URL(urlStr);
  const fileName = path.basename(url.pathname);
  const filePath = path.join(outdir, fileName);
  const fileStream = fs.createWriteStream(filePath);

  const request = http.get(url, (res) => {
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
      console.log(`downloaded [${fileName}]`);
    });
  });
}

for (const url of process.argv.slice(2)) {
  install(url);
}
