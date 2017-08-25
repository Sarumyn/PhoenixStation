/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	flags = OPENCONTAINER
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/amount_per_transfer_from_this = 10
	var/possible_transfer_amounts = list(10,25,50,100)

/obj/structure/reagent_dispensers/attackby(obj/item/weapon/W, mob/user)
	return

/obj/structure/reagent_dispensers/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	if (!possible_transfer_amounts)
		src.verbs -= /obj/structure/reagent_dispensers/verb/set_APTFT
	..()

/obj/structure/reagent_dispensers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in view(1)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/structure/reagent_dispensers/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		else
	return

/obj/structure/reagent_dispensers/blob_act()
	if(prob(50))
		new /obj/effect/effect/water(src.loc)
		qdel(src)


//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10
	var/modded = 0

/obj/structure/reagent_dispensers/watertank/New()
	..()
	reagents.add_reagent("water",1000)

/obj/structure/reagent_dispensers/watertank/examine(mob/user)
	..()
	if(src in oview(2, user) && modded)
		to_chat(user, "\red Water faucet is wrenched open, leaking the water!")

/obj/structure/reagent_dispensers/watertank/attackby(obj/item/weapon/W, mob/user)
	if (istype(W,/obj/item/weapon/wrench))
		user.visible_message("[user] wrenches [src]'s faucet [modded ? "closed" : "open"].", \
			"You wrench [src]'s faucet [modded ? "closed" : "open"]")
		modded = modded ? 0 : 1
		if (modded)
			START_PROCESSING(SSobj, src)
			leak_water(amount_per_transfer_from_this)

	add_fingerprint(usr)
	return ..()

/obj/structure/reagent_dispensers/watertank/process()
	if(!src) return
	if(modded)
		leak_water(2)
	else
		STOP_PROCESSING(SSobj, src)

/obj/structure/reagent_dispensers/watertank/Move()
	if (..() && modded)
		leak_water(1)

/obj/structure/reagent_dispensers/watertank/proc/leak_water(amount)
	if (reagents.total_volume == 0)
		return

	amount = min(amount, reagents.total_volume)
	reagents.remove_reagent("water",amount)
	spawn_fluid(loc, amount * 50)

/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank."
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10
	var/modded = 0
	var/obj/item/device/assembly_holder/rig = null

/obj/structure/reagent_dispensers/fueltank/New()
	..()
	var/datum/reagents/R = new/datum/reagents(300)
	reagents = R
	R.my_atom = src
	if(!possible_transfer_amounts)
		src.verbs -= /obj/structure/reagent_dispensers/verb/set_APTFT
	reagents.add_reagent("fuel",300)

/obj/structure/reagent_dispensers/fueltank/examine(mob/user)
	..()
	if(src in oview(2, user))
		if (modded)
			to_chat(user, "<span class='red'>Fuel faucet is wrenched open, leaking the fuel!</span>")
		if(rig)
			to_chat(user, "<span class='notice'>There is some kind of device rigged to the tank.</span>")

/obj/structure/reagent_dispensers/fueltank/attack_hand()
	if (rig)
		usr.visible_message("[usr] begins to detach [rig] from \the [src].", "You begin to detach [rig] from \the [src]")
		if(do_after(usr, 20, target = src))
			usr.visible_message("\blue [usr] detaches [rig] from \the [src].", "\blue  You detach [rig] from \the [src]")
			rig.loc = get_turf(usr)
			rig = null
			overlays = new/list()

