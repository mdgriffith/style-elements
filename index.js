var path = require("path");
var compileElm = require("node-elm-compiler").compile;
var utils = require("./js/utils.js");

var unindent = utils.unindent;
var writeFile = utils.writeFile;
var withTmpDir = utils.withTmpDir;
var assertKeysPresent = utils.assertKeysPresent;

var requiredOptions = ["stylesheetModule", "stylesheetFunction", "mode"];

function generateCss(opts) {
  assertKeysPresent(opts, requiredOptions, missingOptions => {
    throw new Error(`Missing options: ${missingOptions.join(", ")}`);
  });

  return withTmpDir().then(tmpDirPath => {
    var emitterSourceFile = path.join(tmpDirPath, "StyleElementsEmitter.elm");
    var emitterWorkerFile = path.join(tmpDirPath, "style-elements-emitter.js");
    var emitterTemplate = buildEmitterTemplate(
      opts.stylesheetModule,
      opts.stylesheetFunction,
      opts.mode
    );

    return writeFile(emitterSourceFile, emitterTemplate)
      .then(() => compile(emitterSourceFile, { output: emitterWorkerFile, yes: true }))
      .then(() => extractCssResults(emitterWorkerFile));
  });
}

function buildEmitterTemplate(stylesheetModule, stylesheetFunction, mode) {
  return unindent(
    `
    port module StyleElementsEmitter exposing (..)

    import ${stylesheetModule}
    import Element


    port result : String -> Cmd msg


    styles =
        Element.${renderFunction(mode)} ${stylesheetModule}.${stylesheetFunction}


    main : Program Never () Never
    main =
        Platform.program
            { init = ( (), result styles )
            , update = \\_ _ -> ( (), Cmd.none )
            , subscriptions = \\_ -> Sub.none
            }
    `
  );
}

function renderFunction(mode) {
  switch (mode) {
    case "viewport": return "toViewportCss";
    case "layout": return "toLayoutCss";
    default: throw new Error(`Invalid mode: ${mode}, must be either 'layout' or 'viewport'`);
  }
}

function compile(src, options) {
  return new Promise(function(resolve, reject) {
    compileElm(src, options).on("close", function(exitCode) {
      if (exitCode === 0) {
        resolve();
      } else {
        reject("Errored with exit code " + exitCode);
      }
    });
  });
}

function extractCssResults(destFile) {
  var emitter = require(destFile).StyleElementsEmitter;
  var worker = emitter.worker();

  return new Promise(resolve => worker.ports.result.subscribe(resolve));
}

module.exports = generateCss;
