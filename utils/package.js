// require modules
const fs = require('fs');
const archiver = require('archiver');
const package = require('../package.json')
const del = require('del');
const path = require('path')
const copy = require('./copy')

var mkdir = function(dir) {
	// making directory without exception if exists
	try {
		fs.mkdirSync(dir, 0755);
	} catch(e) {
		if(e.code != "EEXIST") {
			throw e;
		}
	}
};

var copyDir = function(src, dest) {
	mkdir(dest);
	var files = fs.readdirSync(src);
	for(var i = 0; i < files.length; i++) {
		var current = fs.lstatSync(path.join(src, files[i]));
		if(current.isDirectory()) {
			copyDir(path.join(src, files[i]), path.join(dest, files[i]));
		} else if(current.isSymbolicLink()) {
			var symlink = fs.readlinkSync(path.join(src, files[i]));
			fs.symlinkSync(symlink, path.join(dest, files[i]));
		} else {
			copy(path.join(src, files[i]), path.join(dest, files[i]));
		}
	}
};

del(['*.zip']).then(paths => {
  // create a file to stream archive data to.
  var output = fs.createWriteStream(path.join(path.normalize(__dirname + "/../"), 'ReEquip-v' + package.version + '.zip'));
  var archive = archiver('zip', {
    zlib: { level: 9 } // Sets the compression level.
  });

  // listen for all archive data to be written
  // 'close' event is fired only when a file descriptor is involved
  output.on('close', function() {
    console.log(archive.pointer() + ' total bytes');
    console.log('archiver has been finalized and the output file descriptor has closed.');
    del([path.normalize(__dirname + "/../Source")])
  });

  // This event is fired when the data source is drained no matter what was the data source.
  // It is not part of this library but rather from the NodeJS Stream API.
  // @see: https://nodejs.org/api/stream.html#stream_event_end
  output.on('end', function() {
    console.log('Data has been drained');
  });

  // good practice to catch warnings (ie stat failures and other non-blocking errors)
  archive.on('warning', function(err) {
    if (err.code === 'ENOENT') {
      // log warning
    } else {
      // throw error
      throw err;
    }
  });

  // good practice to catch this error explicitly
  archive.on('error', function(err) {
    throw err;
  });

  archive.pipe(output);

  // append a file from stream
  archive.append(
    fs.createReadStream(
      path.normalize(__dirname + '/../ReEquip.esp')
    ),
    { name: 'ReEquip.esp' }
  );

  // append files from a sub-directory, putting its contents at the root of archive
  archive.directory(path.normalize(__dirname + '/../Scripts/'), "Scripts");
  // archive.directory('mods/', true);
  mkdir(path.normalize(__dirname + '/../Source/'))
  copyDir(path.normalize(__dirname + '/../Scripts/Source'), path.normalize(__dirname + '/../Source/Scripts'))

  archive.directory(path.normalize(__dirname + '/../Source/'), "Source");
  // finalize the archive (ie we are done appending files but streams have to finish yet)
  // 'close', 'end' or 'finish' may be fired right after calling this method so register to them beforehand
  archive.finalize();

});
