# Scripted watchpoints

## TO-DO

- I/O related
    - [ ] `ScriptInterpreterLua::IOHandlerActivated`
    - [ ] `ScriptInterpreterLua::IOHandlerInputComplete`

- Core - Interpreter
    - [ ] `ScriptInterpreterLua::GenerateWatchpointCommandCallbackData`
    - [ ] `ScriptInterpreterLua::CollectDataForWatchpointCommandCallback`
    - [ ] `ScriptInterpreterLua::SetWatchpointCommandCallback`

- Core - Lua
    - [ ] `Lua::RegisterWatchpointCallback`
    - [ ] `Lua::CallWatchpointCallback`

- SWIG
    - [ ] `LLDBSwigLuaWatchpointCallbackFunction`

## A simple sample in Python

### Some codes and commands

```c
#include <stdio.h>

int main()
{
    int counter = 0;
    while(counter < 1000)
    {
        counter++;
    }
    return 0;
}
```

```
script counter_10 = 0
breakpoint set --name main
run
watchpoint set variable counter
watchpoint modify -c "(counter%10==0)"
watchpoint command add -s python
```

```python
global counter_10
print("[%i] counter mod 10==0" % counter_10)
counter_10 += 1
frame.GetThread().GetProcess().Continue()
```

### Output

