local lldb = require 'lldb'

local exe = './program'

lldb.SBDebugger.Initialize()

local debugger = lldb.SBDebugger.Create()
debugger:SetAsync(false)

local target = debugger:CreateTargetWithFileAndArch(exe, lldb.LLDB_ARCH_DEFAULT)
debugger:SetLoggingCallback(function()
    print('log')
end)

-- [typemap] FileSP
debugger:SetOutputFile(io.open('dbg_output.txt', 'w+'))

-- print(target:GetInstructions(0, ""))
print(debugger:SetScriptLanguage(debugger:GetScriptingLanguage('lua')))

-- [typemap] ()
print(lldb.SBData.CreateDataFromSInt32Array(lldb.eByteOrderLittle, 1, {1,-1,2,-2}))
print(lldb.SBData.CreateDataFromSInt32Array(lldb.eByteOrderLittle, 2, {1,-1,2,-2}))
print(lldb.SBData.CreateDataFromSInt32Array(lldb.eByteOrderLittle, 4, {1,-1,2,-2}))
print(lldb.SBData.CreateDataFromSInt32Array(lldb.eByteOrderLittle, 4, {}))

-- [typemap] SBCommandReturnObject
local interpreter = debugger:GetCommandInterpreter()
res = lldb.SBCommandReturnObject()
expression = interpreter:HandleCommand('exp 1', res)
print(res)
res:PutCString('abc')
print(res)

if target then
    print(target)
    local error = lldb.SBError()
    -- Test breakpoint and output disasm result to file in "SetOutputFile"
    local main_bp = target:BreakpointCreateByName('main', target:GetExecutable():GetFilename())
    main_bp:SetScriptCallbackBody("print(frame:GetThread():GetProcess():GetTarget():GetDebugger():HandleCommand('dis')); return false")
    
    local process = target:LaunchSimple(nil, nil, '.')
    local th = process:GetSelectedThread()
    local tid = th:GetThreadID()
    print(process:GetThreadByID(tid))
    print(process:GetState())
    -- Test launching program with specific argv and envp
    -- [typemap] char **
    -- target:LaunchSimple(
    --     {
    --         'A',
    --         'B',
    --         'C'
    --     },
    --     {
    --         'ENV2=1'
    --     },
    --     '/home/siger/data/projects/open-source/gsoc-lablua-lldb/test/lua-module'
    -- )
    target:Launch(
        debugger:GetListener(),
        {
            'A',
            'B',
            'C'
        },
        {
            'ENV2=e',
            'ENV3=e'
        },
        nil, -- 'stdin',
        '/tmp/stdo', -- 'stdout',
        nil, -- 'stderr',
        nil, -- '.',
        0,
        false,
        error
    )
    local f = debugger:GetOutputFileHandle()
    f:write('\nWRITE SOMETHING\n')
    -- local error = lldb.SBError()
    -- local mem = process:ReadMemory(0x555555555179, 16, error)
    -- for i = 1, #mem do
    --     print(mem:byte(i, i))
    -- end
    -- print(error)
end