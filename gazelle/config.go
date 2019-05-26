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
	"flag"
	"fmt"
	"log"

	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/rule"
)

// JsConfig contains configuration values related to js/tsſ.
//
// This type is public because other languages need to generate rules based
// on JS, so this configuration may be relevant to them.
type JsConfig struct {
	// NpmWorkspaceName defines the of the workspace name where yarn/npm installs its packages to.
	// Defaults to npm
	NpmWorkspaceName string

	// JsLibrary defines which library rule to use for js generation, either js_library or
	// babel_library
	JsLibrary Library

	// JsImportExtenstions defines for which extensions to generate the js_import rule. An empty string disables it.
	JsImportExtenstions []string

	// AliasImportSupport defines enables/disbles alias import support
	// TODO: We want this probably more configurable once it is not hardcode anymore.
	AliasImportSupport bool

	// GenerateTests decides if jest_node_test rules will be generated or not.
	GenerateTests bool
}

// GetJsConfig returns the js language configuration. If the js
// extension was not run, it will return nil.
func GetJsConfig(c *config.Config) *JsConfig {
	js := c.Exts[extName]
	if js == nil {
		return nil
	}
	return js.(*JsConfig)
}

type Library int

const (
	// JsLibrary is the default library rule and simply supports loading of transitive deps.
	JsLibrary Library = iota
	// BabelLibrary brings support for babel
	BabelLibrary
)

// LibraryFromString turns the string into the corresponding const
func LibraryFromString(s string) (Library, error) {
	switch s {
	case "js_library":
		return JsLibrary, nil
	case "babel_library":
		return BabelLibrary, nil
	default:
		return 0, fmt.Errorf("unrecognized library rule: %q", s)
	}
}

func (lib Library) String() string {
	switch lib {
	case JsLibrary:
		return "js_library"
	case BabelLibrary:
		return "babel_library"
	default:
		log.Panicf("unknown library rule %d", lib)
		return ""
	}
}

// RegisterFlags registers command-line flags used by the extension. This
// method is called once with the root configuration when Gazelle
// starts. RegisterFlags may set an initial values in Config.Exts. When flags
// are set, they should modify these values.
func (s *jslang) RegisterFlags(fs *flag.FlagSet, cmd string, c *config.Config) {
	js := &JsConfig{}
	c.Exts[extName] = js

	fs.Var(&libraryFlag{&js.JsLibrary}, "js_library", "js_library: Uses js_library\n\tbabel_library: Uses babel_library")
	fs.Var(&stringArrayFlag{&js.JsImportExtenstions}, "js_import_extensions", "A comma separated list of file extensions that js_import will be generated for. Defaults to no generation.")
	fs.StringVar(&js.NpmWorkspaceName, "npm_workspace_name", "npm", "option to change the name of the external workspace where npm/yarn is installing its packages to")
	fs.BoolVar(&js.AliasImportSupport, "alias_import_support", false, "Enables or disables alias import support, such as imports starting with ~, etc.")
	fs.BoolVar(&js.GenerateTests, "generate_js_tests", false, "Enables or disables generation of jest_node_test rules for .test.js files.")
}

// CheckFlags validates the configuration after command line flags are parsed.
// This is called once with the root configuration when Gazelle starts.
// CheckFlags may set default values in flags or make implied changes.
func (s *jslang) CheckFlags(fs *flag.FlagSet, c *config.Config) error {
	return nil
}

// KnownDirectives returns a list of directive keys that this Configurer can
// interpret. Gazelle prints errors for directives that are not recoginized by
// any Configurer.
func (s *jslang) KnownDirectives() []string {
	return []string{"js_library", "babel_library"}
}

// Configure modifies the configuration using directives and other information
// extracted from a build file. Configure is called in each directory.
//
// c is the configuration for the current directory. It starts out as a copy
// of the configuration for the parent directory.
//
// rel is the slash-separated relative path from the repository root to
// the current directory. It is "" for the root directory itself.
//
// f is the build file for the current directory or nil if there is no
// existing build file.
func (s *jslang) Configure(c *config.Config, rel string, f *rule.File) {
}
