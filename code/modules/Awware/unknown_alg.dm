var
	const/_baseAlphaStr = \
		"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
proc
	strbase(str)
		var/buffer, char, len = length(str)
		for(var/i in 1 to len step 3)
			buffer = text2ascii(str, i) << 4
			if(len-i > 0)
				char = text2ascii(str, i+1)
				buffer |= char >> 4
				. += ascii2text(text2ascii(_baseAlphaStr, 1 + (buffer >> 6))) + \
					ascii2text(text2ascii(_baseAlphaStr, 1 + (buffer & 0x3F)))
				buffer = (char & 0xF) << 8
				if(len-i > 1)
					buffer |= text2ascii(str, i+2)
					. += ascii2text(text2ascii(_baseAlphaStr, 1 + (buffer >> 6))) + \
						ascii2text(text2ascii(_baseAlphaStr, 1 + (buffer & 0x3F)))
				else . += ascii2text(text2ascii(_baseAlphaStr, 1 + (buffer >> 6))) + "="
			else . += ascii2text(text2ascii(_baseAlphaStr, 1 + (buffer >> 6))) + \
				ascii2text(text2ascii(_baseAlphaStr, 1 + (buffer & 0x3F))) + \
				"=="

	basestr(b)
		var/buffer, char, len = length(b)
		for(var/i in 1 to len step 4)
			buffer = (findtextEx(_baseAlphaStr, ascii2text(text2ascii(b, i)))-1) << 2
			char = findtextEx(_baseAlphaStr, ascii2text(text2ascii(b, i+1)))-1
			buffer |= char >> 4
			. += ascii2text(buffer)
			buffer = (char & 0xF) << 4
			char = text2ascii(b, i+2)
			if(char != 61)	// char != "="
				char = findtextEx(_baseAlphaStr, ascii2text(char))-1
				buffer |= char >> 2
				. += ascii2text(buffer)
				buffer = (char & 0x3) << 6
				char = text2ascii(b, i+3)
				if(char != 61)	// char != "="
					buffer |= findtextEx(_baseAlphaStr, ascii2text(char)) - 1
					. += ascii2text(buffer)
				else break
			else break