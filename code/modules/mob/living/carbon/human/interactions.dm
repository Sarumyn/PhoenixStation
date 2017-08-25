/**********************************
*******Interactions code by HONKERTRON feat TestUnit********
**Contains a lot ammount of ERP and MEHANOYEBLYA**
**RECODED BY AWWARE, AND OPTIMAZED
***********************************/

/mob/living/carbon/human/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(M == src || src == usr || M != usr)		return
	if(usr.restrained())		return

	var/mob/living/carbon/human/H = usr
	H.partner = src
	make_interaction(machine)

/mob/proc/make_interaction()
	return
/mob/living/carbon/human/proc/hashands(hand, mob/living/carbon/human/temps)
	return 1

/mob/living/carbon/human/proc/is_nude()
	return (!w_uniform) ? 1 : 0

/datum/species/human
	genitals = 1
	anus = 1

/mob/living/carbon/human/make_interaction()
	set_machine(src)

	var/mob/living/carbon/human/H = usr
	var/mob/living/carbon/human/P = H.partner
	var/mouthfree = !(H.wear_mask)
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

	var/dat = "<B><HR><FONT size=3>Взаимодейтсвия с [H.partner]</FONT></B><BR><HR>"
	if (hashands(BP_R_HAND, H))
		dat +=  {"<font size=3><B>Руки:</B></font><BR>"}
		if (Adjacent(P))
			if (isnude_p)
				if (hasvagina_p && (!P.mutilated_genitals))
					dat += {"<A href='?src=\ref[usr];interaction=fingering'><font color=white>Put fingers in places...</font></A><BR>"}
				if (hasanus_p)
					dat += {"<A href='?src=\ref[usr];interaction=assslap'><font color=white>Slap ass</font></A><BR>"}
			if (P.species.name == TAJARAN)
				dat +=  {"<A href='?src=\ref[usr];interaction=touchtail'><font color=white>Touch the tip of the tail</font></A><BR>"}
	if (mouthfree)
		dat += {"<font size=3><B>Рот:</B></font><BR>"}
		if(mouthfree_p)
			dat += {"<A href='?src=\ref[usr];interaction=kiss'>Kiss.</A><BR>"}
		if (Adjacent(P))
			if (isnude_p && (!P.mutilated_genitals))
				if (haspenis_p)
					dat += {"<A href='?src=\ref[usr];interaction=blowjob'><font color=purple>Give head.</font></A><BR>"}
				if (hasvagina_p)
					dat += {"<A href='?src=\ref[usr];interaction=vaglick'><font color=purple>Lick pussy.</font></A><BR>"}
				if (hasanus_p)
					dat += {"<A href='?src=\ref[usr];interaction=asslick'><font color=purple>Lick ass.</font></A><BR>"}
				if (P.gender == FEMALE)
					dat += {"<A href='?src=\ref[usr];interaction=suckle'><font color=purple>Suckle</font></A><BR>"}
	if (isnude && usr.loc == H.partner.loc)
		if (haspenis && hashands(BP_R_HAND, H))
			dat += {"<font size=3><B>ЕРП:</B></font><BR>"}
			if (isnude_p)
				if (hasvagina_p && (!P.mutilated_genitals))
					dat += {"<A href='?src=\ref[usr];interaction=vaginal'><font color=purple>Fuck vagina.</font></A><BR>"}
				if (hasanus_p)
					dat += {"<A href='?src=\ref[usr];interaction=anal'><font color=purple>Fuck ass.</font></A><BR>"}
				if (mouthfree_p)
					dat += {"<A href='?src=\ref[usr];interaction=oral'><font color=purple>Fuck mouth.</font></A><BR>"}
	if (isnude && usr.loc == H.partner.loc && hasvagina)
		dat += {"<font size=3><B>Лоно:</B></font><BR>"}
		dat += {"<A href='?src=\ref[usr];interaction=mountmouth'><font color=purple>Mount mouth!</font></A><BR><HR>"}
		if (hasvagina && haspenis_p && (!H.mutilated_genitals) && hasanus_p)
			dat += {"<A href='?src=\ref[usr];interaction=mount'><font color=purple>Mount!</font></A><BR><HR>"}
			dat += {"<font size=3><B>Ass:</B></font><BR>"}
			dat += {"<A href='?src=\ref[usr];interaction=mountass'><font color=purple>Mount ass!</font></A><BR><HR>"}

	var/datum/browser/popup = new(usr, "interactions", "Interactions", 340, 480)
	popup.set_content(dat)
	popup.open()

