-- Define the module
local StringEncoder = require(game:GetService("ReplicatedStorage").StringEncoder);

-- Define the test
local function StringEncoder64Test()
	-- Define the test string
	local testString = "Hello World!";

	-- Encode the string
	local encodedString = StringEncoder.Encode64(testString);

	-- Decode the string
	local decodedString = StringEncoder.Decode64(encodedString);

	-- Print the results
	print("Test String: " .. testString);
	print("Encoded String: " .. encodedString);
	print("Decoded String: " .. decodedString);

	-- Assert the results
	assert(testString == decodedString, "The decoded string does not match the original string.");
end

local function StringEncoder91Test()
	-- Define the test string
	local testString = "Hello World! How are you!!";

	-- Encode the string
	local encodedString = StringEncoder.Encode91(testString);

	-- Decode the string
	local decodedString = StringEncoder.Decode91(encodedString);

	-- Print the results
	print("Test String: " .. testString);
	print("Encoded String: " .. encodedString);
	print("Decoded String: " .. decodedString);

	-- Assert the results
	assert(testString == decodedString, "The decoded string does not match the original string.");
end

-- Run the test
--StringEncoder64Test();
StringEncoder91Test();