---
title: Lua scripted watchpoints in LLDB - GSoC 2021
---

# Overview

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
in the frame, a register or essentially a piece of memory) and break the program
if the value of that expression changes. Scripted watchpoints are just like
normal watchpoints, but with a extra callback that will be executed in the
scripting interpreter.

Before this project, Lua interpreter in LLDB could not support scripted
watchpoints, because it is missing some watchpoints-related glue functions
to connect LLDB with Lua interpreter. This project was originally aimed to:

* Add support for Lua scripted watchpoints
* Improve the whole documentation for scripting in LLDB

Considering the fact that `liblldb` does not completely work in Lua, together
with the progress at the 1st evaluation in July, we decided to extend this
project and add an additional task:

* Export `liblldb` as a Lua module

# Usage

## Hit Count of a Line for Statistics

Given an easy C program that calculates $\sum_{i=1}^{100} i$, with the following
source

```{.c .numberLines}
// File: sum.c
#include <stdio.h>

int main(void)
{
    // `volatile` to prevent compiler optimizations
    volatile int sum = 0;

    for(int i = 1; i <= 100; i++)
    {
        sum += i;
    }
    return 0;
}
```

and its compiling command line

```bash
clang -g -o sum sum.c
```

Though the program is very easy, it is enough to show the power of LLDB module.

It is quite obvious that line 11 `sum += i;` will be executed 100 times. However,
this fact can also be validated by a record-only breakpoint through scripting:

```{.lua .numberLines}
local lldb = require('lldb')

lldb.SBDebugger.Initialize()
local debugger = lldb.SBDebugger.Create()
debugger:SetAsync(false)

local target = debugger:CreateTarget('sum')

-- set a breakpoint at `sum += i`
local bp = target:BreakpointCreateByLocation('sum.c', 11)
-- to prevent the breakpoint from breaking our program
-- but each hit of the breakpoint will be recorded
bp:SetAutoContinue(true)

local process = target:LaunchSimple(nil, nil, nil)

-- it should be 100
print(bp:GetHitCount())
```

## Dump Data Structures at Runtime without Touching Sources

Here is a simple program using linked list.

```{.c .numberLines}
// File: list.c
#include <stdio.h>

struct list_node
{
    int value;
    struct list_node *next;
};

int main(void)
{
    struct list_node p, q, r;
    struct list_node *head = &p;
    p.value = 10;
    p.next = &q;
    q.value = 100;
    q.next = &r;
    r.value = 1000;
    r.next = NULL;
    return 0;
}
```

It is possible to dump the data structure without adding dump code to source.

```{.lua .numberLines}
local lldb = require('lldb')

lldb.SBDebugger.Initialize()
local debugger = lldb.SBDebugger.Create()
debugger:SetAsync(false)

local target = debugger:CreateTarget('list')

-- set a breakpoint at `return 0`
local bp = target:BreakpointCreateByLocation('list.c', 20)

local process = target:LaunchSimple(nil, nil, nil)

-- the program should be stopped because it hits `return 0` bp
-- find the thread that is stopped by breakpoint
local bp_thread

for i = 0, process:GetNumThreads() - 1 do
    local t = process:GetThreadAtIndex(i)
    print(t)
    if t:IsValid() and t:GetStopReason() == lldb.eStopReasonBreakpoint then
        bp_thread = t
        break
    end
end

local frame = bp_thread:GetFrameAtIndex(0)

local head = frame:FindVariable('head')

local node = head

while node:IsValid() and node:GetValue() do
    local value = node:GetChildMemberWithName('value')
    print(value:GetValue())
    node = node:GetChildMemberWithName('next')
end
```

Its output will look like:

