/mob/living/carbon/human
	var/mob/living/carbon/human/partner
	var/mob/living/carbon/human/lastfucked
	var/lfhole
	var/potenzia = 10
	var/resistenza = 200
	var/lust = 0
	var/erpcooldown = 0
	var/multiorgasms = 0
	var/lastmoan
	var/mutilated_genitals = 0


/mob/living/carbon/human/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(M == src || src == usr || M != usr)		return
	if(usr.restrained())		return

	var/mob/living/carbon/human/H = usr
	H.partner = src
	make_interaction(machine)

/mob/proc/make_interaction()
	return

/mob/living/carbon/human/make_interaction()
	set_machine(src)

	var/mob/living/carbon/human/H = usr
	var/mob/living/carbon/human/P = H.partner
	var/mouthfree = !(H.wear_mask && !istype(P.head, /obj/item/clothing/head/helmet))
	var/mouthfree_p = !(P.wear_mask && !istype(P.head, /obj/item/clothing/head/helmet))
	var/haspenis = H.has_penis()
	var/haspenis_p = P.has_penis()
	var/hasvagina = (H.gender == FEMALE && H.species.genitals)
	var/hasvagina_p = (P.gender == FEMALE && P.species.genitals)
	var/hasanus_p = P.species.anus
	var/hasanus = H.species.anus
	var/isnude = H.is_nude()
	var/isnude_p = P.is_nude()

	H.lastfucked = null
	H.lfhole = ""

	var/dat = "<B><HR><FONT size=3>¬заимодейтсви€ с [H.partner]</FONT></B><BR><HR>"
//--------------------------Hands--------------------------//
	dat +=  {"<font size=3><B>–уки:</B></font><BR>"}
	if (Adjacent(P) && isnude_p && hasvagina_p  && (!P.mutilated_genitals))
		dat += {"<A href='?src=\ref[usr];interaction=fingering'><font color=white>Put fingers in places...</font></A><BR>"}
	if (hasanus_p)
		dat += {"<A href='?src=\ref[usr];interaction=assslap'><font color=white>Slap ass</font></A><BR>"}
	if (P.species.name == TAJARAN)
		dat +=  {"<A href='?src=\ref[usr];interaction=touchtail'><font color=white>Touch the tip of the tail</font></A><BR>"}
//--------------------------Mouth--------------------------//
	dat +=  {"<font size=3><B>–от:</B></font><BR>"}
	if(mouthfree && mouthfree_p)
		dat += {"<A href='?src=\ref[usr];interaction=kiss'>Kiss.</A><BR>"}
		if(Adjacent(P) && isnude_p && (!P.mutilated_genitals))
			if(haspenis_p)
				dat += {"<A href='?src=\ref[usr];interaction=blowjob'><font color=purple>Give head.</font></A><BR>"}
			if(hasvagina_p)
				dat += {"<A href='?src=\ref[usr];interaction=vaglick'><font color=purple>Lick pussy.</font></A><BR>"}
			if(hasanus_p)
				dat += {"<A href='?src=\ref[usr];interaction=asslick'><font color=purple>Lick ass.</font></A><BR>"}
			if(P.gender == FEMALE)
				dat += {"<A href='?src=\ref[usr];interaction=suckle'><font color=purple>Suckle</font></A><BR>"}
//--------------------------ERP MAIN--------------------------//
	if(isnude && usr.loc == H.partner.loc)
		if(haspenis && isnude_p)
			dat += {"<font size=3><B>≈–ѕ:</B></font><BR>"}
			if (hasvagina_p && (!P.mutilated_genitals))
				dat += {"<A href='?src=\ref[usr];interaction=vaginal'><font color=purple>Fuck vagina.</font></A><BR>"}
			if (hasanus_p)
				dat += {"<A href='?src=\ref[usr];interaction=anal'><font color=purple>Fuck ass.</font></A><BR>"}
			if (mouthfree_p)
				dat += {"<A href='?src=\ref[usr];interaction=oral'><font color=purple>Fuck mouth.</font></A><BR>"}
	if (isnude && usr.loc == H.partner.loc && hasvagina)
		dat += {"<font size=3><B>Ћоно:</B></font><BR>"}
		dat += {"<A href='?src=\ref[usr];interaction=mountmouth'><font color=purple>Mount mouth!</font></A><BR><HR>"}
		if(haspenis_p && (!H.mutilated_genitals) && hasanus)
			dat += {"<A href='?src=\ref[usr];interaction=mount'><font color=purple>Mount!</font></A><BR><HR>"}
			dat += {"<font size=3><B>Ass:</B></font><BR>"}
			dat += {"<A href='?src=\ref[usr];interaction=mountass'><font color=purple>Mount ass!</font></A><BR><HR>"}
