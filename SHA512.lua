-- sha512 function

-- initial values
local _h = {
    0x6a09e667f3bcc908,
    0xbb67ae8584caa73b,
    0x3c6ef372fe94f82b,
    0xa54ff53a5f1d36f1,
    0x510e527fade682d1,
    0x9b05688c2b3e6c1f,
    0x1f83d9abfb41bd6b,
    0x5be0cd19137e2179
}

-- initial constants
local _k = {
    0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc,
    0x3956c25bf348b538, 0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118,
    0xd807aa98a3030242, 0x12835b0145706fbe, 0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2,
    0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 0xc19bf174cf692694,
    0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65,
    0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5,
    0x983e5152ee66dfab, 0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4,
    0xc6e00bf33da88fc2, 0xd5a79147930aa725, 0x06ca6351e003826f, 0x142929670a0e6e70,
    0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 0x53380d139d95b3df,
    0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
    0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30,
    0xd192e819d6ef5218, 0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8,
    0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8,
    0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 0x682e6ff3d6b2b8a3,
    0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
    0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b,
    0xca273eceea26619c, 0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178,
    0x06f067aa72176fba, 0x0a637dc5a2c898a6, 0x113f9804bef90dae, 0x1b710b35131c471b,
    0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 0x431d67c49c100d4c,
    0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817
};

local MAX_64BIT = 0xffffffffffffffff;

local function _rotr(x, y)
    return (bit32.band((bit32.bor((bit32.rshift(x, y)), (bit32.lshift(x, (64 - y))))), MAX_64BIT));
end

function SHA512(data)
    local main = {};

    -- populate the main array
	for i = 1, #_h do
		main[i] = _h[i];
	end;

    local function _sha512_process(chunk)
        local w = {};

        -- fill the w array
        for j = 1, 16 do
            -- get the 64 bit word
            local word = chunk:sub((j - 1) * 8 + 1, j * 8);

            -- pad the word if it's too short
            if (#word < 8) then
                word = word .. string.rep("\0", 8 - #word);
            end;

            -- convert the word to a number in big endian
            w[j] = string.unpack(">I8", word);
        end;

        -- print(w)
        print(w);

        -- extend the w array
        for i = 17, 80 do
            local s0 = bit32.bxor(bit32.bxor(_rotr(w[i - 15], 1), _rotr(w[i - 15], 8)), bit32.rshift(w[i - 15], 7));
            local s1 = bit32.bxor(bit32.bxor(_rotr(w[i - 2], 19), _rotr(w[i - 2], 61)), bit32.rshift(w[i - 2], 6));      
            w[i] = bit32.band(w[i - 16] + s0 + w[i - 7] + s1, MAX_64BIT);
        end;

        local a, b, c, d, e, f, g, h = main[1], main[2], main[3], main[4], main[5], main[6], main[7], main[8];

        -- main loop
        for i = 1, 80 do
            local s0 = bit32.bxor(bit32.bxor(_rotr(a, 28), _rotr(a, 34)), _rotr(a, 39));
            local maj = bit32.bxor(bit32.bxor(bit32.band(a, b), bit32.band(a, c)), bit32.band(b, c));
            local t2 = bit32.band(s0 + maj, MAX_64BIT);
            local s1 = bit32.bxor(bit32.bxor(_rotr(e, 14), _rotr(e, 18)), _rotr(e, 41));
            local ch = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g));
            local t1 = bit32.band(h + s1 + ch + _k[i] + w[i], MAX_64BIT);

            h = g;
            g = f;
            f = e;
            e = bit32.band(d + t1, MAX_64BIT);
            d = c;
            c = b;
            b = a;
            a = bit32.band(t1 + t2, MAX_64BIT);
        end;

        print("end");
        print(a, b, c, d, e, f, g, h);

        -- add the values to the main array
        main[1] = bit32.band(main[1] + a, MAX_64BIT);
        main[2] = bit32.band(main[2] + b, MAX_64BIT);
        main[3] = bit32.band(main[3] + c, MAX_64BIT);
        main[4] = bit32.band(main[4] + d, MAX_64BIT);
        main[5] = bit32.band(main[5] + e, MAX_64BIT);
        main[6] = bit32.band(main[6] + f, MAX_64BIT);
        main[7] = bit32.band(main[7] + g, MAX_64BIT);
        main[8] = bit32.band(main[8] + h, MAX_64BIT);
    end;

    -- process the data
    for i = 1, #data, 128 do
        _sha512_process(data:sub(i, i + 127));
    end;

    -- convert the digest to hex
    local function digestHex()
        local digest = "";

        for i = 1, #main do
            digest = digest .. string.format("%02x", main[i]);
        end;

        return digest;
    end;

    return {
        hex = function()
            return digestHex();
        end
    };
end

print(SHA512("unicorn").hex());