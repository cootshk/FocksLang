# Compiling
Go to `.lux/*/bin/unwrapped/luastatic` and change
```lua

```lua
for i, file in ipairs(lua_source_files) do
	out(('	static const unsigned char lua_require_%i[] = {\n		'):format(i))
	out_lua_source(file);
	out("\n	};\n")
	out(([[
	lua_pushlstring(L, (const char*)lua_require_%i, sizeof(lua_require_%i));
]]):format(i, i))
    out(('	lua_setfield(L, -2, "%s");\n\n'):format(file.dotpath_noextension))
end
```

to
```lua
for i, file in ipairs(lua_source_files) do
	out(('	static const unsigned char lua_require_%i[] = {\n		'):format(i))
	out_lua_source(file);
	out("\n	};\n")
	out(([[
	lua_pushlstring(L, (const char*)lua_require_%i, sizeof(lua_require_%i));
]]):format(i, i))
    ---@type string
    local location = file.dotpath_noextension
    if location:find(".src.", 1, true) then
    	local loc = location:sub(location:find(".src.", 1, true)+5)
    	location = loc
    end
    out(('	lua_setfield(L, -2, "%s");\n\n'):format(location))
end
```

You can try the still WIP compile script by running it with `BETA_BUILD=1 bin/compile`

also todo: patch the script to load the `lfs.so` object from the /lib part of the nix store