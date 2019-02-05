/obj/item/projectile/animate
	name = "bolt of animation"
	icon_state = "ice_1"
	light_color = "#00bfff"
	light_power = 2
	light_range = 2
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"

/obj/item/projectile/animate/Bump(atom/change)
	if((istype(change, /obj/item) || istype(change, /obj/structure)) && !is_type_in_list(change, protected_objects))
		var/obj/O = change
		new /mob/living/simple_animal/hostile/mimic/copy(O.loc, O, firer)
	..()