/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/weapon/W, mob/user)
	if (istype(W,/obj/item/weapon/wrench))
		user.visible_message("[user] wrenches [src]'s faucet [modded ? "closed" : "open"].", \
			"You wrench [src]'s faucet [modded ? "closed" : "open"]")
		modded = modded ? 0 : 1
		if (modded)
			leak_fuel(amount_per_transfer_from_this)
	if (istype(W,/obj/item/device/assembly_holder))
		if (rig)
			to_chat(user, "\red There is another device in the way.")
			return ..()
		user.visible_message("[user] begins rigging [W] to \the [src].", "You begin rigging [W] to \the [src]")
		if(do_after(user, 20, target = src))
			user.visible_message("\blue [user] rigs [W] to \the [src].", "\blue  You rig [W] to \the [src]")

			var/obj/item/device/assembly_holder/H = W
			if (istype(H.a_left,/obj/item/device/assembly/igniter) || istype(H.a_right,/obj/item/device/assembly/igniter))
				message_admins("[key_name_admin(user)] rigged fueltank at ([loc.x],[loc.y],[loc.z]) for explosion. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
				log_game("[key_name(user)] rigged fueltank at ([loc.x],[loc.y],[loc.z]) for explosion.")

			rig = W
			user.drop_item()
			W.loc = src

			var/icon/test = getFlatIcon(W)
			test.Shift(NORTH,1)
			test.Shift(EAST,6)
			overlays += test

	add_fingerprint(usr)
	return ..()


/obj/structure/reagent_dispensers/fueltank/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if(!istype(Proj ,/obj/item/projectile/beam/lastertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			explode()

/obj/structure/reagent_dispensers/fueltank/blob_act()
	explode()

/obj/structure/reagent_dispensers/fueltank/ex_act()
	explode()

/obj/structure/reagent_dispensers/fueltank/proc/explode()
	if (reagents.total_volume > 500)
		explosion(src.loc,1,2,4)
	else if (reagents.total_volume > 100)
		explosion(src.loc,0,1,3)
	else
		explosion(src.loc,-1,1,2)
	if(src)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank/fire_act(datum/gas_mixture/air, temperature, volume)
	if(temperature > T0C+500)
		explode()
	return ..()

/obj/structure/reagent_dispensers/fueltank/tesla_act()
	..() //extend the zap
	explode()

/obj/structure/reagent_dispensers/fueltank/Move()
	if (..() && modded)
		leak_fuel(amount_per_transfer_from_this/10.0)

/obj/structure/reagent_dispensers/fueltank/proc/leak_fuel(amount)
	if (reagents.total_volume == 0)
		return

	amount = min(amount, reagents.total_volume)
	reagents.remove_reagent("fuel",amount)
	new /obj/effect/decal/cleanable/liquid_fuel(src.loc, amount)



/obj/structure/reagent_dispensers/peppertank
	name = "Pepper Spray Refiller"
	desc = "Refill pepper spray canisters."
	icon = 'icons/obj/objects.dmi'
	icon_state = "peppertank"
	anchored = 1
	density = 0
	amount_per_transfer_from_this = 45

/obj/structure/reagent_dispensers/peppertank/New()
	..()
	reagents.add_reagent("condensedcapsaicin",1000)



/obj/structure/reagent_dispensers/water_cooler
	name = "Water-Cooler"
	desc = "A machine that dispenses water to drink."
	amount_per_transfer_from_this = 5
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	possible_transfer_amounts = null
	anchored = 1

/obj/structure/reagent_dispensers/water_cooler/New()
	..()
	reagents.add_reagent("water",500)


/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg."
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/beerkeg/New()
	..()
	reagents.add_reagent("beer",1000)

/obj/structure/reagent_dispensers/beerkeg/blob_act()
	explosion(src.loc,0,3,5,7,10)
	qdel(src)

/obj/structure/reagent_dispensers/virusfood
	name = "Virus Food Dispenser"
	desc = "A dispenser of virus food."
	icon = 'icons/obj/objects.dmi'
	icon_state = "virusfoodtank"
	amount_per_transfer_from_this = 10
	anchored = 1

/obj/structure/reagent_dispensers/virusfood/New()
	..()
	reagents.add_reagent("virusfood", 1000)

/obj/structure/reagent_dispensers/acid
	name = "Sulphuric Acid Dispenser"
	desc = "A dispenser of acid for industrial processes."
	icon = 'icons/obj/objects.dmi'
	icon_state = "acidtank"
	amount_per_transfer_from_this = 10
	anchored = 1

/obj/structure/reagent_dispensers/acid/New()
	..()
	reagents.add_reagent("sacid", 1000)