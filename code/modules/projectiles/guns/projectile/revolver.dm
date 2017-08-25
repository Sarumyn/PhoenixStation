/obj/item/weapon/gun/projectile/revolver
	desc = "A classic revolver. Uses 357 ammo."
	name = "revolver"
	icon_state = "revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder
	fire_sound = 'sound/weapons/guns/revolver_shot.ogg'

/obj/item/weapon/gun/projectile/revolver/chamber_round()
	if (chambered || !magazine)
		return
	else if (magazine.ammo_count())
		chambered = magazine.get_round(1)
	return

/obj/item/weapon/gun/projectile/revolver/process_chamber()
	return ..(0, 1)

/obj/item/weapon/gun/projectile/revolver/attackby(obj/item/A, mob/user)
	var/num_loaded = magazine.attackby(A, user, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src].</span>")
		A.update_icon()
		update_icon()
		chamber_round()

/obj/item/weapon/gun/projectile/revolver/attack_self(mob/living/user)
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.SpinAnimation(10, 1)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		to_chat(user, "<span class = 'notice'>You unload [num_unloaded] shell\s from [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")

/obj/item/weapon/gun/projectile/revolver/get_ammo(countchambered = 0, countempties = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/weapon/gun/projectile/revolver/examine(mob/user)
	..()
	to_chat(user, "[get_ammo(0,0)] of those are live rounds.")

/obj/item/weapon/gun/projectile/revolver/detective
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = "revolver"
	icon_state = "detective"
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38


/obj/item/weapon/gun/projectile/revolver/detective/special_check(mob/living/carbon/human/M)
	if(magazine.caliber == initial(magazine.caliber))
		return 1
	if(prob(70 - (magazine.ammo_count() * 10)))	//minimum probability of 10, maximum of 60
		to_chat(M, "<span class='danger'>[src] blows up in your face!</span>")
		M.take_bodypart_damage(0, 20)
		M.drop_item()
		qdel(src)
		return 0
	return 1

/obj/item/weapon/gun/projectile/revolver/detective/verb/rename_gun()
	set name = "Name Gun"
	set category = "Object"
	set desc = "Click to rename your gun."

	var/mob/M = usr
	var/input = stripped_input(M,"What do you want to name the gun?", ,"", MAX_NAME_LEN)

	if(src && input && !M.stat && in_range(M,src))
		name = input
		to_chat(M, "You name the gun [input]. Say hello to your new friend.")
		return 1

/obj/item/weapon/gun/projectile/revolver/detective/attackby(obj/item/A, mob/user)
	..()
	if(istype(A, /obj/item/weapon/screwdriver))
		if(magazine.caliber == "38")
			to_chat(user, "<span class='notice'>You begin to reinforce the barrel of [src].</span>")
			if(magazine.ammo_count())
				afterattack(user, user)	//you know the drill
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
				return
			if(do_after(user, 30, target = src))
				if(magazine.ammo_count())
					to_chat(user, "<span class='notice'>You can't modify it!</span>")
					return
				magazine.caliber = "357"
				desc = "The barrel and chamber assembly seems to have been modified."
				to_chat(user, "<span class='warning'>You reinforce the barrel of [src]! Now it will fire .357 rounds.</span>")
		else
			to_chat(user, "<span class='notice'>You begin to revert the modifications to [src].</span>")
			if(magazine.ammo_count())
				afterattack(user, user)	//and again
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
				return
			if(do_after(user, 30, target = src))
				if(magazine.ammo_count())
					to_chat(user, "<span class='notice'>You can't modify it!</span>")
					return
				magazine.caliber = "38"
				desc = initial(desc)
				to_chat(user, "<span class='warning'>You remove the modifications on [src]! Now it will fire .38 rounds.</span>")

/obj/item/weapon/gun/projectile/revolver/mateba
	name = "mateba"
	desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"
	origin_tech = "combat=2;materials=2"

// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/weapon/gun/projectile/revolver/russian
	name = "Russian Revolver"
	desc = "A Russian made revolver. Uses .357 ammo. It has a single slot in its chamber for a bullet."
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rus357
	var/spun = 0

/obj/item/weapon/gun/projectile/revolver/russian/New()
	..()
	Spin()
	update_icon()

/obj/item/weapon/gun/projectile/revolver/russian/proc/Spin()
	chambered = null
	var/random = rand(1, magazine.max_ammo)
	if(random <= get_ammo(0,0))
		chamber_round()
	spun = 1

/obj/item/weapon/gun/projectile/revolver/russian/attackby(obj/item/A, mob/user)
	var/num_loaded = ..()
	if(num_loaded)
		user.visible_message("<span class='warning'>[user] loads a single bullet into the revolver and spins the chamber.</span>", "<span class='warning'>You load a single bullet into the chamber and spin it.</span>")
	else
		user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
	if(get_ammo() > 0)
		Spin()
	update_icon()
	A.update_icon()
	return

/obj/item/weapon/gun/projectile/revolver/russian/attack_self(mob/user)
	if(!spun && get_ammo(0,0))
		user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
		Spin()
	else
		var/num_unloaded = 0
		while (get_ammo() > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round()
			chambered = null
			CB.loc = get_turf(src.loc)
			CB.update_icon()
			num_unloaded++
		if (num_unloaded)
			to_chat(user, "<span class = 'notice'>You unload [num_unloaded] shell\s from [src]!</span>")
		else
			to_chat(user, "<span class='notice'>[src] is empty.</span>")

/obj/item/weapon/gun/projectile/revolver/russian/afterattack(atom/target, mob/living/user, flag, params)
	if(!spun && get_ammo(0,0))
		user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
		Spin()
	..()
	spun = 0

/obj/item/weapon/gun/projectile/revolver/russian/attack(atom/target, mob/living/user)
	if(!spun && get_ammo(0,0))
		user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
		Spin()
		return


	if(target == user)
		if(!chambered)
			user.visible_message("\red *click*", "\red *click*")
			return

		if(isliving(target) && isliving(user))
			var/target_zone = user.zone_sel.selecting
			if(target_zone == BP_HEAD)
				var/obj/item/ammo_casing/AC = chambered
				if(AC.fire(user, user))
					user.apply_damage(300, BRUTE, target_zone, null, DAM_SHARP)
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[user.name] fires [src] at \his head!</span>", "<span class='danger'>You fire [src] at your head!</span>", "You hear a [istype(AC.BB, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
					return
				else
					user.visible_message("\red *click*", "\red *click*")
					return
	..()

/obj/item/weapon/gun/projectile/revolver/peacemaker
	name = "Colt SAA"
	desc = "A legend of Wild West."
	icon_state = "peacemaker"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev45

/obj/item/weapon/gun/projectile/revolver/peacemaker/isHandgun()
	return 1

/obj/item/weapon/gun/projectile/revolver/peacemaker/attack_self(mob/living/user)
	var/num_unloaded = 0
	if (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		to_chat(user, "<span class = 'notice'>You unload [num_unloaded] shell\s from [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")

/obj/item/weapon/gun/projectile/revolver/flare
	name = "flare gun"
	desc = "Fires flares."
	icon_state = "flaregun"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/flaregun

/obj/item/weapon/gun/projectile/revolver/detective/dungeon
	desc = "A a six-shot double-action revolver."
	name = "Smith & Wesson Model 10"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/dungeon

/obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/dualshot/dungeon

/obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon/sawn_off
	icon_state = "sawnshotgun"
	w_class = 3.0
	slot_flags = SLOT_BELT
	name = "sawn-off shotgun"
	desc = "Omar's coming!"
	short = 1

/obj/item/weapon/gun/projectile/revolver/syndie
	name = "revolver"
	desc = "A powerful revolver, very popular among mercenaries and pirates. Uses .357 ammo."
	icon_state = "synd_revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder