# Package

version       = "0.3.0"
author        = "Gabriel Capilla"
description   = "Easily delete files from the terminal using fzf"
license       = "MIT"
srcDir        = "src"
bin           = @["zrm"]


# Dependencies

requires "nim >= 2.0.8"

task test, "Runs the tests":
  exec "nim compile --verbosity:0 --run tests/test_zrm.nim"
