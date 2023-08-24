ab_loop = {}

function ab_loop_load()
    local path = mp.get_property("path")

    -- TODO: error handling
    local f, err, errno = io.open(path .. ".abl", "r")

    for l in f:lines() do
        table.insert(ab_loop, l)
    end

    for i, v in ipairs(ab_loop) do
        local loop_a, loop_b = string.match(v, "(%d+%.%d+),(%d+%.%d+)")
        mp.command("ab-loop")
        mp.set_property("ab-loop-a", loop_a)
        mp.set_property("ab-loop-b", loop_b)
        mp.command("seek " .. loop_a .. " absolute")
        -- TODO: dealing with multiple A-B loops
        break
    end
end

function ab_loop_save()
    local ab_loop = {}

    local path = mp.get_property("path")
    local loop_a = mp.get_property("ab-loop-a")
    local loop_b = mp.get_property("ab-loop-b")

    if loop_a == "no" or loop_b == "no" then
        print("Unable to get A-B loop points")
        return
    end

    print(loop_a, loop_b)

    -- TODO: catching errors
    local f, err, errno = io.open(path .. ".abl", "a+")

    f:write(loop_a .. "," .. loop_b .. "\n")
    f:close()
end

mp.add_key_binding("Ctrl+L", "ab-loop-save", ab_loop_save)
mp.add_key_binding("Ctrl+l", "ab-loop-load", ab_loop_load)
