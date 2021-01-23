"use strict";

const child_process = require("child_process");
const fs = require("fs");
const http = require("http");
const os = require("os");
const path = require("path");

const outdir = fs.mkdtempSync(path.join(os.tmpdir(), "xc-installers-"));
console.log(`downloading installers to [${outdir}]`);

function download(urlStr) {
  return new Promise((resolve, reject) => {
    console.log("downloading", urlStr);

    const url = new URL(urlStr);
    const fileName = path.basename(url.pathname);
    const filePath = path.join(outdir, fileName);
    const fileStream = fs.createWriteStream(filePath);

    const request = http.get(url, (res) => {
      if (res.statusCode != 200) {
        console.error(`failed to fetch [${urlStr}]: ${res.statusCode}`);
        reject(res.statusCode);
      }

      res.pipe(fileStream);
    });

    request.on("error", (err) => {
      console.error(`failed to fetch [${urlStr}]:`, err);
      reject(err);
    });

    fileStream.on("error", (err) => {
      console.error(`failed to write file [${filePath}]:`, err);
      reject(err);
    });

    fileStream.on("finish", () => {
      fileStream.close(() => {
        fs.chmod(filePath, "+x", () => {
          console.log("downloaded", fileName);
          resolve(filePath);
        });
      });
    });
  });
}

function install(execPath) {
  return new Promise((resolve, reject) => {
    const execName = path.basename(execPath);
    console.log("running", execName);

    const child = child_process.spawn(
      "sudo",
      [
        execPath,
        "--mode", "unattended",
        "--unattendedmodeui", "none",
        "--LicenseType", "FreeMode",
        "--netservername", "none",
      ],
      {
        stdio: ["ignore", "inherit", "inherit"],
      }
    );

    child.on("error", (err) => {
      console.error("failed to run", execName, err);
      reject(err);
    });

    child.on("exit", (code, signal) => {
      if (code === 0) {
        resolve();
      } else {
        console.error("failed to run", execName, code || signal);
        reject(code || signal);
      }
    });
  });
}

Promise.all(
  process.argv.slice(2).map((url) => download(url).then(install))
).then(() => {
  fs.promises.rm(outdir, {recursive: true});
}).catch(() => {
  process.exit(2);
});
