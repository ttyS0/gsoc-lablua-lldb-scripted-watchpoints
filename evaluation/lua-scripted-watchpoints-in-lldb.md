# Lua Scripted Watchpoints in LLDB

## Overview

[LLDB][lldb], a subproject of [LLVM][llvm], is a powerful debugger that supports
plenty of platforms. One of the featured parts in LLDB is the embedded scripting
interpreter, which supports Python at first, enabling users to use popular
scripting languages to hook some actions in LLDB (e.g. breakpoints, watchpoints)
and then manipulate LLDB. Besides, LLDB library `liblldb` is also available as a
Python library, and can be used in a standalone Python environment to gain all
access to the power of LLDB. The connection between LLDB and scripting
interpreter is Scripting Bridge API (a.k.a. SB API).

[llvm]: https://llvm.org/
[lldb]: https://lldb.llvm.org/

In this [commit][lua_first_commit], Lua was first introduced into LLDB as an
alternative language to access the embedded interpreter. Mentors of this GSoC
project, [\@Pedro Tammela][tammela] and [\@Jonas Devlieghere][JDevlieghere] have
already contributed a lot to these Lua parts in LLDB.

[lua_first_commit]: https://reviews.llvm.org/rG67de896229c0f1918f50a48973b7ce0007a181a9
[tammela]: https://reviews.llvm.org/p/tammela/
[JDevlieghere]: https://reviews.llvm.org/p/JDevlieghere/

One specific feature of the embedded scripting interpreter is called
*scripted watchpoints*. A watchpoint will monitor an expression (e.g. a variable
in the frame or a register) and break the program if the value of that
expression changes. Scripted watchpoints are just like normal watchpoints, but
with a extra callback that will be executed in the scripting interpreter.

Before this project, Lua interpreter in LLDB could not support scripted
watchpoints, because it is missing some watchpoints-related glue functions
to connect LLDB with Lua interpreter. This project was originally aimed to:

* Add support for Lua scripted watchpoints
* Improve the whole documentation for scripting in LLDB

Considering the fact that `liblldb` does not completely work in Lua, together
with the progress at the 1st evaluation in July, we decided to extend this
project and add an additional task:

* Export `liblldb` as a Lua module

## Usage

### Scripted Watchpoints

Given a C program, with the following source and compiling command line:

```c
// File: program.c
#include <stdio.h>

int main(void)
{
    int sum = 0;
    for(int i = 1; i <= 100; i++)
    {
        sum += i;
    }
    return 0;
}
```

```bash
clang -g -o a.out program.c
```

```lua
local lldb = require('lldb')

lldb.SBDebugger.Initialize()
local debugger = lldb.SBDebugger.Create()


```


## Installation

You will need to clone the [LLVM][llvm-project] project to compile LLDB.

Create a build directory anywhere you like, running the command at build root
(replace `path/to/llvm-project/llvm` to your cloned one):

```bash
cmake -G Ninja \
      -DLLVM_ENABLE_PROJECTS="clang;lldb" \
      -DLLDB_ENABLE_LUA=ON \
      path/to/llvm-project/llvm
```

This will generate building files needed for `ninja`, then call:

```bash
ninja lldb
```

and `lldb` with Lua scripting features will be built.

You can also check other building options at [Building - The LLDB Debugger][lldb-building].

[llvm-project]: https://github.com/llvm/llvm-project
[lldb-building]: https://lldb.llvm.org/resources/build.html

## My Works
### SWIG

Since most parts in LLDB are written in C++, exposing APIs to other languages
manually will be a quite complex project. [SWIG][swig] eases a lot of
difficulties in exposing C/C++ APIs to Python and Lua,

#### Typemaps

Most parts of the wrapper code for Python and Lua are generated automatically by
SWIG. But there will be some situations where additional mapping on types is
required. Here is a basic example:

If we have a C/C++ function of the prototype:

```
int read(void *buf, size_t length);
```

and it will read at most `length` bytes data to `buf`.

Since "strings" in Lua are immutable, it is necessary and more natural to have a
function "read(length)" returning a string.

However, these will not be translated automatically by SWIG, and what SWIG will
do is almost to keep all the prototype same as C/C++ ones.

SWIG provides a "typemap" mechanism and allows user to customize these typemaps,
a typemap to adapt the function with Lua will look like:


[swig]: http://www.swig.org/