local Encryption = { };

-- SHA Encryption Algorithm
function Encryption.sha256(data)
    -- start values
    -- first 32 bits of the fractional parts of the square roots of the first 8 primes
    local h0 = 0x6a09e667;
    local h1 = 0xbb67ae85;
    local h2 = 0x3c6ef372;
    local h3 = 0xa54ff53a;
    local h4 = 0x510e527f;
    local h5 = 0x9b05688c;
    local h6 = 0x1f83d9ab;
    local h7 = 0x5be0cd19;

    -- constants
    -- first 32 bits of the fractional parts of the cube roots of the first 64 primes
    local k = {
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

    -- fix this data
    local data = data .. "\128" .. string.rep("\0", 63 - ((#data + 8) % 64)) .. string.pack(">I8", #data * 8);

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
        local a, b, c, d, e, f, g, h = h0, h1, h2, h3, h4, h5, h6, h7

        -- main loop
        for j = 1, 64 do
            -- calculate the working variables
            local s0 = bit32.bxor(bit32.rrotate(a, 2), bit32.rrotate(a, 13), bit32.rrotate(a, 22));
            local maj = bit32.bxor(bit32.band(a, b), bit32.band(a, c), bit32.band(b, c));
            local t2 = s0 + maj;
            local s1 = bit32.bxor(bit32.rrotate(e, 6), bit32.rrotate(e, 11), bit32.rrotate(e, 25));
            local ch = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g));
            local t1 = h + s1 + ch + k[j] + w[j];

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

        -- add the compressed chunk to the current hash value
        h0 = bit32.band(h0 + a, 0xffffffff);
        h1 = bit32.band(h1 + b, 0xffffffff);
        h2 = bit32.band(h2 + c, 0xffffffff);
        h3 = bit32.band(h3 + d, 0xffffffff);
        h4 = bit32.band(h4 + e, 0xffffffff);
        h5 = bit32.band(h5 + f, 0xffffffff);
        h6 = bit32.band(h6 + g, 0xffffffff);
        h7 = bit32.band(h7 + h, 0xffffffff);
    end;

    -- result
    local result = string.pack(">I4I4I4I4I4I4I4I4", h0, h1, h2, h3, h4, h5, h6, h7);
	
    -- convert it to hex
	local hex = "";
	for i = 1, #result do
		hex = hex .. string.format("%02x", string.byte(result, i));
	end;
	
    -- return
	return hex;
end
function Encryption.sha224(data)
    -- ...
end
function Encryption.sha384(data)
    -- ...
end
function Encryption.sha512(data)
    -- ...
end

return Encryption