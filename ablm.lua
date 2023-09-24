ABLoop = {
    curr = 0,
    list = {},
}

function ABLoop.parse(ab_loop_string)
    return string.match(ab_loop_string, "(%d+%.%d+),(%d+%.%d+)")
end

function ABLoop.sort()
    table.sort(ABLoop.list, function (l1, l2)
        local l1_loop_a, l1_loop_b = ABLoop.parse(l1)
        local l2_loop_a, l2_loop_b = ABLoop.parse(l2)
        if l1_loop_a < l2_loop_a then
            return true
        end
        if l1_loop_a == l2_loop_a and l1_loop_b < l2_loop_b then
            return true
        end
        return false
    end)
end

function ABLoop.load()
    local path = mp.get_property("path")

    -- TODO: error handling
    local f, err, errno = io.open(path .. ".abl", "r")

    for l in f:lines() do
        table.insert(ABLoop.list, l)
    end
end

function ABLoop.move(step)
    if #ABLoop.list == 0 then
        mp.osd_message("Unfound A-B loop")
        return
    end

    ABLoop.curr = ABLoop.curr + step
    if ABLoop.curr > #ABLoop.list then
        ABLoop.curr = 1
    elseif ABLoop.curr < 1 then
        ABLoop.curr = #ABLoop.list
    end

    print(#ABLoop.list, ABLoop.list)
    print(ABLoop.list[1])
    local loop_a, loop_b = ABLoop.parse(ABLoop.list[ABLoop.curr])
    print(loop_a .. " " .. loop_b)

    mp.command("ab-loop")
    mp.set_property("ab-loop-a", loop_a)
    mp.set_property("ab-loop-b", loop_b)
    mp.command(string.format("seek %s absolute", loop_a))
    mp.osd_message(string.format("Restore A-B loop: [%d/%d] %s - %s", ABLoop.curr, #ABLoop.list, loop_a, loop_b))
end

function ABLoop.save()
    local path = mp.get_property("path")
    local loop_a = mp.get_property("ab-loop-a")
    local loop_b = mp.get_property("ab-loop-b")

    if loop_a == "no" or loop_b == "no" then
        mp.osd_message("No A-B loop to save")
    else
        mp.osd_message(string.format("Save A-B loop: %s - %s", loop_a, loop_b))

        -- TODO: catching errors
        local f, err, errno = io.open(path .. ".abl", "a+")

        f:write(string.format("%s,%s\n", loop_a, loop_b))
        f:close()
    end
end


mp.add_hook("on_preloaded", 50, ABLoop.load)
mp.add_key_binding("Alt+l", "ab-loop-save", ABLoop.save)
mp.add_key_binding("Ctrl+l", "ab-loop-next", function () ABLoop.move(1) end)
mp.add_key_binding("Ctrl+L", "ab-loop-prev", function () ABLoop.move(-1) end)
