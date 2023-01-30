-- TODO
local Encryption = require(...);

local function sha256(data)
    -- hex
    -- return Encryption.sha256(data).hex();

    -- bytes
    -- return Encryption.sha256(data).bytes();
end

print(sha256("abcdef"));