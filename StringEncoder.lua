local HttpService = game:GetService("HttpService");

-- Define our base64 characters
local base64chars = [[
	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/
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

return {
	Encode = stringToBase64,
	Decode = base64ToString,
}