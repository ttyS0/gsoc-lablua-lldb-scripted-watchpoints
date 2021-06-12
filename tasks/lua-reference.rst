Lua Reference
================

.. default-role:: samp

Lua is a lightweight but powerful language. At present, Lua is only serving as
an embedded interpreter in LLDB.

.. contents::
   :local:



Embedded Lua Interpreter
---------------------------

The embedded Lua interpreter can be accessed in a variety of ways from
within LLDB. The easiest way is to use the lldb command script with no
arguments at the lldb command prompt:

::

   (lldb) script
   >>> t = { 1, 2, 3 }
   >>> print(t[1])
   1
   >>> print(t[1] + t[2])
   3
   >>>

This drops you into the embedded Lua interpreter. When running under the
script command, lldb sets some convenience variables that give you quick access
to the currently selected entities that characterize the program and debugger
state. In each case, if there is no currently selected entity of the
appropriate type, the variable's IsValid method will return false. These
variables are:

+-------------------+---------------------+-------------------------------------+-------------------------------------------------------------------------------------+
| Variable          | Type                | Equivalent                          | Description                                                                         |
+-------------------+---------------------+-------------------------------------+-------------------------------------------------------------------------------------+
| `lldb.debugger`   | `lldb.SBDebugger`   | `SBTarget:GetDebugger`              | Contains the debugger object whose `script` command was invoked.                    |
|                   |                     |                                     | The `lldb.SBDebugger` object owns the command interpreter                           |
|                   |                     |                                     | and all the targets in your debug session.  There will always be a                  |
|                   |                     |                                     | Debugger in the embedded interpreter.                                               |
+-------------------+---------------------+-------------------------------------+-------------------------------------------------------------------------------------+
| `lldb.target`     | `lldb.SBTarget`     | `SBDebugger:GetSelectedTarget`      | Contains the currently selected target - for instance the one made with the         |
|                   |                     |                                     | `file` or selected by the `target select <target-index>` command.                   |
|                   |                     | `SBProcess:GetTarget`               | The `lldb.SBTarget` manages one running process, and all the executable             |
|                   |                     |                                     | and debug files for the process.                                                    |
+-------------------+---------------------+-------------------------------------+-------------------------------------------------------------------------------------+
| `lldb.process`    | `lldb.SBProcess`    | `SBTarget:GetProcess`               | Contains the process of the currently selected target.                              |
|                   |                     |                                     | The `lldb.SBProcess` object manages the threads and allows access to                |
|                   |                     | `SBThread:GetProcess`               | memory for the process.                                                             |
+-------------------+---------------------+-------------------------------------+-------------------------------------------------------------------------------------+
| `lldb.thread`     | `lldb.SBThread`     | `SBProcess:GetSelectedThread`       | Contains the currently selected thread.                                             |
|                   |                     |                                     | The `lldb.SBThread` object manages the stack frames in that thread.                 |
|                   |                     | `SBFrame:GetThread`                 | A thread is always selected in the command interpreter when a target stops.         |
|                   |                     |                                     | The `thread select <thread-index>` command can be used to change the                |
|                   |                     |                                     | currently selected thread.  So as long as you have a stopped process, there will be |
|                   |                     |                                     | some selected thread.                                                               |
+-------------------+---------------------+-------------------------------------+-------------------------------------------------------------------------------------+
| `lldb.frame`      | `lldb.SBFrame`      | `SBThread:GetSelectedFrame`         | Contains the currently selected stack frame.                                        |
|                   |                     |                                     | The `lldb.SBFrame` object manage the stack locals and the register set for          |
|                   |                     |                                     | that stack.                                                                         |
|                   |                     |                                     | A stack frame is always selected in the command interpreter when a target stops.    |
|                   |                     |                                     | The `frame select <frame-index>` command can be used to change the                  |
|                   |                     |                                     | currently selected frame.  So as long as you have a stopped process, there will     |
|                   |                     |                                     | be some selected frame.                                                             |
+-------------------+---------------------+-------------------------------------+-------------------------------------------------------------------------------------+

While extremely convenient, these variables have a couple caveats that you
should be aware of. First of all, they hold the values of the selected objects
on entry to the embedded interpreter. They do not update as you use the LLDB
API's to change, for example, the currently selected stack frame or thread.

Moreover, they are only defined and meaningful while in the interactive Lua
interpreter. There is no guarantee on their value in any other situation, hence
you should not use them when defining Lua formatters, breakpoint scripts and
commands (or any other Lua extension point that LLDB provides). For the
latter you'll be passed an `SBDebugger`, `SBTarget`, `SBProcess`, `SBThread` or
`SBframe` instance and you can use the functions from the "Equivalent" column
to navigate between them.

