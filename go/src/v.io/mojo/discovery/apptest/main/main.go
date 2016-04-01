// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// +build mojo

package main

import (
	"flag"
	"fmt"
	"os"

	"mojo/public/go/application"
	"mojo/public/go/system"

	"v.io/mojo/discovery/apptest"
)

//#include "mojo/public/c/system/handle.h"
import "C"

func init() {
	// Add flag placeholders to suppress warnings on unhandled mojo flags.
	flag.String("child-connection-id", "", "")
	flag.String("platform-channel-handle-info", "", "")
}

type delegate struct{}

func (*delegate) Initialize(mctx application.Context) {
	os.Args = mctx.Args()
	if len(os.Args) == 0 {
		// TODO(jhahn): mojo_run doesn't pass the service url when there is
		// no flags. See https://github.com/domokit/mojo/issues/586.
		os.Args = []string{mctx.URL()}
	}
	// mojo_test checks the output for the test results since mojo_shell
	// always exits with 0.
	if apptest.RunAppTests(mctx) == 0 {
		fmt.Println("[  PASSED  ]")
	} else {
		fmt.Println("[  FAILED  ]")
	}
	mctx.Close()
}

func (*delegate) AcceptConnection(connection *application.Connection) { connection.Close() }
func (*delegate) Quit()                                               {}

//export MojoMain
func MojoMain(handle C.MojoHandle) C.MojoResult {
	application.Run(&delegate{}, system.MojoHandle(handle))
	return C.MOJO_RESULT_OK
}

func main() {}
