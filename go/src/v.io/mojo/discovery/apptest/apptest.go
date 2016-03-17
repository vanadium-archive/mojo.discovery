// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// +build mojo

package apptest

import (
	"reflect"
	"regexp"
	"runtime"
	"strings"
	"testing"

	"mojo/public/go/application"
)

func RunAppTests(mctx application.Context) int {
	apptests := []func(*testing.T, application.Context){
		AppTestBasic,
	}

	var tests []testing.InternalTest
	for _, apptest := range apptests {
		qname := runtime.FuncForPC(reflect.ValueOf(apptest).Pointer()).Name()
		name := qname[strings.LastIndex(qname, ".")+1:]
		tests = append(tests, testing.InternalTest{name, func(t *testing.T) { apptest(t, mctx) }})
	}

	// MainStart is not supposed to be called directly, but there is no other way
	// to run tests programatically at run time.
	return testing.MainStart(regexp.MatchString, tests, nil, nil).Run()
}
