-- function for parsing command line arguments (named and unnamed)
-- config is a table of the following format:
-- {'name', 'description', 'type', 'default'}
-- type can be 'string', 'number', 'boolean'
-- default is optional
-- returns a table of the following format:
-- {name = value, ...}
local function argparse(config)
    local args = {}
    local i = 1

    -- set default values first
    for k, v in pairs(config) do
        local name = v[1]
        local default = v[4]

        args[name] = default
    end

    -- process provided arguments
    while i <= #arg do
        local argument = arg[i]
        local config = config[argument]
        if config then
            local name = config[1]
            local type = config[3]
            local default = config[4]
            if type == 'boolean' then
                args[name] = true
            else
                i = i + 1
                local value = arg[i]
                if type == 'number' then
                    value = tonumber(value)
                end
                args[name] = value
            end
        -- else
        --     local name = config[1]
        --     local default = config[4]
        --     args[name] = default
        end
        i = i + 1
    end

    return args
end

local api = {
    argparse = argparse
}

return api

-- -- example usage
-- local config = {
--     ['--help'] = {'help', 'show this help message', 'boolean'},
--     ['--name'] = {'name', 'name of the person', 'string', 'John Doe'},
--     ['--age'] = {'age', 'age of the person', 'number'},
--     ['--married'] = {'married', 'is the person married', 'boolean', false},
-- }

-- local args = argparse(config)

-- -- process arguments
-- if args.help then
--     print("Usage: " .. arg[0] .. " [options]")
--     print("Options:")
--     for k, v in pairs(config) do
--         print(k, v[2])
--     end
-- else
--     print("Name: " .. tostring(args.name))
--     print("Age: " .. tostring(args.age))
--     print("Married: " .. tostring(args.married))
-- end