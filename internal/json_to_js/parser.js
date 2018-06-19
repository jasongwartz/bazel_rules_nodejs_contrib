const { readFile, writeFile } = require('fs');
const path = require('path');
const rollup = require('rollup-pluginutils');
const mkdirp = require('mkdirp');
const argv = require('minimist')(process.argv.slice(2));

const outDir = argv['out-dir'] || '';

for (let i = 0; i < argv._.length; i += 1) {
    const input = argv._[i];
    const output = path.join(outDir, `${input.slice(0, -4)}js`);
    readFile(input, 'utf-8', (err, data) => {
        if (err) {
            return console.error(err);
        }
        const parsed = JSON.parse(data);
        const esm = rollup.dataToEsm(parsed);

        if (outDir) {
            mkdirp.sync(outDir);
        }

        return writeFile(output, esm, (err2) => {
            if (err2) {
                console.error(err2);
            }
        });
    });
}
