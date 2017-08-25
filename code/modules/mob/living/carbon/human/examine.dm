/mob/living/carbon/human/examine(mob/user)
	var/skipgloves = 0
	var/skipsuitstorage = 0
	var/skipjumpsuit = 0
	var/skipshoes = 0
	var/skipmask = 0
	var/skipears = 0
	var/skipeyes = 0
	var/skipface = 0
	//exosuits and helmets obscure our view and stuff.
	if(wear_suit)
		skipgloves = wear_suit.flags_inv & HIDEGLOVES
		skipsuitstorage = wear_suit.flags_inv & HIDESUITSTORAGE
		skipjumpsuit = wear_suit.flags_inv & HIDEJUMPSUIT
		skipshoes = wear_suit.flags_inv & HIDESHOES

	if(head)
		skipmask = head.flags_inv & HIDEMASK
		skipeyes = head.flags_inv & HIDEEYES
		skipears = head.flags_inv & HIDEEARS
		skipface = head.flags_inv & HIDEFACE

	if(wear_mask)
		skipface |= wear_mask.flags_inv & HIDEFACE

	// crappy hacks because you can't do \his[src] etc. I'm sorry this proc is so unreadable, blame the text macros :<
	var/t_He = "Это" //capitalised for use at the start of each line.
	var/t_his = "его"
	var/t_his2 = "Его"
	var/t_is = "это"
	var/t_its = "него"
	var/buckle_event = "пристёгнут"
	var/t_sleeping = "заснул"
	var/t_catatonics = "впал"

	var/msg = "<span class='info'>*---------*\nЭто "

	if( skipjumpsuit && skipface ) //big suits/masks/helmets make it hard to tell their gender
		t_He = "Оно"
		t_his = "их"
		t_is = "находятся"
	else
		switch(gender)
			if(MALE)
				t_He = "Он"
				t_his = "его"
				t_his2 = "Его"
				t_its = "него"
			if(FEMALE)
				t_He = "Она"
				t_his = "её"
				t_his2 = "Её"
				t_its = "неё"
				buckle_event = "пристёгнута"
				t_sleeping = "заснула"
				t_catatonics = "впала"

	msg += "<EM>[src.name]</EM>!\n"

	//uniform TRANSLATE
	if(w_uniform && !skipjumpsuit)
		//Ties
		var/tie_msg
		if(istype(w_uniform,/obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.hastie)
				tie_msg += " с [bicon(U.hastie)] \a [U.hastie]"

		if(w_uniform.blood_DNA)
			msg += "<span class='warning'>[t_He] носит [bicon(w_uniform)] [w_uniform.gender==PLURAL?"":""] испачканую [(w_uniform.blood_color != "#030303") ? "кровью" : "топливом"] [w_uniform.name][tie_msg]!</span>\n"
		else if(w_uniform.wet)
			msg += "<span class='wet'>[t_He] носит промокшую [bicon(w_uniform)] [w_uniform.gender==PLURAL?"":""] [w_uniform.name][tie_msg]!</span>\n"
		else
			msg += "[t_He] носит [bicon(w_uniform)] [w_uniform][tie_msg].\n"

	//head TRANSLATE
	if(head)
		if(head.blood_DNA)
			msg += "<span class='warning'>[t_He] носит [bicon(head)] [head.gender==PLURAL?"":""] испачканое [(head.blood_color != "#030303") ? "кровью" : "топливом"] [head.name] на [t_his] голове!</span>\n"
		else if(head.wet)
			msg += "<span class='wet'>[t_He] носит промокшую [bicon(head)] [head.gender==PLURAL?"":""] [head.name] на голове!</span>\n"
		else
			msg += "[t_He] носит [bicon(head)] [head] на голове.\n"

	//suit/armour TRANSLATE
	if(wear_suit)
		if(wear_suit.blood_DNA) //TRANSLATE TO RUSSTIAN LANGUAGE
			msg += "<span class='warning'>[t_He] носит [bicon(wear_suit)] [wear_suit.gender==PLURAL?"":""] испачканое [(wear_suit.blood_color != "#030303") ? "кровью" : "топливом"] [wear_suit.name]!</span>\n"
		else if(wear_suit.wet)
			msg += "<span class='wet'>[t_He] носит промокшую [bicon(wear_suit)] [wear_suit.gender==PLURAL?"":""] [wear_suit.name]!</span>\n"
		else
			msg += "[t_He] носит [bicon(wear_suit)] [wear_suit].\n"

		//suit/armour storage TRANSLATE
		if(s_store && !skipsuitstorage)
			if(s_store.blood_DNA)
				msg += "<span class='warning'>[t_He] носит [bicon(s_store)] [s_store.gender==PLURAL?"":""] испачканую [(s_store.blood_color != "#030303") ? "кровью" : "топливом"] [s_store.name] на [wear_suit.name]!</span>\n"
			else
				msg += "[t_He] несёт [bicon(s_store)] [s_store] на [wear_suit.name].\n"

	//back TRANSLATE
	if(back)
		if(back.blood_DNA)
			msg += "<span class='warning'>[t_He] носит [bicon(back)] [back.gender==PLURAL?"":""] испачканый [(back.blood_color != "#030303") ? "кровью" : "топливом"] [back] на спине.</span>\n"
		else if(back.wet)
			msg += "<span class='wet'>[t_He] носит промокший [bicon(back)] [back.gender==PLURAL?"":""][back] на спине.</span>\n"
		else
			msg += "[t_He] носит [bicon(back)] [back] на спине.\n"

	//left hand TRANSLATE
	if(l_hand && !(l_hand.flags&ABSTRACT))
		if(l_hand.blood_DNA)
			msg += "<span class='warning'>[t_He] держит [bicon(l_hand)] [l_hand.gender==PLURAL?"":""] испачканый [(l_hand.blood_color != "#030303") ? "кровью" : "топливом"] [l_hand.name] в левой руке!</span>\n"
		else if(l_hand.wet)
			msg += "<span class='wet'>[t_He] держит промокшую [bicon(l_hand)] [l_hand.gender==PLURAL?"":""] [l_hand.name] в левой руке!</span>\n"
		else
			msg += "[t_He] держит [bicon(l_hand)] [l_hand] в левой руке.\n"

	//right hand TRANSLATE
	if(r_hand && !(r_hand.flags&ABSTRACT))
		if(r_hand.blood_DNA)
			msg += "<span class='warning'>[t_He] держит [bicon(r_hand)] [r_hand.gender==PLURAL?"":""] испачканый [(r_hand.blood_color != "#030303") ? "кровью" : "топливом"] [r_hand.name] в правой руке!</span>\n"
		else if(r_hand.wet)
			msg += "<span class='wet'>[t_He] держит промокший(ую) [bicon(r_hand)] [r_hand.gender==PLURAL?"":""] [r_hand.name] в правой руке!</span>\n"
		else
			msg += "[t_He] держит [bicon(r_hand)] [r_hand] в правой руке.\n"
	//gloves TRANSLATE
	if(gloves && !skipgloves)
		if(gloves.blood_DNA)
			msg += "<span class='warning'>[t_He] носит [bicon(gloves)] [gloves.gender==PLURAL?"":""] испачканые [(gloves.blood_color != "#030303") ? "кровью" : "топливом"] [gloves.name] на руках!</span>\n"
		else if(gloves.wet)
			msg += "<span class='wet'>[t_He] носит промокшие [bicon(gloves)] [gloves.gender==PLURAL?"":""] [gloves.name] на руках!</span>\n"
		else
			msg += "[t_He] носит [bicon(gloves)] [gloves] на руках.\n"
	else if(blood_DNA)
		msg += "<span class='warning'>У [t_its] испачканые [(hand_blood_color != "#030303") ? "кровью" : "топливом"] руки!</span>\n"

	//handcuffed? TRANSLATE
	if(handcuffed)
		if(istype(handcuffed, /obj/item/weapon/handcuffs/cable))
			msg += "<span class='warning'>[t_He] в [bicon(handcuffed)] самодельных наручниках!</span>\n"
		else
			msg += "<span class='warning'>[t_He] в [bicon(handcuffed)] наручниках!</span>\n"

	//buckled TRANSLATE
	if(buckled)
		msg += "<span class='warning'>[t_He] [buckle_event] к [bicon(buckled)] [buckled]!</span>\n"

	//belt TRANSLATE
	if(belt)
		if(belt.blood_DNA)
			msg += "<span class='warning'>[t_He] носит [bicon(belt)] [belt.gender==PLURAL?"":""] испачканый [(belt.blood_color != "#030303") ? "кровью" : "топливом"] [belt.name] на талии!</span>\n"
		else if(belt.wet)
			msg += "<span class='wet'>[t_He] носит промокший [bicon(belt)] [belt.gender==PLURAL?"":""] [belt.name] на талии!</span>\n"
		else
			msg += "[t_He] носит [bicon(belt)] [belt] на талии.\n"

	//shoes TRANSLATE
	if(shoes && !skipshoes)
		if(shoes.blood_DNA)
			msg += "<span class='warning'>[t_He] носит [bicon(shoes)] [shoes.gender==PLURAL?"":""] испачканые [(shoes.blood_color != "#030303") ? "кровью" : "топливом"] [shoes.name] на ногах!</span>\n"
		else if(shoes.wet)
			msg += "<span class='wet'>[t_He] носит промокшие [bicon(shoes)] [shoes.gender==PLURAL?"":""] [shoes.name] на ногах!</span>\n"
		else
			msg += "[t_He] носит [bicon(shoes)] [shoes] на ногах.\n"
	else if(feet_blood_DNA)
		msg += "<span class='warning'>У [t_its] испачканые [(feet_blood_color != "#030303") ? "кровью" : "топливом"] ноги!</span>\n"

	//mask TRANSLATE
	if(wear_mask && !skipmask)
		if(wear_mask.blood_DNA)
			msg += "<span class='warning'>[t_He] носит [bicon(wear_mask)] [wear_mask.gender==PLURAL?"":""] испачканую [(wear_mask.blood_color != "#030303") ? "кровью" : "топливом"] [wear_mask.name] на лице!</span>\n"
		else if(wear_mask.wet)
			msg += "<span class='wet'>[t_He] носит промокшие [bicon(wear_mask)] [wear_mask.gender==PLURAL?"":""] [wear_mask.name] на лице!</span>\n"
		else
			msg += "[t_He] носит [bicon(wear_mask)] [wear_mask] на лице.\n"

	//eyes TRANSLATE
	if(glasses && !skipeyes)
		if(glasses.blood_DNA)
			msg += "<span class='warning'>[t_He] носит [bicon(glasses)] [glasses.gender==PLURAL?"":""] испачканые [(glasses.blood_color != "#030303") ? "кровью" : "топливом"] [glasses] на глазах!</span>\n"
		else if(glasses.wet)
			msg += "<span class='wet'>[t_He] носит мокрые [bicon(glasses)] [glasses.gender==PLURAL?"":""] [glasses] на глазах!</span>\n"
		else
			msg += "[t_He] носит [bicon(glasses)] [glasses] на глазах\n"

	//left ear TRANSLATE
	if(l_ear && !skipears)
		msg += "[t_He] носит [bicon(l_ear)] [l_ear] на левом ухе.\n"

	//right ear TRANSLATE
	if(r_ear && !skipears)
		msg += "[t_He] носит [bicon(r_ear)] [r_ear] на правом ухе.\n"

	//ID TRANSLATE
	if(wear_id)
		msg += "У [t_its] видна [bicon(wear_id)] [wear_id].\n"

	//Jitters TRANSLATE
	if(is_jittery)
		if(jitteriness >= 300)
			msg += "<span class='warning'><B>[t_He] сильно дрожит!</B></span>\n"
		else if(jitteriness >= 200)
			msg += "<span class='warning'>[t_He] нервно подёргиваетс&#255;.</span>\n"
		else if(jitteriness >= 100)
			msg += "<span class='warning'>[t_He] слегка дрожит.</span>\n"

	//splints TRANSLATE
	for(var/bodypart in list(BP_L_LEG , BP_R_LEG , BP_L_ARM , BP_R_ARM))
		var/obj/item/organ/external/BP = bodyparts_by_name[bodypart]
		if(BP && BP.status & ORGAN_SPLINTED)
			msg += "<span class='warning'>У [t_its] шина, установленна&#255; на [BP.name]!</span>\n"

	if(suiciding)
		msg += "<span class='warning'>С виду удачна&#255; попытка суицида... нет никакой надежды на выздоровление.</span>\n"

	if(SMALLSIZE in mutations)
		msg += "[t_He] маленького роста!\n"

	var/distance = get_dist(user,src)
	if(istype(user, /mob/dead/observer) || user.stat == DEAD) // ghosts can see anything
		distance = 1
	if (src.stat)
		msg += "<span class='warning'>[t_He] не реагирует ни на что вокруг себ&#255;, похоже на бесконечный сон...</span>\n"
		if((stat == DEAD || src.losebreath) && distance <= 3)
			msg += "<span class='warning'>[t_He] не дышит.</span>\n"
		if(istype(user, /mob/living/carbon/human) && !user.stat && distance <= 1)
			for(var/mob/O in viewers(user.loc, null))
				O.show_message("[user] проверяет пульс [src]", 1)
		spawn(15)
			if(distance <= 1 && user && user.stat != UNCONSCIOUS)
				if(pulse == PULSE_NONE)
					to_chat(user, "<span class='deadsay'>[t_He] не имеет пульса[src.client ? "" : ", и его душа уже давно покинула его тело."]...</span>")
				else
					to_chat(user, "<span class='deadsay'>[t_He] имеет пульс!</span>")

	msg += "<span class='warning'>"

	if(nutrition < 100)
		msg += "[t_He] имеет проблемы с нарушением питания.\n"
	else if(nutrition >= 500)
		msg += "[t_He] имеет серьёзные проблемы с лишним весом.\n"

	msg += "</span>"

	if(stat == UNCONSCIOUS)
		msg += "[t_He] не реагирует ни на что вокруг себ&#255;, похоже на бесконечный сон...\n"
	else if(getBrainLoss() >= 60)
		msg += "[t_He] имеет глупое выражение на лице.\n"

	if(!key && brain_op_stage != 4 && stat != DEAD)
		msg += "<span class='deadsay'>[t_He] [t_catatonics] в кататонический сон, возможно у [t_its] было слишком много стрессов в жизни...</span>\n"
	else if(!client && brain_op_stage != 4 && stat != DEAD)
		msg += "[t_He] внезапно [t_sleeping]...\n"

	var/list/wound_flavor_text = list()
	var/list/is_destroyed = list()
	var/list/is_bleeding = list()
	var/applying_pressure = ""

	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP)
			if(BP.status & ORGAN_DESTROYED)
				is_destroyed["[BP.name]"] = 1
				wound_flavor_text["[BP.name]"] = "<span class='warning'><b>У [t_its] утер&#255;на [BP.name].</b></span>\n"
				continue
			if(BP.applied_pressure)
				if(BP.applied_pressure == src)
					applying_pressure = "<span class='info'>[t_He] оказывает давление на [BP.name].</span><br>"
				else
					applying_pressure = "<span class='info'>[BP.applied_pressure] оказываемое давление на [BP.name].</span><br>"
			if(BP.status & ORGAN_ROBOT)
				if(!(BP.brute_dam + BP.burn_dam))
					if(!species.flags[IS_SYNTHETIC])
						wound_flavor_text["[BP.name]"] = "<span class='warning'>[t_He] имеет кибернетическую [BP.name]!</span>\n"
						continue
				else
					wound_flavor_text["[BP.name]"] = "<span class='warning'>[t_He] имеет кибернетическую [BP.name]"
				if(BP.brute_dam)
					switch(BP.brute_dam)
						if(0 to 20)
							wound_flavor_text["[BP.name]"] += " некоторые повреждени&#255;"
						if(21 to INFINITY)
							wound_flavor_text["[BP.name]"] += pick(" много повреждений"," т&#255;жёлые повреждени&#255;")
				if(BP.brute_dam && BP.burn_dam)
					wound_flavor_text["[BP.name]"] += " и"
				if(BP.burn_dam)
					switch(BP.burn_dam)
						if(0 to 20)
							wound_flavor_text["[BP.name]"] += " некоторые ожоги"
						if(21 to INFINITY)
							wound_flavor_text["[BP.name]"] += pick(" много ожогов"," т&#255;жёлые ожоги")
				if(wound_flavor_text["[BP.name]"])
					wound_flavor_text["[BP.name]"] += "!</span>\n"
			else if(BP.wounds.len > 0)
				var/list/wound_descriptors = list()
				for(var/datum/wound/W in BP.wounds)
					var/this_wound_desc = W.desc
					if(W.damage_type == BURN && W.salved) this_wound_desc = "salved [this_wound_desc]"
					if(W.bleeding()) this_wound_desc = "bleeding [this_wound_desc]"
					else if(W.bandaged) this_wound_desc = "bandaged [this_wound_desc]"
					if(W.germ_level > 600) this_wound_desc = "badly infected [this_wound_desc]"
					else if(W.germ_level > 330) this_wound_desc = "lightly infected [this_wound_desc]"
					if(this_wound_desc in wound_descriptors)
						wound_descriptors[this_wound_desc] += W.amount
						continue
					wound_descriptors[this_wound_desc] = W.amount
				if(wound_descriptors.len)
					var/list/flavor_text = list()
					var/list/no_exclude = list("gaping wound", "big gaping wound", "massive wound", "large bruise",\
					"huge bruise", "massive bruise", "severe burn", "large burn", "deep burn", "carbonised area")
					for(var/wound in wound_descriptors)
						switch(wound_descriptors[wound])
							if(1)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] has[prob(10) && !(wound in no_exclude)  ? " what might be" : ""] a [wound]"
								else
									flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a [wound]"
							if(2)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] has[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
								else
									flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
							if(3 to 5)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] has several [wound]s"
								else
									flavor_text += " several [wound]s"
							if(6 to INFINITY)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] has a bunch of [wound]s"
								else
									flavor_text += " a ton of [wound]\s"
					var/flavor_text_string = ""
					for(var/text = 1, text <= flavor_text.len, text++)
						if(text == flavor_text.len && flavor_text.len > 1)
							flavor_text_string += ", and"
						else if(flavor_text.len > 1 && text > 1)
							flavor_text_string += ","
						flavor_text_string += flavor_text[text]
					flavor_text_string += " on [t_his] [BP.name].</span><br>"
					wound_flavor_text["[BP.name]"] = flavor_text_string
				else
					wound_flavor_text["[BP.name]"] = ""
				if(BP.status & ORGAN_BLEEDING)
					is_bleeding["[BP.name]"] = 1
			else
				wound_flavor_text["[BP.name]"] = ""

	//Handles the text strings being added to the actual description.
	//If they have something that covers the limb, and it is not missing, put flavortext.  If it is covered but bleeding, add other flavortext.
	var/display_chest = 0
	var/display_shoes = 0
	var/display_gloves = 0
	if(wound_flavor_text["head"] && (is_destroyed["head"] || (!skipmask && !(wear_mask && istype(wear_mask, /obj/item/clothing/mask/gas)))))
		msg += wound_flavor_text["head"]
	else if(is_bleeding["head"])
		msg += "<span class='warning'>[src] кровь бежит по лицу!</span>\n"
	if(wound_flavor_text["chest"] && !w_uniform && !skipjumpsuit) //No need.  A missing chest gibs you.
		msg += wound_flavor_text["chest"]
	else if(is_bleeding["chest"])
		display_chest = 1
	if(wound_flavor_text["left arm"] && (is_destroyed["left arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["left arm"]
	else if(is_bleeding["left arm"])
		display_chest = 1
	if(wound_flavor_text["left hand"] && (is_destroyed["left hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["left hand"]
	else if(is_bleeding["left hand"])
		display_gloves = 1
	if(wound_flavor_text["right arm"] && (is_destroyed["right arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["right arm"]
	else if(is_bleeding["right arm"])
		display_chest = 1
	if(wound_flavor_text["right hand"] && (is_destroyed["right hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["right hand"]
	else if(is_bleeding["right hand"])
		display_gloves = 1
	if(wound_flavor_text["groin"] && (is_destroyed["groin"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["groin"]
	else if(is_bleeding["groin"])
		display_chest = 1
	if(wound_flavor_text["left leg"] && (is_destroyed["left leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["left leg"]
	else if(is_bleeding["left leg"])
		display_chest = 1
	if(wound_flavor_text["left foot"]&& (is_destroyed["left foot"] || (!shoes && !skipshoes)))
		msg += wound_flavor_text["left foot"]
	else if(is_bleeding["left foot"])
		display_shoes = 1
	if(wound_flavor_text["right leg"] && (is_destroyed["right leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["right leg"]
	else if(is_bleeding["right leg"])
		display_chest = 1
	if(wound_flavor_text["right foot"]&& (is_destroyed["right foot"] || (!shoes  && !skipshoes)))
		msg += wound_flavor_text["right foot"]
	else if(is_bleeding["right foot"])
		display_shoes = 1
	if(display_chest)
		msg += "<span class='warning'><b>[src] has blood soaking through from under [t_his] clothing!</b></span>\n"
	if(display_shoes)
		msg += "<span class='warning'><b>[src] has blood running from [t_his] shoes!</b></span>\n"
	if(display_gloves)
		msg += "<span class='warning'><b>[src] has blood running from under [t_his] gloves!</b></span>\n"

	for(var/implant in get_visible_implants(1))
		msg += "<span class='warning'><b>[src] has \a [implant] sticking out of their flesh!</b></span>\n"
	if(digitalcamo)
		msg += "<span class='warning'>[t_He] [t_is] moving [t_his] body in an unnatural and blatantly inhuman manner.</span>\n"
	if(mind && mind.changeling && mind.changeling.isabsorbing)
		msg += "<span class='warning'><b>[t_He] sucking fluids from someone through a giant proboscis!</b></span>\n"



	if(hasHUD(user,"security"))
		var/perpname = "wot"
		var/criminal = "None"

		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
		else
			perpname = name

		if(perpname)
			for (var/datum/data/record/E in data_core.general)
				if(E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if(R.fields["id"] == E.fields["id"])
							criminal = R.fields["criminal"]

			msg += "<span class = 'deptradio'>Criminal status:</span> <a href='?src=\ref[src];criminal=1'>\[[criminal]\]</a>\n"
			msg += "<span class = 'deptradio'>Security records:</span> <a href='?src=\ref[src];secrecord=`'>\[View\]</a>  <a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>\n"

	if(hasHUD(user,"medical"))
		var/perpname = "wot"
		var/medical = "None"

		if(wear_id)
			if(istype(wear_id,/obj/item/weapon/card/id))
				perpname = wear_id:registered_name
			else if(istype(wear_id,/obj/item/device/pda))
				var/obj/item/device/pda/tempPda = wear_id
				perpname = tempPda.owner
		else
			perpname = src.name

		for (var/datum/data/record/E in data_core.general)
			if (E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.general)
					if (R.fields["id"] == E.fields["id"])
						medical = R.fields["p_stat"]

		msg += "<span class = 'deptradio'>Physical status:</span> <a href='?src=\ref[src];medical=1'>\[[medical]\]</a>\n"
		msg += "<span class = 'deptradio'>Medical records:</span> <a href='?src=\ref[src];medrecord=`'>\[View\]</a> <a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>\n"

	if(print_flavor_text()) msg += "[print_flavor_text()]\n"
	if(Growth && Weight)
		msg += "\blue[t_his2] рост : [Growth]\n[t_his2] вес : [Weight]\n [t_his2] телосложение : [body_type]\n"
	msg += "*---------*</span><br>"
	if(applying_pressure)
		msg += applying_pressure
	else if(busy_with_action)
		msg += "<span class='info'>[t_He] is busy with something!</span><br>"
	if (pose)
		if( findtext(pose,".",lentext(pose)) == 0 && findtext(pose,"!",lentext(pose)) == 0 && findtext(pose,"?",lentext(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\n[t_He] is [pose]"

	//someone here, but who?
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species && H.species.name != ABDUCTOR)
			for(var/obj/item/clothing/suit/armor/abductor/vest/V in list(wear_suit))
				if(V.stealth_active)
					to_chat(H, "<span class='notice'>You can't focus your eyes on [src].</span>")
					return
	to_chat(user, msg)

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M, hudtype)
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		switch(hudtype)
			if("security")
				return istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud)
			if("medical")
				return istype(H.glasses, /obj/item/clothing/glasses/hud/health)
			else
				return 0
	else if(istype(M, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		switch(hudtype)
			if("security")
				return istype(R.module_state_1, /obj/item/borg/sight/hud/sec) || istype(R.module_state_2, /obj/item/borg/sight/hud/sec) || istype(R.module_state_3, /obj/item/borg/sight/hud/sec)
			if("medical")
				return istype(R.module_state_1, /obj/item/borg/sight/hud/med) || istype(R.module_state_2, /obj/item/borg/sight/hud/med) || istype(R.module_state_3, /obj/item/borg/sight/hud/med)
			else
				return 0
	else
		return 0
