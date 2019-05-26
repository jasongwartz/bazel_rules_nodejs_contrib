package gazelle

import (
	"strings"
)

type libraryFlag struct {
	library *Library
}

func (f *libraryFlag) Set(value string) error {
	if library, err := LibraryFromString(value); err != nil {
		return err
	} else {
		*f.library = library
		return nil
	}
}

func (f *libraryFlag) String() string {
	var lib Library
	if f != nil && f.library != nil {
		lib = *f.library
	}
	return lib.String()
}

type stringArrayFlag struct {
	arr *[]string
}

func (i *stringArrayFlag) String() string {
	return strings.Join(*i.arr, ",")
}

func (i *stringArrayFlag) Set(value string) error {
	*i.arr = strings.Split(value, ",")
	return nil
}
