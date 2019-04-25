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
		"import": importSubexpIndex,
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
		want             FileInfo
	}{
		{
			desc: "empty",
			name: "empty^file.js",
			js: "",
			want: FileInfo{},
		}, {
			desc: "import single quote",
			name: "single.js",
			js: `import dateFns from 'date-fns';`,
			want: FileInfo{
				Imports: []string{"date-fns"},
			},
		}, {
			desc: "import double quote",
			name: "double.sass",
			js: `import dateFns from "date-fns";`,
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
			js: `import package from "from/internal/package";`,
			want: FileInfo{
				Imports: []string{"from/internal/package"},
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
