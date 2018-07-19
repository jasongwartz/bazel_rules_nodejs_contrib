package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
	// "path/filepath"
	// "strings"
)

var (
	port        = flag.Int("port", 8080, "server port to listen on")
	base        = flag.String("base", "", "server base (required, runfiles of the binary)")
	pkgs        = flag.String("packages", "", "root package(s) to serve, comma-separated")
	servingPath = flag.String("serving_path", "/_/ts_scripts.js", "path to serve the combined sources at")
	entryPoint  = flag.String("entry_point", "", "entry point path")
)

func main() {
	flag.Parse()

	if *base == "" || len(*pkgs) == 0 {
		fmt.Fprintf(os.Stderr, "Required argument not set\n")
		os.Exit(1)
	}

	if _, err := os.Stat(*base); err != nil {
		fmt.Fprintf(os.Stderr, "Cannot read server base %s: %v\n", *base, err)
		os.Exit(1)
	}

	// scriptsManifestPath := filepath.Join(*base, *entryPoint)
	// scriptFiles, err := manifestFiles(scriptsManifestPath)
	// if err != nil {
	// 	fmt.Fprintf(os.Stderr, "Failed to read scripts_manifest: %v\n", err)
	// 	os.Exit(1)
	// }

	preScripts := ""

	// Include the livereload script if IBAZEL_LIVERELOAD_URL is set.
	livereloadUrl := os.Getenv("IBAZEL_LIVERELOAD_URL")
	if livereloadUrl != "" {
		fmt.Printf("Serving livereload script from %s\n", livereloadUrl)
		livereloadLoaderSnippet := fmt.Sprintf(`(function(){
	const script = document.createElement('script');
	script.src = "%s";
	document.head.appendChild(script);
})();`, livereloadUrl)
		preScripts += livereloadLoaderSnippet
	}

	// Include the profiler script if IBAZEL_PROFILER_URL is set.
	profilerScriptURL := os.Getenv("IBAZEL_PROFILER_URL")
	if profilerScriptURL != "" {
		fmt.Printf("Serving profiler script from %s\n", profilerScriptURL)
		profilerLoaderSnippet := fmt.Sprintf(`(function(){
	const script = document.createElement('script');
	script.src = "%s";
	document.head.appendChild(script);
})();`, profilerScriptURL)
		preScripts += profilerLoaderSnippet
	}

	// TODO: Serve preMain script as a separate script
	preMain := []byte(preScripts)

	// Include all user scripts in preScripts. This should always include
	// the requirejs script which is added to scriptFiles by the devserver
	// skylark rule.
	// for _, v := range scriptFiles {
	// 	js, err := loadScript(filepath.Join(*base, v))
	// 	if err != nil {
	// 		fmt.Fprintf(os.Stderr, "Failed to read script %s: %v\n", v, err)
	// 	} else {
	// 		preScripts = append(preScripts, js)
	// 	}
	// }

	http.HandleFunc(*servingPath, func(w http.ResponseWriter, r *http.Request) {
		main, err := ioutil.ReadFile(*entryPoint)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Failed to read script %s: %v\n", *entryPoint, err)
		}
		w.Header().Add("Content-Type", "application/javascript")
		w.Write(append(preMain[:], main[:]...))
	})
	pkgList := strings.Split(*pkgs, ",")
	http.HandleFunc("/", CreateFileHandler(*servingPath, pkgList, *base))

	h, err := os.Hostname()
	if err != nil {
		h = "localhost"
	}

	fmt.Printf("Server listening on http://%s:%d/\n", h, *port)
	fmt.Fprintln(os.Stderr, http.ListenAndServe(fmt.Sprintf(":%d", *port), nil).Error())
	os.Exit(1)
}

func loadScript(path string) (string, error) {
	buf, err := ioutil.ReadFile(path)
	if err != nil {
		return "", err
	}
	return string(buf), nil
}

// manifestFiles parses a manifest, returning a list of the files in the manifest.
func manifestFiles(manifest string) ([]string, error) {
	f, err := os.Open(manifest)
	if err != nil {
		return nil, fmt.Errorf("could not read manifest %s: %s", manifest, err)
	}
	defer f.Close()
	return manifestFilesFromReader(f)
}

// manifestFilesFromReader is a helper for manifestFiles, split out for testing.
func manifestFilesFromReader(r io.Reader) ([]string, error) {
	var lines []string
	s := bufio.NewScanner(r)
	for s.Scan() {
		path := s.Text()
		if path == "" {
			continue
		}
		lines = append(lines, path)
	}
	if err := s.Err(); err != nil {
		return nil, err
	}

	return lines, nil
}
