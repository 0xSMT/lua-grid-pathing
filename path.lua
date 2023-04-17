-- generate a 2d W*H array of nodes where there is an edge between each node and its neighbors
local function generateNodes(W, H)
    local nodes = {}
    for i = 1, W do
        nodes[i] = {}
        for j = 1, H do
            nodes[i][j] = {x = i, y = j}
        end
    end
    local edges = {}
    for i = 1, W do
        for j = 1, H do
            local node = nodes[i][j]
            if i > 1 then
                edges[#edges + 1] = {node, nodes[i - 1][j]}
            end
            if j > 1 then
                edges[#edges + 1] = {node, nodes[i][j - 1]}
            end
        end
    end
    return nodes, edges
end

-- travel in a given direction with continuation probability c, turning probability t, and branching probability b
local function path(nodes, edges, startx, starty, startdir, c, t, b, cDecay, bDecay)
    local traversed = {}

    if (b < 0) then
        b = 0
    end

    if (c < 0) then
        c = 0
    end

    local paths = {{startx = startx, starty = starty, dir = startdir, c = c, t = t, b = b, bDecay = bDecay, cDecay = cDecay}}

    local function turn(dir) 
        return math.random() < 0.5 and {dir[2], -dir[1]} or {-dir[2], dir[1]}
    end

    local function loop(prob)
        -- print(prob)
        return prob
    end

    while #paths > 0 do
        local path = table.remove(paths, 1)
        local currNode = nodes[path.startx][path.starty]

        while loop(math.random()) < path.c do
            local turn_prob = math.random()

            if turn_prob < path.t then
                path.dir = turn(path.dir)
            elseif turn_prob < path.t + path.b then
                local newDir = turn(path.dir)
                local newNode = nodes[currNode.x + newDir[1]] and nodes[currNode.x + newDir[1]][currNode.y + newDir[2]]
                if newNode then
                    table.insert(paths, {startx = newNode.x, starty = newNode.y, dir = newDir, c = path.c, t = path.t, b = path.b - bDecay, bDecay = bDecay, cDecay = cDecay})
                end
            end

            table.insert(traversed, {x = currNode.x, y = currNode.y, dir = path.dir})

            currNode = nodes[currNode.x + path.dir[1]] and nodes[currNode.x + path.dir[1]][currNode.y + path.dir[2]]

            if not currNode then
                break
            end
        end
    end

    return traversed
end

-- local nodes, edges = generateNodes(30, 30)

-- local traversed = path(nodes, edges, 15, 15, {1, 0}, 0.99, 0.3, 0.05, 0.05, 0.01)

-- convert traversed nodes to a 2d array of arrows
local function toGrid(nodes, traversed)
    local grid = {}
    for i = 1, #nodes do
        grid[i] = {}
        for j = 1, #nodes[i] do
            grid[i][j] = ' '
        end
    end
    for i = 1, #traversed do
        local dir = traversed[i].dir

        local dirSym = dir[1] == 1 and "→" or dir[1] == -1 and "←" or dir[2] == 1 and "↓" or dir[2] == -1 and "↑" or "?"

        grid[traversed[i].x][traversed[i].y] = dirSym
    end

    -- make start point 'o'
    if traversed[1] then
        grid[traversed[1].x][traversed[1].y] = 'o'
    end
    
    return grid
end

local function drawUpTo(t, nodes, traversed)
    local upToT = {}

    for i = 1, t do
        table.insert(upToT, traversed[i])
    end

    local grid = toGrid(nodes, upToT)

    -- draw the grid to console
    for i = 1, #grid do
        local line = ""
        for j = 1, #grid[i] do
            line = line .. (grid[j][i])
        end
        io.write(line .. '\n')
    end
end

local function animatedTraverse(traversed, nodes, updateTime)
    local T = #traversed

    local LINE_UP = '\x1B[F'
    
    for t = 1, T do
        drawUpTo(t, nodes, traversed)
        io.write("Traversed " .. t .. " nodes\n")
        io.flush()
        os.execute("sleep " .. tostring(updateTime))
        if (t < T) then
            for _ = 1, #nodes + 1 do
                io.write(LINE_UP)
            end
        end
    end
end

-- TODO: Currently simulated by effectively doing a bernoulli trial for each node.
-- Could instead find a statistical distribution that would instead simulate the length
-- of one straight segment of the path, and then turn. Likely much faster behavior.
-- Would be one for loop iteration per striahgt segment, rather than one per node
-- (which would mean it would be more performant for paths with long straight segments)
local api = {
    generateNodes = generateNodes,
    path = path,
    toGrid = toGrid,
    animatedTraverse = animatedTraverse,
}

return api