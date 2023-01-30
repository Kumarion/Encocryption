-- Define the module
local StringEncoder = require(game:GetService("ReplicatedStorage").StringEncoder);

-- Define the test
local function StringEncoderTest()
    -- Define the test string
    local testString = "Hello World!";

    -- Encode the string
    local encodedString = StringEncoder.Encode(testString);

    -- Decode the string
    local decodedString = StringEncoder.Decode(encodedString);

    -- Print the results
    print("Test String: " .. testString);
    print("Encoded String: " .. encodedString);
    print("Decoded String: " .. decodedString);

    -- Assert the results
    assert(testString == decodedString, "The decoded string does not match the original string.");
end

-- Run the test
StringEncoderTest();