//INTERACTIONS
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
	var/mutilated_genitals = 0 //Whether or not they can do the fug.

mob/living/carbon/human/proc/cum(mob/living/carbon/human/H as mob, mob/living/carbon/human/P as mob, var/hole = "floor")
	var/message = ""
	var/turf/T

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
			if (hole == "mouth" || H.zone_sel.selecting == "mouth")
				message = pick("cums right in [P]'s mouth.")

			else if (hole == "vagina")
				message = pick("cums in [P]'s pussy")

			else if (hole == "anus")
				message = pick("cums in [P]'s asshole.")
			else if (hole == "floor")
				message = "cums on the floor!"

		else
			message = pick("cums!", "orgams!")

		playsound(loc, "sound/interactions/final_m[rand(1, 5)].ogg", 70, 1, 0)

		H.visible_message("\blue [H] [message]")
		if (istype(P.loc, /obj/structure/closet))
			P.visible_message("\blue [H] [message]")
		H.lust = 5
		H.resistenza += 50

	else
		message = pick("cums!")
		H.visible_message("\blue [H] [message].")
		if (istype(P.loc, /obj/structure/closet))
			P.visible_message("\blue [H] [message].")
		playsound(loc, "sound/interactions/final_f[rand(1, 3)].ogg", 90, 1, 0)
		var/delta = pick(20, 30, 40, 50)
		src.lust -= delta

	H.druggy = 60
	H.multiorgasms += 1
	H.erpcooldown = rand(200, 450)
	H.druggy = 120

