const fs = require('fs');
const path = require('path')
const package = require('../package.json')
const copy = require('./copy')

for (let index = 0; index < package.esp.length; index++) {
  const element = package.esp[index];
  const Src = path.join(package.SkyrimSE_Path, `Data/${element}.esp`)
  if (fs.existsSync(Src)) {
    copy(Src, path.join(__dirname, `../${element}.esp`))
    console.log(`Copied: ${element}.esp, from Skyrims data folder!`)
  }
  else {
    console.log(`File: ${element}.esp, Does not exsist!`)
  }
}
