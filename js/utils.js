var tmp = require("tmp");
var fs = require("fs");

module.exports = {
  unindent: function(text) {
    var indentation = text.split("\n")
      .map(line => {
        var match = line.match(/([\s]+)[^\s]+/);
        return match && match[1];
      })
      .find(value => value);

    return indentation
      ? text.replace(new RegExp(`^${indentation}`, "gm"), "")
      : text;
  },

  writeFile: function(path, content) {
    return new Promise((resolve, reject) => {
      return fs.writeFile(path, content, err => (err ? reject(err) : resolve()));
    });
  },

  withTmpDir: function() {
    return new Promise(function(resolve, reject) {
      tmp.dir({ unsafeCleanup: true }, function(err, tmpDirPath) {
        if (err) {
          reject(err);
        } else {
          resolve(tmpDirPath);
        }
      });
    });
  },

  assertKeysPresent: function(object, requiredKeys, missingCallback) {
    var providedKeys = Object.keys(object || {});
    var missingKeys = requiredKeys.filter(key => {
      return (
        providedKeys.indexOf(key) === -1 || providedKeys[key] === ""
      );
    });

    if (missingKeys.length > 0) {
      missingCallback(missingKeys);
    }
  }
};
