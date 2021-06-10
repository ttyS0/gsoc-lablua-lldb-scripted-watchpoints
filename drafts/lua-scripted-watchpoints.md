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
(lldb) watchpoint modify -c "(counter%10==0)"
(lldb) watchpoint command add -s python
Enter your Python command(s). Type 'DONE' to end.
    global counter_10 
    print("[%i] counter mod 10==0" % counter_10) 
    counter_10 += 1 
    frame.GetThread().GetProcess().Continue() 
(lldb) c
Process 1799208 resuming
(lldb) [0] counter mod 10==0
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