local merge = {}

function merge.all(base, overrides)
	local ret = base or {}
	local second = overrides or {}

	for _, v in pairs(second) do
		table.insert(ret, v)
	end

	return ret
end

return merge
