-- sha512 function

-- initial values
local t = {
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
local CONSTANTS = {
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

function SHA512(data)
    local main = t
    data = data .. "\128" .. string.rep("\0", 127 - (#data + 8) % 128) .. string.pack(">I8", #data * 8)
  
    for i = 1, #data, 128 do
      local chunk = data:sub(i, i + 127)
      local w = {}
  
      for j = 1, 16 do
        w[j] = string.unpack(">I8", chunk, (j - 1) * 8 + 1)
      end
  
      for j = 17, 80 do
        w[j] = bit32.bxor(bit32.rrotate(w[j - 15], 1), bit32.rrotate(w[j - 15], 8), bit32.rshift(w[j - 15], 7)) + w[j - 16] + bit32.bxor(bit32.rrotate(w[j - 2], 19), bit32.rrotate(w[j - 2], 61), bit32.rshift(w[j - 2], 6)) + w[j - 7]
      end
  
      local a, b, c, d, e, f, g, h = t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8]
  
      for j = 1, 80 do
        local t1 = h + bit32.bxor(bit32.rrotate(e, 14), bit32.rrotate(e, 18), bit32.rrotate(e, 41)) + bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g)) + w[j]
        local t2 = bit32.bxor(bit32.rrotate(a, 28), bit32.rrotate(a, 34), bit32.rrotate(a, 39)) + bit32.bxor(bit32.band(a, b), bit32.band(a, c), bit32.band(b, c))
        h = g
        g = f
        f = e
        e = bit32.band(d + t1, 0xffffffffffffffff)
        d = c
        c = b
        b = a
        a = bit32.band(t1 + t2, 0xffffffffffffffff)
      end
  
        main[1] = bit32.band(t[1] + a, 0xffffffffffffffff)
        main[2] = bit32.band(t[2] + b, 0xffffffffffffffff)
        main[3] = bit32.band(t[3] + c, 0xffffffffffffffff)
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

-- test
print(SHA512("unicorn").hex());