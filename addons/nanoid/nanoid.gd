class_name Nanoid
extends RefCounted

const ALPHANUMERICALS: String = "useandom26T198340PX75pxJACKVERYMINDBUSHWOLFGQZbfghjklqvwyzrict"

## Generate a random ID using the NanoID algorithm.[br]
## [param size] The length of the ID to generate.[br]
## [param alphabet] The characters to use in the ID.
static func generate(length: int = 21, alphabet: String = ALPHANUMERICALS) -> String:
	var crypto: Crypto = Crypto.new()
	var id: String = ""
	var bytes: PackedByteArray = crypto.generate_random_bytes(length)
	
	for i in range(length):
		id += ALPHANUMERICALS[bytes[i] % ALPHANUMERICALS.length()]  # Use modulo to keep values in range (0-ALPHANUMERICALS.length())

	return id