```
> lua5.3 b.lua
thread #1: tid = 2384702, 0x0000000000401150 list`main at list.c:20:5, name = 'list', stop reason = breakpoint 1.1
10
100
1000
nil
```

And the linked list was dumped at runtime by the help of LLDB module.

## Find Bugs - A More Complicated Example with Embedded Scripting Interpreter

The [example][lldb-binary-search-tree-example] used by LLDB documentation is a good
one to demonstrate how the scripting interpreter can assist debugging. It takes
a buggy binary search tree program and uses embedded scripting interpreter to
locate where the bugs lie.

[lldb-binary-search-tree-example]: https://gsoc2021.sigeryeung.tk/lldb-docs/use/scripting-example.html

# Installation

You will need to clone the [LLVM][llvm-project] project to compile LLDB.

Create a build directory anywhere you like, running the command at build root to
configure the project (replace `path/to/llvm-project/llvm` with your cloned one):

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

To install `liblldb` as a Lua library, you will need to run

```
ninja install
```

at build root either with `root` user or set a fake prefix when configuring.

# Final Code List

Some codes or drafts of this project could be found at [GitHub][siger-repo].

There are 4 pull requests in total.

* [[lldb][docs] Add reference docs for Lua scripting][docs-pr]
* [[lldb/lua] Add scripted watchpoints for Lua][watchpoints-pr]
* [[lldb/lua] Supplement Lua bindings for lldb module][module-pr]
* [[lldb/lua] Force Lua version to be 5.3][lock-version-pr]

The improved documentation can be previewed [here][preview-docs].

[siger-repo]: https://github.com/siger-yeung/gsoc-lablua-lldb-scripted-watchpoints
[docs-pr]: https://reviews.llvm.org/D104281
[watchpoints-pr]: https://reviews.llvm.org/D105034
[module-pr]: https://reviews.llvm.org/D108090
[lock-version-pr]: https://reviews.llvm.org/D108515
[preview-docs]: https://gsoc2021.sigeryeung.tk/lldb-docs/

# A Closer Look at My Works

## Improved Documentation

This project adds a plugin `sphinx_tabs` to LLDB documentation system to support
an integrated view for both Lua and Python codes.

```python
extensions = ['sphinx.ext.todo', 'sphinx.ext.mathjax', 'sphinx.ext.intersphinx', 'sphinx_tabs.tabs']
```

At the same time, many codes just for Python have been rewritten to Lua, together
with some updates on descriptive texts of the documentation.

## SWIG & Typemaps

Since most parts in LLDB are written in C++, exposing APIs to other languages
manually will be a quite complex project. [SWIG][swig] eases a lot of
difficulties in exposing C/C++ APIs to Python and Lua.

[swig]: http://www.swig.org/

The wrapper code for Python and Lua are generated automatically by SWIG. But
there will be situations where additional mapping on types is required. Here is
a basic example:

If we have a C/C++ function of the prototype:

```
size_t read(void *buf, size_t length);
```

and it will read at most `length` bytes data to `buf`, and return how many bytes
are successfully read.

But Lua and Python have no direct "pointers" type, and "strings" in both Lua and
Python are immutable, it is necessary and more natural to have a function of the
form "read(length)" returning a string to work.

However, these will not be translated automatically by SWIG, and what SWIG will
do is almost to keep all the prototype same as C/C++ ones.

Fortunately, SWIG provides a "typemap" mechanism to allow users to customize
these typemaps, a typemap to adapt the function with Lua will look like:

```
%typemap(in) (void *buf, size_t length) {
   $2 = luaL_checkinteger(L, $input);
   if ($2 <= 0) {
      return luaL_error(L, "Positive integer expected");
   }
   $1 = (char *) malloc($2);
}

%typemap(argout) (void *buf, size_t length) {
   lua_pop(L, 1); // Blow away the previous result
   if ($result == 0) {
      lua_pushliteral(L, "");
   } else {
      lua_pushlstring(L, (const char *)$1, $result);
   }
   free($1);
}
```

These typemaps are **critical** to the extended GSoC project -- exporting `liblldb`
as a Lua module.