mob/living/carbon/human/proc/fuck(mob/living/carbon/human/H as mob, mob/living/carbon/human/P as mob, var/hole)
	var/message = ""

	switch(hole)

		if("touchtail")
			message = pick("нежно трогает кончик хвоста у [P].", "грубо трогает кончик хвоста у [P] иногда надавливая.")

			if (H.lastfucked != P || H.lfhole != hole)
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [message]</font>")
				P.lust += 0.15
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 0.15
				if(prob(5))
					P.moan()
			H.do_fucking_animation(P)
		if("asslick")
			message = pick("licks ass [P].", "sucks [P]'s ass.")

			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [message]</B></font>")
				P.lust += 2
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 2
				if (P.lust >= P.resistenza)
					if(P.gender == FEMALE)
						P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)
		if("vaglick")

			message = pick("licks [P].", "sucks [P]'s pussy.")

			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [message]</B></font>")
				P.lust += 5
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 5
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)

		if("fingering")

			message = pick("fingers [P].", "fingers [P]'s pussy.")
			if (prob(35))
				message = pick("fingers [P] hard.")
			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [message]</B></font>")
				P.lust += 5
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 5
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			playsound(loc, "sound/interactions/champ_fingering.ogg", 50, 1, -1)
			H.do_fucking_animation(P)

		if("suckle")

			message = pick("suckle [P].", "suckle [P]'s boobs")
			if (prob(35))
				message = pick("suckle [P] hard.")
			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [message]</B></font>")
				P.lust += 5
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 5
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)

		if("blowjob")
			message = pick("sucks [P]'s dick.", "gives [P] head.")
			if (prob(35))
				message = pick("sucks [P] off.")
			if (H.lust < 6)
				H.lust += 4
			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [message]</B></font>")
				P.lust += 4
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 4
				if (P.lust >= P.resistenza)
					P.cum(P, H, "mouth")
			playsound(loc, "sound/interactions/bj[rand(1, 11)].ogg", 50, 1, -1)
			H.do_fucking_animation(P)
			if (prob(P.potenzia))
				H.visible_message("\blue [H] goes in deep on [P].")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("\blue [H] goes in deep on [P].")

		if("vaginal")
			message = pick("fucks [P].",)
			if (prob(35))
				message = pick("pounds [P]'s pussy.")

			if (H.lastfucked != P || H.lfhole != hole)
				message = pick(" shoves their dick into [P]'s pussy.")
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [message]</font>")
				P.lust += H.potenzia * 2
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += 5
			if (H.lust >= H.resistenza)
				H.cum(H, P, "vagina")

			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += H.potenzia * 0.5
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)
			playsound(loc, "sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)

		if("anal")

			message = pick("fucks [P]'s ass.")
			if (prob(35))
				message = pick("fucks [P]'s ass.")

			if (H.lastfucked != P || H.lfhole != hole)
				message = pick(" shoves their dick into [P]'s asshole.")
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [message]</font>")
				P.lust += H.potenzia * 2
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += 5
			if (H.lust >= H.resistenza)
				H.cum(H, P, "anus")

			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				if (H.potenzia > 13)
					P.lust += H.potenzia * 0.25
				else
					P.lust += H.potenzia * 0.75
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)
			playsound(loc, "sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)

		if("oral")

			message = pick("fucks [P]'s throat.")
			if (prob(35))
				message = pick(" sucks [P]'s [P.gender == FEMALE ? "vag" : "dick"]..", " licks [P]'s [P.gender == FEMALE ? "vag" : "dick"]..")
			if (H.lastfucked != P || H.lfhole != hole)
				message = pick(" shoves their dick down [P]'s throat.")
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && H.stat != DEAD)
				H.visible_message("<font color=purple>[H][message]</font>")
				H.lust += 7
			else
				H.visible_message("<font color=purple>[H][message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H][message]</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += 7
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

			message = pick("fucks [P]'s dick", "rides [P]'s dick", "rides [P]")

			if (H.lastfucked != P || H.lfhole != hole)
				message = pick("begins to hop on [P]'s dick")
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [message].</font>")
				P.lust += H.potenzia * 1.2
			else
				H.visible_message("<font color=purple>[H] [message].</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message].</font>")
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

		if("mountmouth")

			message = pick("rides [P]")

			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				P.visible_message("<font color=purple>[H] [message].</font>")
				P.lust += H.potenzia * 1.25
			else
				H.visible_message("<font color=purple>[H] [message].</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message].</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += P.potenzia
			if (H.lust >= H.resistenza)
				H.cum(H, P)
			else
				H.moan()
			H.do_fucking_animation(P)
			playsound(loc, "sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)

		if("mountass")

			message = pick("fucks [P]'s dick in ass", "rides [P]'s dick ass", "rides [P]'s ass")

			if (H.lastfucked != P || H.lfhole != hole)
				message = pick("begins ass [P]'s dick")
				H.lastfucked = P
				H.lfhole = hole

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple>[H] [message].</font>")
				P.lust += H.potenzia * 1.2
			else
				H.visible_message("<font color=purple>[H] [message].</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message].</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += P.potenzia
			if (P.lust >= P.resistenza)
				P.cum(H, P)
			else
				P.moan()
			if (H.stat != DEAD && H.stat != UNCONSCIOUS)
				H.lust += H.potenzia
				if (H.lust >= H.resistenza)
					H.cum(H, P, "anus")
				else
					H.moan()
			H.do_fucking_animation(P)
			playsound(loc, "sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)

mob/living/carbon/human/proc/moan()

	var/mob/living/carbon/human/H = src
	switch(species.name)
		if ("Human")
			if (prob(H.lust / H.resistenza * 65))
				var/message = pick("moans", "moans in pleasure",)
				H.visible_message("\blue [H] [message].")
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
				var/message = pick("издаёт звук подобный стону", "стонет",)
				H.visible_message("\blue [H] [message].")
				var/moan = rand(1, 7)
				if (moan == lastmoan)
					moan--
				playsound(loc, "sound/interactions/purr[rand(1, 3)].ogg", 70, 1, 0)
				lastmoan = moan

mob/living/carbon/human/proc/handle_lust()
	lust -= 4
	if (lust <= 0)
		lust = 0
		lastfucked = null
		lfhole = ""
		multiorgasms = 0
	if (lust == 0)
		erpcooldown -= 1
	if (erpcooldown < 0)
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

/obj/item/weapon/enlarger
	name = "penis enlarger"
	desc = "Very special DNA mixture which helps YOU to enlarge your little captain."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	item_state = "dnainjector"
	hitsound = null
	throwforce = 0
	w_class = 1
	throw_speed = 3
	throw_range = 15
	attack_verb = list("stabbed")

/obj/item/weapon/enlarger/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(istype(M, /mob/living/carbon/human) && (M.gender == MALE))
		M.potenzia = 30
		M << "<span class='warning'>Your penis extends!</span>"

	else if (istype(M, /mob/living/carbon/human) && M.gender == FEMALE)
		M << "<span class='warning'>It didn't affect you since you're female!</span>"

	..()

	qdel(src)

/obj/item/weapon/enlarger/attack_self(mob/user as mob)
	user << "<span class='warning'>You break the syringe. Gooey mass is dripping on the floor.</span>"
	qdel(src)

/obj/item/weapon/dildo
	name = "dildo"
	desc = "Hmmm, deal throw"
	icon = 'icons/obj/dildo.dmi'
	icon_state = "dildo"
	item_state = "c_tube"
	throwforce = 0
	force = 10
	w_class = 1
	throw_speed = 3
	throw_range = 15
	attack_verb = list("slammed", "bashed", "whipped")
	var/hole = "vagina"
	var/pleasure = 10

/obj/item/weapon/dildo/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	var/hasvagina = (M.gender == FEMALE && M.species.genitals && M.species.name != "Unathi" && M.species.name != "Stok")
	var/hasanus = M.species.anus
	var/message = ""

	if(istype(M, /mob/living/carbon/human) && user.zone_sel.selecting == "groin" && M.is_nude())
		if (hole == "vagina" && hasvagina)
			if (user == M)
				message = pick("fucks their own pussy")//, "Г§Г ГІГ Г«ГЄГЁГўГ ГҐГІ Гў Г±ГҐГЎ[ya] [rus_name]", "ГЇГ®ГЈГ°ГіГ¦Г ГҐГІ [rus_name] Гў Г±ГўГ®ГҐ Г«Г®Г­Г®")
			else
				message = pick("fucks [M] right in the pussy with the dildo", "jams it right into [M]")//, "Г§Г ГІГ Г«ГЄГЁГўГ ГҐГІ Гў [M] [rus_name]", "ГЇГ®ГЈГ°ГіГ¦Г ГҐГІ [rus_name] Гў Г«Г®Г­Г® [M]")

			if (prob(5) && M.stat != DEAD && M.stat != UNCONSCIOUS)
				user.visible_message("<font color=purple><B>[user] [message].</B></font>")
				M.lust += pleasure * 2

			else if (M.stat != DEAD && M.stat != UNCONSCIOUS)
				user.visible_message("<font color=purple>[user] [message].</font>")
				M.lust += pleasure

			if (M.lust >= M.resistenza)
				M.cum(M, user, "floor")
			else
				M.moan()

			user.do_fucking_animation(M)
			playsound(loc, "sound/interactions/bang[rand(4, 6)].ogg", 70, 1, -1)

		else if (hole == "anus" && hasanus)
			if (user == M)
				message = pick("fucks their ass")
			else
				message = pick("fucks [M]'s asshole")

			if (prob(5) && M.stat != DEAD && M.stat != UNCONSCIOUS)
				user.visible_message("<font color=purple><B>[user] [message].</B></font>")
				M.lust += pleasure * 2

			else if (M.stat != DEAD && M.stat != UNCONSCIOUS)
				user.visible_message("<font color=purple>[user] [message].</font>")
				M.lust += pleasure

			if (M.lust >= M.resistenza)
				M.cum(M, user, "floor")
			else
				M.moan()

			user.do_fucking_animation(M)
			playsound(loc, "sound/interactions/bang[rand(4, 6)].ogg", 70, 1, -1)

		else
			..()
	else
		..()

/obj/item/weapon/dildo/attack_self(mob/user as mob)
	if(hole == "vagina")
		hole = "anus"
	else
		hole = "vagina"
	user << "<span class='warning'>Hmmm. Maybe we should put it in [hole]?!</span>"