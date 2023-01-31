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

local SHA384_SHA512_CONSTANTS = {
    0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f,
    0xe9b5dba58189dbbc, 0x3956c25bf348b538, 0x59f111f1b605d019,
    0x923f82a4af194f9b, 0xab1c5ed5da6d8118, 0xd807aa98a3030242,
    0x12835b0145706fbe, 0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2,
    0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235,
    0xc19bf174cf692694, 0xe49b69c19ef14ad2, 0xefbe4786384f25e3,
    0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65, 0x2de92c6f592b0275,
    0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5,
    0x983e5152ee66dfab, 0xa831c66d2db43210, 0xb00327c898fb213f,
    0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725,
    0x06ca6351e003826f, 0x142929670a0e6e70, 0x27b70a8546d22ffc,
    0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 0x53380d139d95b3df,
    0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6,
    0x92722c851482353b, 0xa2bfe8a14cf10364, 0xa81a664bbc423001,
    0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218,
    0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8,
    0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 0x2748774cdf8eeb99,
    0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb,
    0x5b9cca4f7763e373, 0x682e6ff3d6b2b8a3, 0x748f82ee5defb2fc,
    0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
    0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915,
    0xc67178f2e372532b, 0xca273eceea26619c, 0xd186b8c721c0c207,
    0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba,
    0x0a637dc5a2c898a6, 0x113f9804bef90dae, 0x1b710b35131c471b,
    0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc,
    0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cf6bceb3,
    0x5fcb6fab3ad6faec, 0x6c44198c4a475817
};

-- SHA Encryption Algorithm
-- Lets create a main SHA function, this will be used to create the other SHA functions
-- All we need to do is pass in the start values and the constants
function Encryption.SHA2(startValues, data, typ)
	-- init the start values
	local main = {};
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
			local t1 = h + s1 + ch + SHA384_CONSTANTS[j] + w[j];

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
print(Encryption.sha384("unicorn").hex())

return Encryption