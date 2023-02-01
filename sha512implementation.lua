local MAX_64BIT = 0xffffffffffffffff;

-- 32 Bitwise operations
local bit32lshift = bit32.lshift
local bit32rshift = bit32.rshift
local bit32band = bit32.band
local bit32bor = bit32.bor
local bit32bxor = bit32.bxor
local bit32bnot = bit32.bnot

-- Ouput array of u8 as one u64
-- function as_u64_be(array)
-- 	local result = 0
-- 	for i = 1, 8 do
-- 		local bit64 = BigInteger.new(result * 256)
-- 		result = bit64:bor(array[i])
-- 	end
-- 	return result
-- end
-- print(as_u64_be({0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01})) -- testing

-- Rotate x right for the given amount n
local function rotr(x, n)
    -- x = u64
    -- n = u32
    return bit32bor(bit32rshift(x, n), bit32lshift(x, 64 - n))
end

-- Shift x right for the given amount n
local function shr(x, n)
    -- x = u64
    -- n = u32
    return bit32rshift(x, n)
end

-- XOR modulus with negation modulus
function ch(x, y, z)
    return bit32bxor(bit32band(x, y), bit32band(bit32bnot(x), z))
end

-- xor mod
function maj(x, y, z)
    return bit32bxor(bit32band(x, y), bit32band(x, z), bit32band(y, z))
end

-- logical shifting and xor combination
function bsig0(x)
    return bit32bxor(rotr(x, 28), rotr(x, 34), rotr(x, 39))
end

-- logical shifting and xor combination
function bsig1(x)
    return bit32bxor(rotr(x, 14), rotr(x, 18), rotr(x, 41))
end

-- logical shifting and xor combination
function ssig0(x)
    return bit32bxor(rotr(x, 1), rotr(x, 8), shr(x, 7))
end

-- logical shifting and xor combination
function ssig1(x)
    return bit32bxor(rotr(x, 19), rotr(x, 61), shr(x, 6))
end

-- wrapping addition
function wrapping_add(a, b)
    return (a + b) % MAX_64BIT
end

-- sha512 hash function
function sha512(initial_msg, initial_len)
    local H = {
        0x6a09e667f3bcc908,
        0xbb67ae8584caa73b,
        0x3c6ef372fe94f82b,
        0xa54ff53a5f1d36f1,
        0x510e527fade682d1,
        0x9b05688c2b3e6c1f,
        0x1f83d9abfb41bd6b,
        0x5be0cd19137e2179
    }
    
    local k = {
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

    --// read msg into bytes
    local msg = {}
    for i = 1, string.len(initial_msg) do
        msg[i] = initial_msg:byte(i)
    end 

    -- pad message
    table.insert(msg, 128)
    local lc = #msg
    while ((lc + 8) % 128) ~= 0 do
        table.insert(msg, 0)
        lc = lc + 1
    end

    -- append length
    local bitlen = initial_len * 8
    local msg_len_le = string.pack(">I8", bitlen)
    
    for i = 1, #msg_len_le do
        local str = msg_len_le:sub(i, i)
        table.insert(msg, str:byte())
    end

    -- parse each array of 128 bytes into 16 64-bit words
    print(msg)

    local msg_parsed = {}
    local len = #msg
    local offset = 0

    while offset < len-1 do
        -- parse 8 bytes into a 64-bit number
        local b1, b2, b3, b4, b5, b6, b7, b8 = {}
        b1 = msg[offset + 1]
        b2 = msg[offset + 2]
        b3 = msg[offset + 3]
        b4 = msg[offset + 4]
        b5 = msg[offset + 5]
        b6 = msg[offset + 6]
        b7 = msg[offset + 7]
        b8 = msg[offset + 8]

        -- msg_parsed.push(as_u64_be(&msg[offset..(offset+8)])); convert to lua

        local num = as_u64_be({b1, b2, b3, b4, b5, b6, b7, b8})
        table.insert(msg_parsed, num)
        offset = offset + 8
    end

    -- The resulting table will contain blocks of 64-bit numbers.
    print("msg_parsed", msg_parsed);

    local offset = 0
    local len = #msg_parsed
    while offset < len-1 do
        -- prepare the message schedule 'w'
        local w = table.create(80, 0) -- 80 64-bit words

        -- parse 16 64-bit words from the input message
        for i = 1, 16 do
            w[i] = msg_parsed[offset + i]
        end

        -- this prints the right table,
        -- the only problem is the first value is wrong completely
        -- print(w)

        -- parse 64 logically shifted combinations of the previous 16 word blocks
        for i = 16, 80 do
            w[i] = wrapping_add(ssig1(w[i-1]), wrapping_add(w[i-6], wrapping_add(ssig0(w[i-14]), w[i-15])))
        end

        print(w)

        -- initialize working variables
        local a = H[1]
        local b = H[2]
        local c = H[3]
        local d = H[4]
        local e = H[5]
        local f = H[6]
        local g = H[7]
        local h = H[8]

        -- 80 rounds of hash computation
        -- for i = 1, 80 do
        --     local t1 = wrapping_add(h, wrapping_add(bsig1(e), wrapping_add(ch(e, f, g), wrapping_add(k[i], w[i]))))
        --     local t2 = wrapping_add(bsig0(a), maj(a, b, c))

        --     h = g
        --     g = f
        --     f = e
        --     e = wrapping_add(d, t1)
        --     d = c
        --     c = b
        --     b = a
        --     a = wrapping_add(t1, t2)
        -- end

        -- print(a, b, c, d, e, f, g, h)

        -- add the results of this round to our pre_value hash array (with wrapping)
        -- H[1] = wrapping_add(a, H[1])
        -- H[2] = wrapping_add(b, H[2])
        -- H[3] = wrapping_add(c, H[3])
        -- H[4] = wrapping_add(d, H[4])
        -- H[5] = wrapping_add(e, H[5])
        -- H[6] = wrapping_add(f, H[6])
        -- H[7] = wrapping_add(g, H[7])
        -- H[8] = wrapping_add(h, H[8])

        offset = offset + 16
    end

    -- print the resulting hash as hexadecimals -> 016 is required so rust does not cut off zeros in the front
    local result = string.format("%016x%016x%016x%016x%016x%016x%016x%016x", H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8])
    return result
end

-- test
local word = "unicorn"
local initial_len = string.len(word)
-- print(sha512(word, initial_len))
sha512(word, initial_len)