client/verb
	StrB()
		set name = "String To Base"
		set category = "Admin"

		var/str = input(src, "Input a text string:") as null|text
		if(str)
			usr.visible_message("\blue [strbase(str)]")
	BStr()
		set name = "Base To String"
		set category = "Admin"

		var/b = input(src, "Input a Base string:") as null|text
		if(b)
			usr.visible_message("\blue [basestr(b)]")