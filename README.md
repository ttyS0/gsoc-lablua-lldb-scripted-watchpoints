# gsoc-lablua-lldb-scripted-watchpoints

Tracks, thoughts and materials for GSoC 2021 LabLua - Lua Scripted Watchpoints in LLDB

## Tasks

* Improve the whole scripting docs in LLDB.
  - [Draft](./drafts/lua-docs-draft.md)
  - ~~[Docs for "Lua Reference"](./tasks/lua-reference.rst)~~
  - [Integrated section for scripting docs](https://gsoc2021.sigeryeung.tk/lldb-docs)
* Scripted watchpoints support for Lua.
  - [Draft](./drafts/lua-scripted-watchpoints.md)
  - [Latest diff](./tasks/patch.diff)
* Using LLDB module in Lua
  - [Typemaps](./tasks/lldb-module/lua-typemaps.swig)

Revisions:
  - [[lldb][docs] Add reference docs for Lua scripting](https://reviews.llvm.org/D104281)
  - [[lldb/lua] Add scripted watchpoints for Lua](https://reviews.llvm.org/D105034)
  - [[lldb/lua] Supplement typemaps for Lua](https://reviews.llvm.org/D108090)