local HttpService = game:GetService("HttpService");

-- Define our base64 characters
local base64chars = [[
	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/
]];

-- Define our base91 characters (recommended for use with datastores)
local base91chars = [[
	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,-./:;<=>?@[]^_`{|}~
]];

function stringToBase64(str)
	local serialized = str;

	local padding = (3 - (string.len(serialized) % 3)) % 3;
	serialized = serialized .. string.rep('\0', padding);

	local base64 = "";

	for i = 1, string.len(serialized), 3 do
		local a, b, c = string.byte(serialized, i, i + 2);
		local b1, b2, b3, b4 = bit32.rshift(a, 2), bit32.lshift(bit32.band(a, 3), 4) + bit32.rshift(b, 4), bit32.lshift(bit32.band(b, 15), 2) + bit32.rshift(c, 6), bit32.band(c, 63);
		base64 = base64 .. string.sub(base64chars, b1 + 1, b1 + 1) .. string.sub(base64chars, b2 + 1, b2 + 1) .. string.sub(base64chars, b3 + 1, b3 + 1) .. string.sub(base64chars, b4 + 1, b4 + 1);
	end;

	return string.sub(base64, 1, -padding - 1);
end

function base64ToString(base64)
	local padding = 0;
	local unpaddedLength = string.len(base64);

	if (string.sub(base64, -1) == "=") then
		padding = padding + 1;
	end;

	if (string.sub(base64, -2, -2) == "=") then
		padding = padding + 1;
	end;

	local serialized = "";

	for i = 1, string.len(base64), 4 do
		local b1, b2, b3, b4 = string.find(base64chars, string.sub(base64, i, i)), string.find(base64chars, string.sub(base64, i + 1, i + 1)), string.find(base64chars, string.sub(base64, i + 2, i + 2)), string.find(base64chars, string.sub(base64, i + 3, i + 3));
		local a, b, c = bit32.lshift(b1 - 1, 2) + bit32.rshift(b2 - 1, 4), bit32.lshift(bit32.band(b2 - 1, 15), 4) + bit32.rshift(b3 - 1, 2), bit32.lshift(bit32.band(b3 - 1, 3), 6) + (b4 - 1);
		serialized = serialized .. string.char(a) .. string.char(b) .. string.char(c);
	end;

	return serialized;
end

local function stringToBase91(str)
	if (str == nil) then
		error("Base91: Missing str to encode.");
	end;

	local raw;

	if (type(str) == "number") then
		raw = tostring(str);
	else
		raw = str;
	end;

	raw = { raw:byte(1, #raw) };
	local len = #raw;

	local ret = "";
	local n = 0;
	local b = 0;

	for i = 1, len do
		b = bit32.bor(b, bit32.lshift(raw[i], n));
		n = n + 8;

		if (n > 13) then
			local v = bit32.band(b, 8191);

			if (v > 88) then
				b = bit32.rshift(b, 13);
				n = n - 13;
			else
				v = bit32.band(b, 16383);
				b = bit32.rshift(b, 14);
				n = n - 14;
			end

			ret = ret .. string.char(base91chars:byte(v % 91 + 1)) .. string.char(base91chars:byte(math.floor(v / 91) + 1));
		end;
	end;

	if (n > 0) then
		ret = ret .. string.char(base91chars:byte(b % 91 + 1));

		if (n > 7 or b > 90) then
			ret = ret .. string.char(base91chars:byte(math.floor(b / 91) + 1));
		end;
	end;

	return ret;
end

local function base91ToString(base91)
	local raw = tostring(base91 or "");
	local len = #raw;

	local ret = {};
	local b = 0;
	local n = 0;
	local v = -1;

	for i = 1, len do
		local p = string.find(base91chars, raw:sub(i, i), 1, true);

		if (p == nil) then
			continue;
		end;

		if v < 0 then
			v = p - 1;
		else
			v = v + (p - 1) * 91;
			b = b + bit32.lshift(v, n);
			n = n + (bit32.band(v, 8191) > 88 and 13 or 14);

			while (n > 7) do
				table.insert(ret, bit32.band(b, 0xff));
				b = bit32.rshift(b, 8);
				n = n - 8;
			end;

			v = -1;
		end;

		continue;
	end;

	if (v > -1) then
		table.insert(ret, bit32.band(b + bit32.lshift(v, n), 0xff));
	end;

	local decoded = "";

	for i, byte in ipairs(ret) do
		decoded = decoded .. string.char(byte);
	end;

	return decoded;
end

return {
	Encode64 = stringToBase64,
	Decode64 = base64ToString,

	Encode91 = stringToBase91,
	Decode91 = base91ToString,
}