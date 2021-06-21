# Scripting Docs Draft

## Python

```
process attach -n "dictionary"
breakpoint set -n find_word
continue
script
```

```python
import tree_utils
root = lldb.frame.FindVariable("dictionary")
current_path = ""
path = tree_utils.DFS(root, "Romeo", current_path)
print(path)
```

## Lua

### Tree utils

```
breakpoint set -n find_word
run
script
tree_utils = require("tree_utils")
root = lldb.frame:FindVariable("dictionary")
current_path = ""
path = tree_utils.DFS(root, "Romeo", current_path)
print(path)
```

```lua
local function DFS(root, word, cur_path)
    local root_word_ptr = root:GetChildMemberWithName("word")
    local left_child_ptr = root:GetChildMemberWithName("left")
    local right_child_ptr = root:GetChildMemberWithName("right")
    local root_word = root_word_ptr:GetSummary()
    local end_pos = #root_word
    if root_word:sub(1, 1) == '"' and root_word:sub(end_pos, end_pos) == '"' then
        root_word = root_word:sub(2, end_pos - 1)
    end
    end_pos = #root_word
    if root_word:sub(1, 1) == '\'' and root_word:sub(end_pos, end_pos) == '\'' then
        root_word = root_word:sub(2, end_pos - 1)
    end
    if root_word == word then
        return cur_path
    elseif word < root_word then
        if not left_child_ptr:GetValue() then
            return ""
        else
            cur_path = cur_path .. "L"
            return DFS(left_child_ptr, word, cur_path)
        end
     else
        if not right_child_ptr:GetValue() then
            return ""
        else
            cur_path = cur_path .. "R"
            return DFS(right_child_ptr, word, cur_path)
        end
    end
end

return { DFS = DFS }
```

![Demo 1](./lua-scripting-demo-1.png)

### Breakpoints trigger

```
breakpoint set -l 116
breakpoint set -l 118
breakpoint command add -s lua 2
breakpoint command add -s lua 3
continue
```

```lua
if path:sub(1, 1) == 'L' then
    path = path:sub(2, #path)
    thread = frame:GetThread()
    process = thread:GetProcess()
    process:Continue()
else
    print("Here is the problem. Going left, should go right!")
end
quit

if path:sub(1, 1) == 'R' then
    path = path:sub(2, #path)
    thread = frame:GetThread()
    process = thread:GetProcess()
    process:Continue()
else
    print("Here is the problem. Going right, should go left!")
end
quit
```

![Demo 2](./lua-scripting-demo-2.png)

# Reference Draft

## Embedded Interpreter

```
breakpoint set -n main
run
```

```lua
print(lldb.debugger)
print(lldb.target)
print(lldb.process)
print(lldb.thread)
print(lldb.frame)
```

![](./lua-reference-demo-interpreter.png)

## Breakpoint Hit Counter

```c
#include <stdio.h>
#include <math.h>

int main()
{
    printf("%lf %lf %lf", sqrt(2), pow(2, 3), sin(M_PI / 2));
    return 0;
}
```

```
breakpoint set --func-regex=. --shlib=libm.so.6
script counter = 0
breakpoint command add -s lua 1
```

```lua
counter = counter + 1 
name = frame:GetFunctionName() 
print(string.format('[%i] %s', counter, name)) 
bp_loc:SetEnabled(false) 
return false
```

![](./lua-reference-demo-bp-counter.png)