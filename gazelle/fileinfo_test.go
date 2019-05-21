/* Copyright 2018 The Bazel Authors. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package gazelle

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"reflect"
	"testing"
)

func TestJsRegexpGroupNames(t *testing.T) {
	names := jsRe.SubexpNames()
	nameMap := map[string]int{
		"import":  importSubexpIndex,
		"require": requireSubexpIndex,
	}
	for name, index := range nameMap {
		if names[index] != name {
			t.Errorf("js regexp subexp %d is %s ; want %s", index, names[index], name)
		}
	}
	if len(names)-1 != len(nameMap) {
		t.Errorf("js regexp has %d groups ; want %d", len(names), len(nameMap))
	}
}

func TestJsFileInfo(t *testing.T) {
	for _, tc := range []struct {
		desc, name, js string
		want           FileInfo
	}{
		{
			desc: "empty",
			name: "empty^file.js",
			js:   "",
			want: FileInfo{},
		}, {
			desc: "import single quote",
			name: "single.js",
			js:   `import dateFns from 'date-fns';`,
			want: FileInfo{
				Imports: []string{"date-fns"},
			},
		}, {
			desc: "import double quote",
			name: "double.sass",
			js:   `import dateFns from "date-fns";`,
			want: FileInfo{
				Imports: []string{"date-fns"},
			},
		}, {
			desc: "import two",
			name: "two.sass",
			js: `import {format} from 'date-fns'
import Puppy from '@/components/Puppy';`,
			want: FileInfo{
				Imports: []string{"@/components/puppy", "date-fns"},
			},
		}, {
			desc: "import depth",
			name: "deep.sass",
			js:   `import package from "from/internal/package";`,
			want: FileInfo{
				Imports: []string{"from/internal/package"},
			},
		}, {
			desc: "import multiline",
			name: "multiline.js",
			js: `import {format} from 'date-fns'
import {
	CONST1,
	CONST2,
	CONST3,
} from '~/constants';`,
			want: FileInfo{
				Imports: []string{"date-fns", "~/constants"},
			},
		},
		{
			desc: "simple require",
			name: "require.js",
			js:   `const a = require("date-fns");`,
			want: FileInfo{
				Imports: []string{"date-fns"},
			},
		},
		{
			desc: "ignores incorrect imports",
			name: "incorrect.js",
			js:   `@import "~mapbox.js/dist/mapbox.css";`,
			want: FileInfo{
				Imports: []string(nil),
			},
		},
		{
			desc: "ignores commented out imports",
			name: "comment.js",
			js: `
    // takes ?inline out of the aliased import path, only if it's set
    // e.g. ~/path/to/file.svg?inline -> ~/path/to/file.svg
    '^~/(.+\\.svg)(\\?inline)?$': '<rootDir>$1',
// const a = require("date-fns");
// import {format} from 'date-fns';
`,
			want: FileInfo{
				Imports: []string(nil),
			},
		},
		{
			desc: "full import",
			name: "comment.js",
			js: `import "mypolyfill";
import "mypolyfill2";`,
			want: FileInfo{
				Imports: []string{"mypolyfill", "mypolyfill2"},
			},
		},
		{
			desc: "full require",
			name: "full_require.js",
			js:   `require("mypolyfill2");`,
			want: FileInfo{
				Imports: []string{"mypolyfill2"},
			},
		},
		{
			desc: "imports and full imports",
			name: "mixed_imports.js",
			js: `import Vuex, { Store } from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';

import '~/plugins/intersection-observer-polyfill';
import '~/plugins/intersect-directive';
import ClaimsSection from './claims-section';
`,
			want: FileInfo{
				Imports: []string{"./claims-section", "@vue/test-utils", "vuex", "~/plugins/intersect-directive", "~/plugins/intersection-observer-polyfill"},
			},
		},
		{
			desc: "dynamic require",
			name: "dynamic_require.js",
			js: `
if (process.ENV.SHOULD_IMPORT) {
    // const old = require('oldmapbox.js');
    const leaflet = require('mapbox.js');
}
`,
			want: FileInfo{
				Imports: []string{"mapbox.js"},
			},
		},
	} {
		t.Run(tc.desc, func(t *testing.T) {
			dir, err := ioutil.TempDir(os.Getenv("TEST_TEMPDIR"), "TestProtoFileinfo")
			if err != nil {
				t.Fatal(err)
			}
			defer os.RemoveAll(dir)
			if err := ioutil.WriteFile(filepath.Join(dir, tc.name), []byte(tc.js), 0600); err != nil {
				t.Fatal(err)
			}

			got := jsFileinfo(dir, tc.name)

			// Reexpose the fields we care bout for testing.
			got = FileInfo{
				Imports: got.Imports,
			}
			if !reflect.DeepEqual(got, tc.want) {
				t.Errorf("Inequalith.\ngot  %#v;\nwant %#v", got, tc.want)
			}
		})
	}
}
