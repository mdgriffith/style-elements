#!/usr/bin/env node

var styleElements = require("../");
var pkg = require("../package.json");
var program = require("commander");
var fs = require("fs");
var chalk = require("chalk");
var requiredOptions = ["stylesheetModule", "stylesheetFunction", "output"];
var { writeFile, assertKeysPresent } = require("../js/utils");

var { output, stylesheetModule, stylesheetFunction } = getOptions(
  process.argv,
  program
);

styleElements({ stylesheetModule, stylesheetFunction })
  .then(result => writeFile(output, result))
  .then(() => {
    console.warn(
      chalk.green(`\n----> Success! styles were written to ${program.output}\n`)
    );
  });

function getOptions(argv, program) {
  program
    .version(pkg.version)
    .usage("[options] <stylesheetModule> <stylesheetFunction>")
    .option(
      "-o, --output [outputFile]",
      "(optional) file to write the CSS to",
      "out.css"
    )
    .parse(argv);

  var options = {
    stylesheetModule: program.args[0],
    stylesheetFunction: program.args[1],
    output: program.output
  };

  assertKeysPresent(options, requiredOptions, _missingOptions => {
    program.outputHelp();
    process.exit(1);
  });

  return options;
}
