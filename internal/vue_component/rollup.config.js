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

// This is maybe a bit of a hack but we are using rollup as a vue "compiler" rather than as a
// bundler, by telling it to ignore all externals (i.e. imports). This is much easier than writing
// a custom vue compiler ourselves.
import path from 'path';
import VuePlugin from 'rollup-plugin-vue';

const input = 'TMPL_src_name';
export default {
    plugins: [
        VuePlugin(),
    ],
    treeshake: false,
    output: {
        // TODO: Figure out if we could need format es here
        format: 'cjs',
        strict: false,
        interop: true
    },
    external: (id) => {
        const ext = (id !== input) && (!id.includes(`${path.basename(input)}?rollup-plugin-vue=script.js`));
        return ext;
    }
};
