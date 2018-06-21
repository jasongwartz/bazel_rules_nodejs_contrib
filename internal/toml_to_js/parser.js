/**
 * @license
 * Copyright 2018 Ecosia GmbH.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 *
 * You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const { readFile, writeFile } = require('fs');
const path = require('path');
const parseToml = require('markty-toml');
const toml = require('toml-j0.4');
const rollup = require('rollup-pluginutils');
const mkdirp = require('mkdirp');
const program = require('commander');

program
  .version('1.0.0')
  .usage('[options] <files...>')
  .option('-o, --out-dir <value>', 'Output directory for created files')
  .option('-s, --strict', 'If provided will use strict parsing')
  .parse(process.argv);

const outDir = program['outDir'] || '';

for (let i = 0; i < program.args.length; i += 1) {
    const input = program.args[i];
    const output = path.join(outDir, `${input.slice(0, -4)}js`);
    readFile(input, 'utf-8', (err, data) => {
        if (err) {
            return console.error(err);
        }
        // markty-toml is faster than toml-j0.4 but does not fully adhere to the toml standard
        // e.g. it ignores comments
        const parsed = program.strict ? toml.parse(data) : parseToml(data);
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
