local Encryption = { };

local METHODS = {
    ["SHA-224"] = {
        HexSize = 56,
        BytesSize = 28,
        StartValues = {
            0xc1059ed8,
            0x367cd507,
            0x3070dd17,
            0xf70e5939,
            0xffc00b31,
            0x68581511,
            0x64f98fa7,
            0xbefa4fa4
        },
    },

    ["SHA-256"] = {
        HexSize = 64,
        BytesSize = 32,
        StartValues = {
            0x6a09e667,
            0xbb67ae85,
            0x3c6ef372,
            0xa54ff53a,
            0x510e527f,
            0x9b05688c,
            0x1f83d9ab,
            0x5be0cd19
        },
    },

    ["SHA-384"] = {
        HexSize = 96,
        BytesSize = 48,
        StartValues = {
            0xcbbb9d5dc1059ed8,
            0x629a292a367cd507,
            0x9159015a3070dd17,
            0x152fecd8f70e5939,
            0x67332667ffc00b31,
            0x8eb44a8768581511,
            0xdb0c2e0d64f98fa7,
            0x47b5481dbefa4fa4,
        },
    },

    ["SHA-512"] = {
        HexSize = 128,
        BytesSize = 64,
        StartValues = {
            0x6a09e667f3bcc908,
            0xbb67ae8584caa73b,
            0x3c6ef372fe94f82b,
            0xa54ff53a5f1d36f1,
            0x510e527fade682d1,
            0x9b05688c2b3e6c1f,
            0x1f83d9abfb41bd6b,
            0x5be0cd19137e2179
        },
    }
};

local HASH_CONSTANTS = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

-- SHA Encryption Algorithm
-- Lets create a main SHA function, this will be used to create the other SHA functions
-- All we need to do is pass in the start values and the constants
function Encryption.SHA2(startValues, data, typ)
	-- init the start values
	local main = {};
    
    -- copy the start values
	for i = 1, #startValues do
		main[i] = startValues[i];
	end;
	
	-- fix this data
	data = data .. "\128" .. string.rep("\0", 63 - ((#data + 8) % 64)) .. string.pack(">I8", #data * 8);

	-- loop through the data
	for i = 1, #data, 64 do
		-- get the chunk
		local chunk = data:sub(i, i + 63);

		-- init the w array
		local w = {};

		-- fill the w array
		for j = 1, 16 do
			-- get the 32 bit word
			w[j] = string.unpack(">I4", chunk:sub((j - 1) * 4 + 1, j * 4));
		end;

        -- extend the w array
		for j = 17, 64 do
			-- calculate the s0 and s1 values and add them to the w array
			local s0 = bit32.bxor(bit32.rrotate(w[j - 15], 7), bit32.rrotate(w[j - 15], 18), bit32.rshift(w[j - 15], 3));
			local s1 = bit32.bxor(bit32.rrotate(w[j - 2], 17), bit32.rrotate(w[j - 2], 19), bit32.rshift(w[j - 2], 10));
			w[j] = bit32.band(w[j - 16] + s0 + w[j - 7] + s1, 0xffffffff);
		end;

		-- init the working variables
		local a, b, c, d, e, f, g, h = main[1], main[2], main[3], main[4], main[5], main[6], main[7], main[8];

		-- main loop
		for j = 1, 64 do
			-- calculate the working variables
			local s0 = bit32.bxor(bit32.rrotate(a, 2), bit32.rrotate(a, 13), bit32.rrotate(a, 22));
			local maj = bit32.bxor(bit32.band(a, b), bit32.band(a, c), bit32.band(b, c));
			local t2 = s0 + maj;
			local s1 = bit32.bxor(bit32.rrotate(e, 6), bit32.rrotate(e, 11), bit32.rrotate(e, 25));
			local ch = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g));
			local t1 = h + s1 + ch + HASH_CONSTANTS[j] + w[j];

			-- update the working variables
			h = g;
			g = f;
			f = e;
			e = bit32.band(d + t1, 0xffffffff);
			d = c;
			c = b;
			b = a;
			a = bit32.band(t1 + t2, 0xffffffff);
		end;
        
		-- update the start values
		main[1] = bit32.band(main[1] + a, 0xffffffff);
		main[2] = bit32.band(main[2] + b, 0xffffffff);
		main[3] = bit32.band(main[3] + c, 0xffffffff);
		main[4] = bit32.band(main[4] + d, 0xffffffff);
		main[5] = bit32.band(main[5] + e, 0xffffffff);
		main[6] = bit32.band(main[6] + f, 0xffffffff);
		main[7] = bit32.band(main[7] + g, 0xffffffff);
		main[8] = bit32.band(main[8] + h, 0xffffffff);
	end;

	-- return the digest
	return {
		hex = function()
            local digest = "";

            for i = 1, #main do
                digest = digest .. string.format("%08x", main[i]);
            end;

            return digest;
		end,

		bytes = function()
			local digest = "";

			for i = 1, #main do
				digest = digest .. string.pack(">I4", main[i]);
			end;

			return digest;
		end;
	};
end;
function Encryption.sha256(data)
	-- use our main SHA function
	-- get our start values and constants
	local h0, h1, h2, h3, h4, h5, h6, h7 = table.unpack(METHODS["SHA-256"].StartValues);

	-- main loop
	-- use our main SHA function
	-- result
	local result = Encryption.SHA2({h0, h1, h2, h3, h4, h5, h6, h7}, data, "SHA-256");
	return result;
end
function Encryption.sha224(data)
	-- use our main SHA function
	-- get our start values and constants
	local h0, h1, h2, h3, h4, h5, h6, h7 = table.unpack(METHODS["SHA-224"].StartValues);

	-- return the result
	-- start values is an array
	local result = Encryption.SHA2({h0, h1, h2, h3, h4, h5, h6, h7}, data, "SHA-224");
	return result;
end
function Encryption.sha384(data)
	-- ...
    -- Needs to use another function because it uses different constants and start values
end
function Encryption.sha512(data)
	-- ...
    -- Needs to use another function because it uses different constants and start values
end

-- Testing for now
print(Encryption.sha256("unicorn").hex())

return Encryption