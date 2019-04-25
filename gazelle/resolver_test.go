package gazelle

import (
	"testing"

	"github.com/bazelbuild/bazel-gazelle/label"
	"github.com/bazelbuild/bazel-gazelle/resolve"
)

const (
	pkgDir = "my/app/src"
)
func TestNormalisePath(t *testing.T) {
	for _, tc := range []struct {
		desc, path, want string
	}{
		{
			desc: "@ alias path",
			path: "@/" + pkgDir + "path/to",
			want: pkgDir + "path/to",
		},
		{
			desc: "~~ alias path",
			path: "~~/" + pkgDir + "/path/to",
			want: pkgDir + "/path/to",
		},
		{
			desc: "relative path, same dir",
			path: "./file",
			want: pkgDir + "/file",
		},
		{
			desc: "relative path, different dir",
			path: "../../app2/file",
			want: "my/app2/file",
		},
	} {
		t.Run(tc.desc, func(t *testing.T) {
			got := normaliseImports(tc.path, &resolve.RuleIndex{}, label.New("repo", pkgDir, "name"))

			if got != tc.want {
				t.Errorf("Inequalith.\ngot  %#v;\nwant %#v", got, tc.want)
			}
		})
	}
}