```
(lldb) target create "./counter"
Current executable set to '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter' (x86_64).
(lldb) script counter_10 = 0
(lldb) breakpoint set --name main
Breakpoint 1: where = counter`main + 11 at counter.c:5:9, address = 0x000000000000112b
(lldb) run
Process 1799208 launched: '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter' (x86_64)
Process 1799208 stopped
* thread #1, name = 'counter', stop reason = breakpoint 1.1
    frame #0: 0x000055555555512b counter`main at counter.c:5:9
   2   
   3    int main()
   4    {
-> 5        int counter = 0;
   6        while(counter < 1000)
   7        {
   8            counter++;
(lldb) watchpoint set variable counter
Watchpoint created: Watchpoint 1: addr = 0x7fffffffe488 size = 4 state = enabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0

### Some codes and commands

```c
#include <stdio.h>

int main()
{
    int counter = 0;
    while(counter < 1000)
    {
        counter++;
    }
    return 0;
}
```

```
script counter_10 = 0
breakpoint set --name main
run
watchpoint set variable counter
watchpoint modify -c "(counter%10==0)"
watchpoint command add -s python
```

```python
global counter_10
print("[%i] counter mod 10==0" % counter_10)
counter_10 += 1
frame.GetThread().GetProcess().Continue()
[1] counter mod 10==0
[2] counter mod 10==0
[3] counter mod 10==0
[4] counter mod 10==0
[5] counter mod 10==0
[6] counter mod 10==0
[7] counter mod 10==0
[8] counter mod 10==0
[9] counter mod 10==0
[10] counter mod 10==0
[11] counter mod 10==0
[12] counter mod 10==0
[13] counter mod 10==0
[14] counter mod 10==0
[15] counter mod 10==0
[16] counter mod 10==0
[17] counter mod 10==0
[18] counter mod 10==0
[19] counter mod 10==0
[20] counter mod 10==0
[21] counter mod 10==0
[22] counter mod 10==0
[23] counter mod 10==0
[24] counter mod 10==0
[25] counter mod 10==0
[26] counter mod 10==0
[27] counter mod 10==0
[28] counter mod 10==0
[29] counter mod 10==0
[30] counter mod 10==0
[31] counter mod 10==0
[32] counter mod 10==0
[33] counter mod 10==0
[34] counter mod 10==0
[35] counter mod 10==0
[36] counter mod 10==0
[37] counter mod 10==0
[38] counter mod 10==0
[39] counter mod 10==0
[40] counter mod 10==0
[41] counter mod 10==0
[42] counter mod 10==0
[43] counter mod 10==0
[44] counter mod 10==0
[45] counter mod 10==0
[46] counter mod 10==0
[47] counter mod 10==0
[48] counter mod 10==0
[49] counter mod 10==0
[50] counter mod 10==0
[51] counter mod 10==0
[52] counter mod 10==0
[53] counter mod 10==0
[54] counter mod 10==0
[55] counter mod 10==0
[56] counter mod 10==0
[57] counter mod 10==0
[58] counter mod 10==0
[59] counter mod 10==0
[60] counter mod 10==0
[61] counter mod 10==0
[62] counter mod 10==0
[63] counter mod 10==0
[64] counter mod 10==0
[65] counter mod 10==0
[66] counter mod 10==0
[67] counter mod 10==0
[68] counter mod 10==0
[69] counter mod 10==0
[70] counter mod 10==0
[71] counter mod 10==0
[72] counter mod 10==0
[73] counter mod 10==0
[74] counter mod 10==0
[75] counter mod 10==0
[76] counter mod 10==0
[77] counter mod 10==0
[78] counter mod 10==0
[79] counter mod 10==0
[80] counter mod 10==0
[81] counter mod 10==0
[82] counter mod 10==0
[83] counter mod 10==0
[84] counter mod 10==0
[85] counter mod 10==0
[86] counter mod 10==0
[87] counter mod 10==0
[88] counter mod 10==0
[89] counter mod 10==0
[90] counter mod 10==0
[91] counter mod 10==0
[92] counter mod 10==0
[93] counter mod 10==0
[94] counter mod 10==0
[95] counter mod 10==0
[96] counter mod 10==0
[97] counter mod 10==0
[98] counter mod 10==0
[99] counter mod 10==0
[100] counter mod 10==0
Stopped due to an error evaluating condition of watchpoint Watchpoint 1: addr = 0x7fffffffe488 size = 4 state = disabled type = w: "(counter%10==0)"
error: <user expression 1001>:1:2: use of undeclared identifier 'counter'
(counter%10==0)
 ^

[101] counter mod 10==0
Process 1799208 exited with status = 0 (0x00000000)
```

## Lua

### Some codes and commands

```c
#include <stdio.h>

int main()
{
    int counter = 0;
    while(counter < 1000)
    {
        counter++;
    }
    return 0;
}
```

```
script counter_10 = 0
breakpoint set --name main
run
watchpoint set variable counter
watchpoint modify -c "(counter%10==0)"
watchpoint command add -s lua
```

```lua
print(frame, wp)
print(string.format("[%i] counter mod 10==0", counter_10))
counter_10 = counter_10 + 1
frame:GetThread():GetProcess():Continue()
```

### Output

```
Welcome to fish, the friendly interactive shell
Type `help` for instructions on how to use fish
siger@vostro ~/D/P/g/test> gsoc-lldb --script-language lua ./counter
(lldb) target create "./counter"
Current executable set to '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter' (x86_64).
(lldb) script counter_10 = 0
(lldb) breakpoint set --name main
Breakpoint 1: where = counter`main + 11 at counter.c:5:9, address = 0x000000000000112b
(lldb) r
Process 78064 launched: '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter' (x86_64)
Process 78064 stopped
* thread #1, name = 'counter', stop reason = breakpoint 1.1
    frame #0: 0x000055555555512b counter`main at counter.c:5:9
   2
   3    int main()
   4    {
-> 5        int counter = 0;
   6        while(counter < 1000)
   7        {
   8            counter++;
(lldb) watchpoint set variable counter
Watchpoint created: Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = enabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
(lldb) watchpoint modify -c "(counter%10==0)"
(lldb) watchpoint command add -s lua
Enter your Lua command(s). Type 'quit' to end.
The commands are compiled as the body of the following Lua function
function (frame, wp, ...) end
..> print(frame, wp)
..>
..> print(string.format("[%i] counter mod 10==0", counter_10))
..> ^D
(lldb) ^D
siger@vostro ~/D/P/g/test> clear                                                                     
siger@vostro ~/D/P/g/test> gsoc-lldb --script-language lua ./counter
(lldb) target create "./counter"
Current executable set to '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter' (x86_64).
(lldb) script counter_10 = 0
(lldb) breakpoint set --name main -o
Breakpoint 1: where = counter`main + 11 at counter.c:5:9, address = 0x000000000000112b
(lldb) run
Process 78104 launched: '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter' (x86_64)
Process 78104 stopped
* thread #1, name = 'counter', stop reason = breakpoint 1.1
    frame #0: 0x000055555555512b counter`main at counter.c:5:9
   2
   3    int main()
   4    {
-> 5        int counter = 0;
   6        while(counter < 1000)
   7        {
   8            counter++;
(lldb) watchpoint set variable counter
Watchpoint created: Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = enabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
(lldb) watchpoint modify -c "(counter%10==0)"
(lldb) watchpoint command add -s lua
Enter your Lua command(s). Type 'quit' to end.
The commands are compiled as the body of the following Lua function
function (frame, wp, ...) end
..> print(frame, wp)
..> print(string.format("[%i] counter mod 10==0", counter_10))
..> counter_10 = counter_10 + 1
(lldb) c
Process 78104 resuming
frame #0: 0x0000555555555132 counter`main at counter.c:6:19     Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 1     ignore_count = 0
[0] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 11    ignore_count = 0
[1] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 21    ignore_count = 0
[2] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 31    ignore_count = 0
[3] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 41    ignore_count = 0
[4] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 51    ignore_count = 0
[5] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 61    ignore_count = 0
[6] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 71    ignore_count = 0
[7] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 81    ignore_count = 0
[8] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 91    ignore_count = 0
[9] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 101   ignore_count = 0
[10] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 111   ignore_count = 0
[11] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 121   ignore_count = 0
[12] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 131   ignore_count = 0
[13] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 141   ignore_count = 0
[14] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 151   ignore_count = 0
[15] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 161   ignore_count = 0
[16] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 171   ignore_count = 0
[17] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 181   ignore_count = 0
[18] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 191   ignore_count = 0
[19] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 201   ignore_count = 0
[20] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 211   ignore_count = 0
[21] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 221   ignore_count = 0
[22] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 231   ignore_count = 0
[23] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 241   ignore_count = 0
[24] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 251   ignore_count = 0
[25] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 261   ignore_count = 0
[26] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 271   ignore_count = 0
[27] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 281   ignore_count = 0
[28] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 291   ignore_count = 0
[29] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 301   ignore_count = 0
[30] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 311   ignore_count = 0
[31] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 321   ignore_count = 0
[32] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 331   ignore_count = 0
[33] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 341   ignore_count = 0
[34] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 351   ignore_count = 0
[35] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 361   ignore_count = 0
[36] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 371   ignore_count = 0
[37] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 381   ignore_count = 0
[38] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 391   ignore_count = 0
[39] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 401   ignore_count = 0
[40] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 411   ignore_count = 0
[41] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 421   ignore_count = 0
[42] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 431   ignore_count = 0
[43] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 441   ignore_count = 0
[44] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 451   ignore_count = 0
[45] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 461   ignore_count = 0
[46] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 471   ignore_count = 0
[47] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 481   ignore_count = 0
[48] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 491   ignore_count = 0
[49] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 501   ignore_count = 0
[50] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 511   ignore_count = 0
[51] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 521   ignore_count = 0
[52] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 531   ignore_count = 0
[53] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 541   ignore_count = 0
[54] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 551   ignore_count = 0
[55] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 561   ignore_count = 0
[56] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 571   ignore_count = 0
[57] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 581   ignore_count = 0
[58] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 591   ignore_count = 0
[59] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 601   ignore_count = 0
[60] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 611   ignore_count = 0
[61] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 621   ignore_count = 0
[62] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 631   ignore_count = 0
[63] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 641   ignore_count = 0
[64] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 651   ignore_count = 0
[65] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 661   ignore_count = 0
[66] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 671   ignore_count = 0
[67] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 681   ignore_count = 0
[68] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 691   ignore_count = 0
[69] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 701   ignore_count = 0
[70] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 711   ignore_count = 0
[71] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 721   ignore_count = 0
[72] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 731   ignore_count = 0
[73] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 741   ignore_count = 0
[74] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 751   ignore_count = 0
[75] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 761   ignore_count = 0
[76] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 771   ignore_count = 0
[77] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 781   ignore_count = 0
[78] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 791   ignore_count = 0
[79] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 801   ignore_count = 0
[80] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 811   ignore_count = 0
[81] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 821   ignore_count = 0
[82] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 831   ignore_count = 0
[83] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 841   ignore_count = 0
[84] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 851   ignore_count = 0
[85] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 861   ignore_count = 0
[86] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 871   ignore_count = 0
[87] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 881   ignore_count = 0
[88] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 891   ignore_count = 0
[89] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 901   ignore_count = 0
[90] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 911   ignore_count = 0
[91] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 921   ignore_count = 0
[92] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 931   ignore_count = 0
[93] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 941   ignore_count = 0
[94] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 951   ignore_count = 0
[95] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 961   ignore_count = 0
[96] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 971   ignore_count = 0
[97] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 981   ignore_count = 0
[98] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 991   ignore_count = 0
[99] counter mod 10==0
frame #0: 0x0000555555555148 counter`main at counter.c:6:5      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 1001  ignore_count = 0
[100] counter mod 10==0
Stopped due to an error evaluating condition of watchpoint Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w: "(counter%10==0)"
expression failed to parse:
error: <user expression 1001>:1:2: use of undeclared identifier 'counter'
(counter%10==0)
 ^

frame #0: 0x00007ffff7cc03b0 libc.so.6`__run_exit_handlers      Watchpoint 1: addr = 0x7fffffffde28 size = 4 state = disabled type = w
    declare @ '/home/siger/Data/Projects/gsoc-lablua-lldb/test/counter.c:5'
    watchpoint spec = 'counter'
    new value: 0
    condition = '(counter%10==0)'
  watchpoint commands:
No commands.

    hw_index = 0  hit_count = 1002  ignore_count = 0
[101] counter mod 10==0
Process 78104 exited with status = 0 (0x00000000)
(lldb)
```