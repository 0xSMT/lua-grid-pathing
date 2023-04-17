local argparse = require 'cmdargs'
local pathing = require 'path'

local config = {
    ['--help'] = {'help', 'show this help message', 'boolean'},
    ['--width'] = {'width', 'width of the window', 'number', 20},
    ['--height'] = {'height', 'height of the window', 'number', 20},
    ['--startdir'] = {'startdir', 'starting direction', 'string', 'right'},
    ['--startx'] = {'startx', 'starting x position', 'number', 10},
    ['--starty'] = {'starty', 'starting y position', 'number', 10},
    ['--c'] = {'c', 'probability of continuing a given path', 'number', 0.99},
    ['--t'] = {'t', 'probability of turning, but remaining on current path', 'number', 0.3},
    ['--b'] = {'b', 'probability of branching a new path from current node', 'number', 0.05},
    ['--cDecay'] = {'cDecay', 'amount continuation probability decreases on newly branched path', 'number', 0.05},
    ['--bDecay'] = {'bDecay', 'amount branching probability decreases on newly branched path', 'number', 0.01},
    ['--showPlot'] = {'showPlot', 'show the plot of trajectory (final if many)', 'boolean', false},
}

local args = argparse(config)

-- process arguments
if args.help then
    print("Usage: " .. arg[0] .. " [options]")
    print("Options:")
    for k, v in pairs(config) do
        print(k, v[2])
    end
    os.exit()
end

-- convert startdir to a vector
if args.startdir == 'right' then
    args.startdir = {1, 0}
elseif args.startdir == 'left' then
    args.startdir = {-1, 0}
elseif args.startdir == 'up' then
    args.startdir = {0, -1}
elseif args.startdir == 'down' then
    args.startdir = {0, 1}
elseif args.startdir == 'random' then
    -- choose a random direction (up, down, left, or right)
    local opt = math.random(4)
    if opt == 1 then
        args.startdir = {1, 0}
    elseif opt == 2 then
        args.startdir = {-1, 0}
    elseif opt == 3 then
        args.startdir = {0, -1}
    else
        args.startdir = {0, 1}
    end
else
    print("Invalid startdir: " .. args.startdir)
    os.exit()
end

-- generate the nodes and edges
local nodes, edges = pathing.generateNodes(args.width, args.height)

-- simulate a path
local traversed = pathing.path(nodes, edges, args.startx, args.starty, args.startdir, args.c, args.t, args.b, args.cDecay, args.bDecay) 

-- print out the path
local grid = pathing.toGrid(nodes, traversed)

-- print out the number of nodes traversed
print(#traversed .. " nodes traversed")

-- print out the grid
if args.showPlot then
    -- draw the grid to console
    for i = 1, #grid do
        local line = ""
        for j = 1, #grid[i] do
            line = line .. (grid[j][i])
        end
        print(line)
    end
end
