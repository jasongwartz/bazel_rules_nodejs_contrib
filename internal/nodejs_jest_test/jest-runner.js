const jest = require('jest-cli');
const fs = require('fs-extra');
const nodePath = require('path');

const outputDir = process.env.TEST_UNDECLARED_OUTPUTS_DIR;
// console.log("outputDir", outputDir);
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

jest
  .runCLI(
    {
      config: '{}',
      watchman: false,
      runTestsByPath: true,
      env: TEMPLATED_env,
      ci: TEMPLATED_ci,
      updateSnapshot: TEMPLATED_update,
      _: TEMPLATED_filePaths,
    },
    [cwd],
  )
  .then((result) => {
    if (result.results.numFailedTests > 0) {
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
        nodePath.resolve(outputDir, 'summary.json'),
        JSON.stringify({
          addedPaths: addedPaths.map((value) => value[1]),
          removedPaths: removedPaths.map((value) => value[1]),
        }),
      ),
    );
  })
  .catch((error) => {
    console.error(error);
    process.exitCode = 3;
  });