As a rationale for such behavior, consider that lldb can run in a multithreaded
environment, and another thread might call the "script" command, changing the
value out from under you.

To get started with these objects and LLDB scripting, please note that almost
all of the lldb Lua objects are able to briefly describe themselves when you
pass them to the Lua print function:

::

   (lldb) script
   >>> print(lldb.debugger)
   Debugger (instance: "debugger_1", id: 1)
   >>> print(lldb.target)
   a.out
   >>> print(lldb.process)
   SBProcess: pid = 3385871, state = stopped, threads = 1, executable = a.out
   >>> print(lldb.thread)
   thread #1: tid = 3385871, 0x000055555555514f a.out`main at test.c:5:3, name = 'a.out', stop reason = breakpoint 1.1
   >>> print(lldb.frame)
   frame #0: 0x000055555555514f a.out`main at test.c:5:3


Running a Lua script when a breakpoint gets hit
--------------------------------------------------

One very powerful use of the lldb Lua API is to have a Lua script run
when a breakpoint gets hit. Adding Lua scripts to breakpoints provides a way
to create complex breakpoint conditions and also allows for smart logging and
data gathering.

When your process hits a breakpoint to which you have attached some Lua
code, the code is executed as the body of a function which takes three
arguments:

::

  function breakpoint_function_wrapper(frame, bp_loc, ...):
     -- Your code goes here


+-------------------+-------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------+
| Argument          | Type                          | Description                                                                                                                               |
+-------------------+-------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------+
| `frame`           | `lldb.SBFrame`                | The current stack frame where the breakpoint got hit.                                                                                     |
|                   |                               | The object will always be valid.                                                                                                          |
|                   |                               | This `frame` argument might *not* match the currently selected stack frame found in the `lldb` module global variable `lldb.frame`.       |
+-------------------+-------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------+
| `bp_loc`          | `lldb.SBBreakpointLocation`   | The breakpoint location that just got hit. Breakpoints are represented by `lldb.SBBreakpoint`                                             |
|                   |                               | objects. These breakpoint objects can have one or more locations. These locations                                                         |
|                   |                               | are represented by `lldb.SBBreakpointLocation` objects.                                                                                   |
+-------------------+-------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------+
| `extra_args`      | `lldb.SBStructuredData`       | `Optional` If your breakpoint callback function takes this extra parameter, then when the callback gets added to a breakpoint, its        |
|                   |                               | contents can parametrize this use of the callback.  For instance, instead of writing a callback that stops when the caller is "Foo",      |
|                   |                               | you could take the function name from a field in the `extra_args`, making the callback more general.  The `-k` and `-v` options           |
|                   |                               | to `breakpoint command add` will be passed as a Dictionary in the `extra_args` parameter, or you can provide it with the SB API's.        |
+-------------------+-------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------+

Optionally, a Lua breakpoint command can return a value. Returning `false`
tells LLDB that you do not want to stop at the breakpoint. Any other return
value (including None or leaving out the return statement altogether) is akin
to telling LLDB to actually stop at the breakpoint. This can be useful in
situations where a breakpoint only needs to stop the process when certain
conditions are met, and you do not want to inspect the program state manually
at every stop and then continue.

An example will show how simple it is to write some Lua code and attach it
to a breakpoint. The following example will allow you to track the order in
which the functions in a given shared library are first executed during one run
of your program. This is a simple method to gather an order file which can be
used to optimize function placement within a binary for execution locality.

We do this by setting a regular expression breakpoint that will match every
function in the shared library. The regular expression '.' will match any
string that has at least one character in it, so we will use that. This will
result in one lldb.SBBreakpoint object that contains an
lldb.SBBreakpointLocation object for each function. As the breakpoint gets hit,
we use a counter to track the order in which the function at this particular
breakpoint location got hit. Since our code is passed the location that was
hit, we can get the name of the function from the location, disable the
location so we won't count this function again; then log some info and continue
the process.

Note we also have to initialize our counter, which we do with the simple
one-line version of the script command.

Here is the code:

::

   (lldb) breakpoint set --func-regex=. --shlib=libfoo.dylib
   Breakpoint created: 1: regex = '.', module = libfoo.dylib, locations = 223
   (lldb) script counter = 0
   (lldb) breakpoint command add -s lua 1
   Enter your Lua command(s). Type 'quit' to end.
   The commands are compiled as the body of the following Lua function
   function (frame, bp_loc, ...) end
   ..> counter = counter + 1 
   ..> name = frame:GetFunctionName() 
   ..> print(string.format('[%i] %s', counter, name)) 
   ..> bp_loc:SetEnabled(false) 
   ..> return false
   ..> quit

The breakpoint command add command above attaches a Lua script to breakpoint 1. To remove the breakpoint command:

::

   (lldb) breakpoint command delete 1