//--------------------------System--------------------------//
	var/datum/browser/popup = new(usr, "interactions", "Interactions", 340, 480)
	popup.set_content(dat)
	popup.open()

/mob/living/carbon/human/proc/is_nude()
	return (!w_uniform) ? 1 : 0

/mob/living/carbon/human/proc/cum(mob/living/carbon/human/H as mob, mob/living/carbon/human/P as mob, var/hole = "floor")
	var/turf/T
	var/text = ""

	if (H.gender == MALE)
		var/datum/reagent/blood/source = H.get_blood(H.vessel)
		if (P)
			T = get_turf(P)
		else
			T = get_turf(H)
		if (H.multiorgasms < H.potenzia)
			var/obj/effect/decal/cleanable/cum/C = new(T)
			C.blood_DNA = list()
			if(source.data["blood_type"])
				C.blood_DNA[source.data["blood_DNA"]] = source.data["blood_type"]
			else
				C.blood_DNA[source.data["blood_DNA"]] = "O+"

		if (H.species.genitals)
			switch(hole)
				if("mouth")
					text = "кончил в рот [P]"
				if("vagina")
					text = "кончил в вагину [P]"
				if("anus")
					text = "кончил в анал [P]"
				if("floor")
					text = "кончил на пол"
		else
			text = "кончает!"

		playsound(loc, "sound/interactions/final_m[rand(1, 5)].ogg", 70, 1, 0)
		H.visible_message("\blue [H] [text]")
		if (istype(P.loc, /obj/structure/closet))
			P.visible_message("\blue [H] [text]")
		H.lust = 5
		H.resistenza += 60
		H.erpcooldown = rand(70, 160)
		addtimer(CALLBACK(H, .proc/handle_lust), H.erpcooldown * 10)
	else
		text = "кончает!"
		H.visible_message("\blue [H] [text].")
		if (istype(P.loc, /obj/structure/closet))
			P.visible_message("\blue [H] [text].")
		playsound(loc, "sound/interactions/final_f[rand(1, 3)].ogg", 90, 1, 0)
		var/delta = pick(30, 40, 50, 60)
		src.lust -= delta

	H.druggy = 30
	H.multiorgasms += 1
//SPECIES ERP ATTRIBUTES
/datum/species
	human
		genitals = 1
		anus = 1
	tajaran
		genitals = 1
		anus = 1
	unathi
		genitals = 1
		anus = 1
	skrell
		genitals = 1
		anus = 1
	//machine
	//	genitals = 1
	//	anus = 1
