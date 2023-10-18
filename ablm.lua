ABLoop = {
	curr = 0,
	list = {},
}

function ABLoop.parse(ab_loop_string)
	loop_a, loop_b = string.match(ab_loop_string, "(%d+%.%d+),(%d+%.%d+)")
	-- TODO: error handling
	return tonumber(loop_a), tonumber(loop_b)
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
	local f = io.open(path .. ".abl", "r")

	if f == nil then
		return
	end

	for l in f:lines() do
		table.insert(ABLoop.list, l)
	end
	ABLoop.sort()

	f:close()
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

	local loop_a, loop_b = ABLoop.parse(ABLoop.list[ABLoop.curr])

	mp.set_property("ab-loop-a", loop_a)
	mp.set_property("ab-loop-b", loop_b)
	mp.command(string.format("seek %s absolute", loop_a))
	mp.osd_message(string.format("Restore A-B loop: [%d/%d] %.3f - %.3f", ABLoop.curr, #ABLoop.list, loop_a, loop_b))
end

function ABLoop.adjust(a_or_b, step)
	local loop_a = tonumber(mp.get_property("ab-loop-a"))
	local loop_b = tonumber(mp.get_property("ab-loop-b"))

	if loop_a == nil or loop_b == nil then
		mp.osd_message("No A-B loop to adjust")
		return
	end

	if a_or_b == "a" then
		loop_a = loop_a + step
	end
	if a_or_b == "b" then
		loop_b = loop_b + step
	end

	mp.set_property("ab-loop-a", loop_a)
	mp.set_property("ab-loop-b", loop_b)
	mp.command(string.format("seek %s absolute", loop_b - 0.5))
	mp.osd_message(string.format("Adjust A-B loop: %s - %s", loop_a, loop_b))
end

function ABLoop.save()
	local loop_a = tonumber(mp.get_property("ab-loop-a"))
	local loop_b = tonumber(mp.get_property("ab-loop-b"))

	if loop_a == nil or loop_b == nil then
		mp.osd_message("No A-B loop to save")
		return
	end

	if loop_a > loop_b then
		loop_a, loop_b = loop_b, loop_a
	end
	-- TODO: remove duplicates

	local path = mp.get_property("path")
	local f = io.open(string.format("%s.abl", path), "a+")

	if f == nil then
		mp.osd_message(string.format("Unable to open %s.abl", path))
		return
	end

	f:write(string.format("%.3f,%.3f\n", loop_a, loop_b))
	f:close()
	mp.osd_message(string.format("Save A-B loop: %.3f - %.3f", loop_a, loop_b))
end


mp.add_hook("on_preloaded", 50, ABLoop.load)

mp.add_key_binding("Alt+l",      "ab-loop-save",  ABLoop.save)
mp.add_key_binding("Ctrl+l",     "ab-loop-next",  function () ABLoop.move( 1) end)
mp.add_key_binding("Ctrl+L",     "ab-loop-prev",  function () ABLoop.move(-1) end)
mp.add_key_binding("Ctrl+LEFT",  "ab-loop-fwd-a", function () ABLoop.adjust("a", -0.2) end)
mp.add_key_binding("Ctrl+RIGHT", "ab-loop-bwd-a", function () ABLoop.adjust("a",  0.2) end)
mp.add_key_binding("Alt+LEFT",   "ab-loop-fwd-b", function () ABLoop.adjust("b", -0.2) end)
mp.add_key_binding("Alt+RIGHT",  "ab-loop-bwd-b", function () ABLoop.adjust("b",  0.2) end)
