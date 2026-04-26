local helpers_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
os.execute("(cd " .. helpers_dir .. " && make)")
