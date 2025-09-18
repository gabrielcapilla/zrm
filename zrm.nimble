# Package

version       = "0.3.1"
author        = "Gabriel Capilla"
description   = "Easily delete files from the terminal using fzf"
license       = "MIT"
srcDir        = "src"
bin           = @["zrm"]


# Dependencies

requires "nim >= 2.2.4"

task test, "Runs the tests":
  exec "nim compile --verbosity:0 --run tests/test_zrm.nim"

task t, "Run tests":
  exec "nimble test"

task r, "Build release":
  exec "nimble run -d:release"

task b, "Build release":
  exec "nimble build -d:release"

task c, "Clean binary":
  exec "nimble clean"
