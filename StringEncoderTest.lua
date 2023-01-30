-- Define the module
local StringEncoder = require(game:GetService("ReplicatedStorage").StringEncoder);

-- Define the test
local function StringEncoder64Test()
	print("--------------BASE 64---------------");
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
	print("--------------------------------------");
end

local function StringEncoder91Test()
	print("--------------BASE 91---------------");
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
	print("--------------------------------------");
end

local function StringEncoder16Test()
	print("--------------BASE 16---------------");
	-- Define the test string
	local testString = "Hithere"

	-- Encode the string
	local encodedString = StringEncoder.Encode16(testString);

	-- Decode the string
	local decodedString = StringEncoder.Decode16(encodedString);

	-- Print the results
	print("Test String: " .. testString);
	print("Encoded String: " .. encodedString);
	print("Decoded String: " .. decodedString);
	print("--------------------------------------");
end

-- Run the test
StringEncoder64Test();
StringEncoder91Test();
StringEncoder16Test();