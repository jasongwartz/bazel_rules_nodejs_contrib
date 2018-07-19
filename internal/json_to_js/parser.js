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
const rollup = require('rollup-pluginutils');
const mkdirp = require('mkdirp');
const argv = require('minimist')(process.argv.slice(2));

const outDir = argv['out-dir'] || '';

for (let i = 0; i < argv._.length; i += 1) {
    const input = argv._[i];
    const output = path.join(outDir, `${input}.js`);
    readFile(input, 'utf-8', (err, data) => {
        if (err) {
            return console.error(err);
        }
        const parsed = JSON.parse(data);
        const esm = rollup.dataToEsm(parsed);
        mkdirp.sync(path.dirname(output));

        return writeFile(output, esm, (err2) => {
            if (err2) {
                console.error(err2);
            }
        });
    });
}
