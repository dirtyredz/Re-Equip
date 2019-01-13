const path = require('path')
const package = require('../package.json')
const { exec } = require('child_process');

const PapyrusCompiler = path.join(package.SkyrimSE_Path,'/Papyrus Compiler/','PapyrusCompiler.exe')
const ScriptsToCompile = path.join(__dirname, '/../Scripts/Source')
const FlagFile = path.join(package.SkyrimSE_Path, package.Flags_Path)
const Output = path.join(__dirname, '/../Scripts')
let ImportDirectories = `"${path.join(__dirname,'/../Scripts/Source')}"`

for (let index = 0; index < package.Imports_Path.length; index++) {
  ImportDirectories += `;"${path.join(package.SkyrimSE_Path, package.Imports_Path[index])}"`
}

const compileCommand = `"${PapyrusCompiler}" "${ScriptsToCompile}" -all -i=${ImportDirectories} -o="${Output}" -f="${FlagFile}"`

console.log("Executing: ", compileCommand)
exec(compileCommand, (err, stdout, stderr) => {
  if (err) {
    // node couldn't execute the command
    console.log(err)
    return;
  }
  console.log("Compilation Complete!")
});