/mob/living/carbon/human/proc/fuck(mob/living/carbon/human/H as mob, mob/living/carbon/human/P as mob, var/hole)
	var/text = ""
	switch(hole)
		if("touchtail")
			text = pick("нежно трогает кончик хвоста у [P].", "грубо трогает кончик хвоста у [P] иногда надавлива&#255;.")

			if (H.lastfucked != P || H.lfhole != hole)				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [text]</font>")
				P.lust += 0.15
			else
				H.visible_message("<font color=purple>[H] [text]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 0.15
				if(prob(5))
					P.moan()
			H.do_fucking_animation(P)
		if("asslick")
			text = pick("лижет колечко ануса у [P].", "посасывает колечко ануса у [P].", "нежно лижет анус у [P] и иногда просовывает свой &#255;зычок во внутрь.")

			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [text]</B></font>")
				P.lust += 1
			else
				H.visible_message("<font color=purple>[H] [text]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [text]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 2
				if (P.lust >= P.resistenza)
					if(P.gender == FEMALE)
						P.cum(P, H)
				else
					P.moan()
			if(prob(5))
				P.moan()
			H.do_fucking_animation(P)
		if("vaglick")
			text = pick("лижет вагину у [P].", "посасывает клитор у [P].", "нежно раздвигает лоно [P], просовыва&#255; внутрь &#255;зык.")
			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole
			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [text]</B></font>")
				P.lust += 2
			else
				H.visible_message("<font color=purple>[H] [text]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [text]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 2.25
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)

		if("fingering")
			text = pick("мастурбирует [P].", "нежно мастурбирует [P].")
			if (prob(35))
				text = pick("усердно мастурбирует [P].")
			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole
			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [text]</B></font>")
				P.lust += 2
			else
				H.visible_message("<font color=purple>[H] [text]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [text]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 2
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			playsound(loc, "sound/interactions/champ_fingering.ogg", 50, 1, -1)
			H.do_fucking_animation(P)
		if("suckle")

			text = pick("мацает грудь [P]")
			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole
			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [text]</B></font>")
				P.lust += 1.25
			else
				H.visible_message("<font color=purple>[H] [text]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [text]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 1.25
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)
		if("blowjob")
			text = pick("sucks [P]'s dick.", "gives [P] head.")
			if (prob(35))
				text = pick("sucks [P] off.")
			if (H.lust < 6)
				H.lust += 2
			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [text]</B></font>")
				P.lust += 5
			else
				H.visible_message("<font color=purple>[H] [text]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [text]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 5
				if (P.lust >= P.resistenza)
					P.cum(P, H, "mouth")
			playsound(loc, "sound/interactions/bj[rand(1, 11)].ogg", 50, 1, -1)
			H.do_fucking_animation(P)
			if (prob(P.potenzia))
				H.visible_message("\blue [H] goes in deep on [P].")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("\blue [H] goes in deep on [P].")
		if("vaginal")
			text = pick("fucks [P].",)
			if (prob(35))
				text = pick("pounds [P]'s pussy.")

			if (H.lastfucked != P || H.lfhole != hole)
				text = pick(" shoves their dick into [P]'s pussy.")
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [text]</font>")
				P.lust += 6
			else
				H.visible_message("<font color=purple>[H] [text]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [text]</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += 6
			if (H.lust >= H.resistenza)
				H.cum(H, P, "vagina")

			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 6
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)
			playsound(loc, "sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)
		if("anal")

			text = pick("fucks [P]'s ass.")
			if (prob(35))
				text = pick("fucks [P]'s ass.")

			if (H.lastfucked != P || H.lfhole != hole)
				text = pick(" shoves their dick into [P]'s asshole.")
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [text]</font>")
				P.lust += 5
			else
				H.visible_message("<font color=purple>[H] [text]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [text]</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += 4
			if (H.lust >= H.resistenza)
				H.cum(H, P, "anus")

			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				if (H.potenzia > 13)
					P.lust += 4
				else
					P.lust += 5
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)
			playsound(loc, "sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)

		if("oral")

			text = pick("fucks [P]'s throat.")
			if (prob(35))
				text = pick(" sucks [P]'s [P.gender == FEMALE ? "vag" : "dick"]..", " licks [P]'s [P.gender == FEMALE ? "vag" : "dick"]..")
			if (H.lastfucked != P || H.lfhole != hole)
				text = pick(" shoves their dick down [P]'s throat.")
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && H.stat != DEAD)
				H.visible_message("<font color=purple>[H] [text]</font>")
				H.lust += 5
			else
				H.visible_message("<font color=purple>[H] [text]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [text]</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += 5
			if (H.lust >= H.resistenza)
				H.cum(H, P, "mouth")

			H.do_fucking_animation(P)
			playsound(loc, "sound/interactions/oral[rand(1, 2)].ogg", 70, 1, -1)
			if (P.species.name == "Slime People")
				playsound(loc, "sound/interactions/champ[rand(1, 2)].ogg", 50, 1, -1)
			if (prob(H.potenzia))
				H.visible_message("\blue [H] fucks [P]'s mouth.")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("\blue [H] fucks [P]'s mouth.")
		if("mount")

			text = pick("fucks [P]'s dick", "rides [P]'s dick", "rides [P]")

			if (H.lastfucked != P || H.lfhole != hole)
				text = pick("begins to hop on [P]'s dick")
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [text].</font>")
				P.lust += H.potenzia * 1.2
			else
				H.visible_message("<font color=purple>[H] [text].</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [text].</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += P.potenzia
			if (H.lust >= H.resistenza)
				H.cum(H, P)
			else
				H.moan()
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += H.potenzia
				if (P.lust >= P.resistenza)
					P.cum(P, H, "vagina")
				else
					P.moan()
			H.do_fucking_animation(P)
			playsound(loc, "sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)
		if("mountass")

			text = pick("fucks [P]'s dick", "rides [P]'s dick", "rides [P]")

			if (H.lastfucked != P || H.lfhole != hole)
				text = pick("begins to hop on [P]'s dick")
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [text].</font>")
				P.lust += H.potenzia * 1.2
			else
				H.visible_message("<font color=purple>[H] [text].</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [text].</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += P.potenzia
			if (H.lust >= H.resistenza)
				H.cum(H, P)
			else
				H.moan()
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += H.potenzia
				if (P.lust >= P.resistenza)
					P.cum(P, H, "anus")
				else
					P.moan()
			H.do_fucking_animation(P)
			playsound(loc, "sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)
		if("mountmouth")

			text = pick("mount mouth [P]")

			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [text].</font>")
				P.lust += H.potenzia * 1.2
			else
				H.visible_message("<font color=purple>[H] [text].</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [text].</font>")
			H.lust += P.potenzia
			if (H.lust >= H.resistenza)
				H.cum(H, P)
			else
				H.moan()
			if (prob(5))
				P.moan()
			H.do_fucking_animation(P)
/mob/living/carbon/human/proc/moan()
	var/mob/living/carbon/human/H = src
	switch(species.name)
		if ("Human")
			if (prob(H.lust / H.resistenza * 65))
				var/text = pick("стонет!", "сдавленно стонет.",)
				H.visible_message("\blue [H] [text].")
				var/g = H.gender == FEMALE ? "f" : "m"
				var/moan = rand(1, 7)
				if (moan == lastmoan)
					moan--
				if(!istype(loc, /obj/structure/closet))
					playsound(loc, "sound/interactions/moan_[g][moan].ogg", 70, 1, 1)
				else if (g == "f")
					playsound(loc, "sound/interactions/under_moan_f[rand(1, 4)].ogg", 70, 1, 1)
				lastmoan = moan
		if (TAJARAN)
			if (prob(H.lust / H.resistenza * 65))
				var/text = pick("издаЄт звук подобный стону", "стонет!",)
				H.visible_message("\blue [H] [text].")
				var/moan = rand(1, 7)
				if (moan == lastmoan)
					moan--
				playsound(loc, "sound/interactions/purr[rand(1, 3)].ogg", 70, 1, 0)
				lastmoan = moan
/mob/living/carbon/human/proc/has_penis()
	if(gender == MALE && potenzia > -1 && species.genitals && !mutilated_genitals)
		return 1
	else return 0

/mob/living/carbon/human/proc/mutilate_genitals()
	if(!mutilated_genitals)
		potenzia = -1
		mutilated_genitals = 1
		return 1
mob/living/carbon/human/proc/handle_lust()
	lust = 0
	lastfucked = null
	lfhole = ""
	multiorgasms = 0
	erpcooldown = 0
/mob/living/carbon/human/proc/do_fucking_animation(mob/living/carbon/human/P)
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/final_pixel_y = initial(pixel_y)

	var/direction = get_dir(src, P)
	if(direction & NORTH)
		pixel_y_diff = 8
	else if(direction & SOUTH)
		pixel_y_diff = -8

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8

	if(pixel_x_diff == 0 && pixel_y_diff == 0)
		pixel_x_diff = rand(-3,3)
		pixel_y_diff = rand(-3,3)
		animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
		animate(pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 2)
		return

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = initial(pixel_x), pixel_y = final_pixel_y, time = 2)