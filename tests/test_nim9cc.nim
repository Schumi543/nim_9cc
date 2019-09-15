import unittest
import os

test "run make test":
    let exit_code = os.execShellCmd("make && make test && make clean")
    check exit_code == 0
