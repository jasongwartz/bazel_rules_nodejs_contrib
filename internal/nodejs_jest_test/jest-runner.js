const nodePath = require('path');
const { createInterface } = require('readline');

const jest = require('jest-cli');
const fs = require('fs-extra');

const configPath = 'TEMPLATED_config_path';

// runCLI accepts a path as well as a json string for the config
// const jestConfig = configPath ? nodePath.resolve(configPath) : '{}';
const jestConfig = configPath ? configPath : '{}';
// var http = require('http');

// let path = "";

// process.stdin.on('data', function(chunk) {
//   console.log("!!!!!");
//   var buffer = new Buffer(chunk);
//   path = buffer.toString();
// });

function onRequest(request, response) {
  // process.stdin.on('data', function(chunk) {
  //   console.log("Got data");
  //   var buffer = new Buffer(chunk);
  //   path = buffer.toString();
  // });

  // const rl = createInterface({input: process.stdin, terminal: true});

  // rl.on('line', chunk => {
  //   console.log('Got line');
  //   console.log(chunk)
  //   console.log('IBAZEL WRITE');
  //   if (chunk === IBAZEL_NOTIFY_BUILD_SUCCESS) {
  //     console.log("should rerun");
  //   }
  // });
  // rl.on('close', () => {
  //   console.error('ibazel stream closed server');
  //   // Give ibazel 5s to kill our process, otherwise do it ourselves
  //   // setTimeout(() => {
  //   //   console.error('ibazel failed to stop karma; probably a bug');
  //   //   process.exit(1);
  //   // }, 5000);
  // });
  // console.log("Request received" + path);
  response.end();
  // fs.readdir(path, function(err, items) {
  //   response.writeHead(200, {"Content-Type": "text/plain"});
  //   response.write(JSON.stringify(items));
  //   response.end();
  // });
}

// Note: this was as a test to get ibazel properly to work
// http.createServer(onRequest).listen(8000);


const rl = createInterface({input: process.stdin, terminal: true});

rl.on('line', chunk => {
  console.log('Got line')
  console.log(chunk)
  console.log('IBAZEL WRITE');
  if (chunk === IBAZEL_NOTIFY_BUILD_SUCCESS) {
    console.log("should rerun");
  }
});
rl.on('close', () => {
  // console.error('ibazel stream closed');
  // Give ibazel 5s to kill our process, otherwise do it ourselves
  // setTimeout(() => {
  //   console.error('ibazel failed to stop karma; probably a bug');
  //   process.exit(1);
  // }, 5000);
});


const IBAZEL_NOTIFY_BUILD_SUCCESS = 'IBAZEL_BUILD_COMPLETED SUCCESS';
const IBAZEL_NOTIFY_CHANGES = 'IBAZEL_NOTIFY_CHANGES';

const outputDir = process.env.TEST_UNDECLARED_OUTPUTS_DIR;
// console.log("outputDir", outputDir);
// console.log("process env", process.env);
const cwd = process.cwd();

const getSnapshotPath = (testResult) => {
  const filePath = nodePath.relative(cwd, testResult.testFilePath);

  const input = nodePath.join(
    nodePath.dirname(filePath),
    '__snapshots__',
    `${nodePath.basename(filePath)}.snap`,
  );

  return [
    input,
    input.endsWith('.closure.js.snap')
      ? input.slice(0, -'.closure.js.snap') + '.js.snap'
      : input,
  ];
};

console.log("jestConfig", jestConfig);

const files = TEMPLATED_filePaths;

// const absoluteFiles = files.map(f => nodePath.resolve(f));

// console.log(absoluteFiles);

const argv = {
  config: jestConfig,
  watchman: false,
  runTestsByPath: true,
  env: TEMPLATED_env,
  ci: TEMPLATED_ci,
  updateSnapshot: TEMPLATED_update,
  _: files,
};

// console.log(argv);

jest
  .runCLI(
    argv,
    [cwd],
  )
  .then((result) => {
    if (result.results.numFailedTests > 0 || result.results.numFailedTestSuites > 0) {
      process.exitCode = 3;
    }

    const addedPaths = result.results.testResults
      .filter(
        (testResult) =>
          testResult.snapshot.added > 0 || testResult.snapshot.updated > 0,
      )
      .map(getSnapshotPath);
    const removedPaths = result.results.testResults
      .filter((testResult) => testResult.snapshot.fileDeleted)
      .map(getSnapshotPath);

    return Promise.all(
      addedPaths.map(([inputPath, outputPath]) => {
        const outputSnapshotPath = nodePath.resolve(outputDir, outputPath);
        return fs
          .ensureDir(nodePath.dirname(outputSnapshotPath))
          .then(() =>
            fs.copy(nodePath.resolve(cwd, inputPath), outputSnapshotPath),
          );
      }),
      fs.writeFile(
        nodePath.resolve(outputDir || "", 'summary.json'),
        JSON.stringify({
          addedPaths: addedPaths.map((value) => value[1]),
          removedPaths: removedPaths.map((value) => value[1]),
        }),
      ),
    );
  })
  .catch((error) => {
    console.error(error);
    process.exit(3);
  });

// process.exitCode = 0;
