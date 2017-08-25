/mob/living/carbon/alien/larva/emote(act,m_type=1,message = null)

	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
//TRANSLATE EMOTE [V1.0]
	switch(act)
		if ("me")
			if(silent)
				return
			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "\red Вы не можете отправл&#255;ть сообщение в IC (muted).")
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if ("custom")
			return custom_emote(m_type, message)
		if("sign")
			if (!src.restrained())
				message = text("<B>The alien</B> signs[].", (text2num(param) ? text(" the number []", text2num(param)) : null))
				m_type = 1
		if ("burp")
			if (!muzzled)
				message = "<B>[src]</B> отрыгнул."
				m_type = 2
		if("scratch")
			if (!src.restrained())
				message = "<B>[src.name]</B> издаёт скрип."
				m_type = 1
		if("whimper")
			if (!muzzled)
				message = "<B>[src.name]</B> тихо скулит."
				m_type = 2
//		if("roar")
//			if (!muzzled)
//				message = "<B>The [src.name]</B> roars." Commenting out since larva shouldn't roar /N
//				m_type = 2
		if("tail")
			message = "<B>[src.name]</B> вел&#255;ет хвостом."
			m_type = 1
		if("gasp")
			message = "<B>[src.name]</B> задыхаетс&#255;."
			m_type = 2
		if("shiver")
			message = "<B>[src.name]</B> дрожит."
			m_type = 2
		if("drool")
			message = "<B>[src.name]</B> несёт чепуху."
			m_type = 1
		if("scretch")
			if (!muzzled)
				message = "<B>[src.name]</B> издаёт звук царапин."
				m_type = 2
		if("choke")
			message = "<B>[src.name]</B> давитс&#255;."
			m_type = 2
		if("moan")
			message = "<B>[src.name]</B> стонет!"
			m_type = 2
		if("nod")
			message = "<B>[src.name]</B> кивает."
			m_type = 1
//		if("sit")
//			message = "<B>The [src.name]</B> sits down." //Larvan can't sit down, /N
//			m_type = 1
		if("sway")
			message = "<B>[src.name]</B> шатаетс&#255;."
			m_type = 1
		if("sulk")
			message = "<B>[src.name]</B> обиженно дуетс&#255;."
			m_type = 1
		if("twitch")
			message = "<B>[src.name]</B> сильно дёргаетс&#255;."
			m_type = 1
		if("dance")
			if (!src.restrained())
				message = "<B>[src.name]</B> весело танцует."
				m_type = 1
		if("roll")
			if (!src.restrained())
				message = "<B>[src.name]</B> вертитс&#255;."
				m_type = 1
		if("shake")
			message = "<B>[src.name]</B> тр&#255;сёт головой."
			m_type = 1
		if("gnarl")
			if (!muzzled)
				message = "<B>[src.name]</B> оскаливаетс&#255;.."
				m_type = 2
		if("jump")
			message = "<B>[src.name]</B> прыгает!"
			m_type = 1
		if("hiss_")
			message = "<B>[src.name]</B> тихо шипит."
			m_type = 1
		if("collapse")
			Paralyse(2)
			message = text("<B>[]</B> рухнул!", src)
			m_type = 2
		if("help")
			to_chat(src, "burp, choke, collapse, dance, drool, gasp, shiver, gnarl, jump, moan, nod, roll, scratch,\nscretch, shake, sign-#, sulk, sway, tail, twitch, whimper")
		else
			to_chat(src, text("Неизвестна&#255; эмоци&#255;: []", act))
	if ((message && src.stat == CONSCIOUS))
		log_emote("[name]/[key] : [message]")
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(703)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(746)
	return
