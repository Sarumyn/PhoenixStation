//update_state
#define UPSTATE_CELL_IN 1
#define UPSTATE_OPENED1 2
#define UPSTATE_OPENED2 4
#define UPSTATE_MAINT 8
#define UPSTATE_BROKE 16
#define UPSTATE_BLUESCREEN 32
#define UPSTATE_WIREEXP 64
#define UPSTATE_ALLGOOD 128
#define UPSTATE_INFECTED 256
#define UPSTATE_INFECTED2 512
#define UPSTATE_INFECTED3 1024
#define UPSTATE_INFECTED4 2048
#define UPSTATE_INFECTED5 4096
#define UPSTATE_INFECTED6 8192

//update_overlay
#define APC_UPOVERLAY_CHARGEING0 1
#define APC_UPOVERLAY_CHARGEING1 2
#define APC_UPOVERLAY_CHARGEING2 4
#define APC_UPOVERLAY_EQUIPMENT0 8
#define APC_UPOVERLAY_EQUIPMENT1 16
#define APC_UPOVERLAY_EQUIPMENT2 32
#define APC_UPOVERLAY_LIGHTING0 64
#define APC_UPOVERLAY_LIGHTING1 128
#define APC_UPOVERLAY_LIGHTING2 256
#define APC_UPOVERLAY_ENVIRON0 512
#define APC_UPOVERLAY_ENVIRON1 1024
#define APC_UPOVERLAY_ENVIRON2 2048
#define APC_UPOVERLAY_LOCKED 4096
#define APC_UPOVERLAY_OPERATING 8192

#define APC_UPDATE_ICON_COOLDOWN 100 // 10 seconds


// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire conection to power network

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


//NOTE: STUFF STOLEN FROM AIRLOCK.DM thx


/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."
	icon = 'icons/obj/power.dmi'
	icon_state = "apc0"
	anchored = 1
	use_power = 0
	req_access = list(access_engine_equip)
	var/area/area
	var/areastring = null
	var/obj/item/weapon/stock_parts/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = 5000				// 0=no cell, 1=regular, 2=high-cap (x5) <- old, now it's just 0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
	var/opened = 0 //0=closed, 1=opened, 2=cover removed
	var/shorted = 0
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = 1
	var/charging = 0
	var/chargemode = 1
	var/chargecount = 0
	var/locked = 1
	var/coverlocked = 1
	var/aidisabled = 0
	var/tdir = null
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	var/wiresexposed = 0
	powernet = 0		// set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/malfhack = 0 //New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
	var/debug= 0
	var/autoflag= 0		// 0 = off, 1= eqp and lights off, 2 = eqp off, 3 = all on.
//	luminosity = 1
	var/has_electronics = 0 // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/overload = 1 //used for the Blackout malf module
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
	var/mob/living/silicon/ai/occupier = null
	var/longtermpower = 10
	var/update_state = -1
	var/update_overlay = -1
	var/global/status_overlays = 0
	var/updating_icon = 0
	var/datum/wires/apc/wires = null
	var/global/list/status_overlays_lock
	var/global/list/status_overlays_charging
	var/global/list/status_overlays_equipment
	var/global/list/status_overlays_lighting
	var/global/list/status_overlays_environ
	//var/datum/malware/malware_injection/malw

/obj/machinery/power/apc/updateDialog()
	if (stat & (BROKEN|MAINT))
		return
	..()

/obj/machinery/power/apc/New(turf/loc, ndir, building=0)
	..()

	wires = new(src)

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir
	src.tdir = dir		// to fix Vars bug
	dir = SOUTH

	pixel_x = (src.tdir & 3)? 0 : (src.tdir == 4 ? 24 : -24)
	pixel_y = (src.tdir & 3)? (src.tdir ==1 ? 24 : -24) : 0
	if (building==0)
		init()
	else
		area = src.loc.loc:master
		area.apc = src
		opened = 1
		operating = 0
		name = "[area.name] APC"
		stat |= MAINT
		src.update_icon()
		addtimer(CALLBACK(src, .proc/update), 5)

/obj/machinery/power/apc/Destroy()
	if(malfai && operating)
		if (ticker.mode.config_tag == "malfunction")
			if (src.z == ZLEVEL_STATION) //if (is_type_in_list(get_area(src), the_station_areas))
				ticker.mode:apcs--
	area.apc = null
	area.power_light = 0
	area.power_equip = 0
	area.power_environ = 0
	area.power_change()
	/*if(occupier)
		malfvacate(1)*/
	QDEL_NULL(wires)
	QDEL_NULL(cell)
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/apc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.dir = tdir
	terminal.master = src

/obj/machinery/power/apc/proc/init()
	has_electronics = 2 //installed and secured
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		src.cell = new/obj/item/weapon/stock_parts/cell(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100.0 		// (convert percentage to actual value)

	var/area/A = src.loc.loc


	//if area isn't specified use current
	if(isarea(A) && src.areastring == null)
		src.area = A
		name = "\improper [area.name] APC"
	else
		src.area = get_area_name(areastring)
		name = "\improper [area.name] APC"
	area.apc = src
	update_icon()

	make_terminal()

	addtimer(CALLBACK(src, .proc/update), 5)

/obj/machinery/power/apc/examine(mob/user)
	..()
	if(src in oview(1, user))
		if(stat & BROKEN)
			to_chat(user, "Looks broken.")
			return
		if(opened)
			if(has_electronics && terminal)
				to_chat(user, "The cover is [opened==2?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"].")
			else if (!has_electronics && terminal)
				to_chat(user, "There are some wires but no any electronics.")
			else if (has_electronics && !terminal)
				to_chat(user, "Electronics installed but not wired.")
			else /* if (!has_electronics && !terminal) */
				to_chat(user, "There is no electronics nor connected wires.")
		else
			if (stat & MAINT)
				to_chat(user, "The cover is closed. Something wrong with it: it doesn't work.")
			else if (malfhack)
				to_chat(user, "The cover is broken. It may be hard to force it open.")
			else
				to_chat(user, "The cover is closed.")

// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_icon()

	if (!status_overlays)
		status_overlays = 1
		status_overlays_lock = new
		status_overlays_charging = new
		status_overlays_equipment = new
		status_overlays_lighting = new
		status_overlays_environ = new

		status_overlays_lock.len = 2
		status_overlays_charging.len = 3
		status_overlays_equipment.len = 4
		status_overlays_lighting.len = 4
		status_overlays_environ.len = 4

		status_overlays_lock[1] = image(icon, "apcox-0")    // 0=blue 1=red
		status_overlays_lock[2] = image(icon, "apcox-1")

		status_overlays_charging[1] = image(icon, "apco3-0")
		status_overlays_charging[2] = image(icon, "apco3-1")
		status_overlays_charging[3] = image(icon, "apco3-2")

		status_overlays_equipment[1] = image(icon, "apco0-0") // 0=red, 1=green, 2=blue
		status_overlays_equipment[2] = image(icon, "apco0-1")
		status_overlays_equipment[3] = image(icon, "apco0-2")
		status_overlays_equipment[4] = image(icon, "apco0-3")

		status_overlays_lighting[1] = image(icon, "apco1-0")
		status_overlays_lighting[2] = image(icon, "apco1-1")
		status_overlays_lighting[3] = image(icon, "apco1-2")
		status_overlays_lighting[4] = image(icon, "apco1-3")

		status_overlays_environ[1] = image(icon, "apco2-0")
		status_overlays_environ[2] = image(icon, "apco2-1")
		status_overlays_environ[3] = image(icon, "apco2-2")
		status_overlays_environ[4] = image(icon, "apco2-3")



	var/update = check_updates() 		//returns 0 if no need to update icons.
						// 1 if we need to update the icon_state
						// 2 if we need to update the overlays
	if(!update)
		return

	if(update & 1) // Updating the icon state
		if(update_state & UPSTATE_ALLGOOD)
			icon_state = "apc0"
		else if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
			var/basestate = "apc[ cell ? "2" : "1" ]"
			if(update_state & UPSTATE_OPENED1)
				if(update_state & (UPSTATE_MAINT|UPSTATE_BROKE))
					icon_state = "apcmaint" //disabled APC cannot hold cell
				else
					icon_state = basestate
			else if(update_state & UPSTATE_OPENED2)
				icon_state = "[basestate]-nocover"
		else if(update_state & UPSTATE_BROKE)
			icon_state = "apc-b"
		else if(update_state & UPSTATE_BLUESCREEN)
			icon_state = "apcemag"
	//	else if(update_state & UPSTATE_INFECTED) //UPDATE MALWARED
	//		icon_state = "apcinfect1"
	//	else if(update_state & UPSTATE_INFECTED2) //UPDATE MALWARED
	//		icon_state = "apcinfect2"
	//	else if(update_state & UPSTATE_INFECTED3) //UPDATE MALWARED
	//		icon_state = "apcinfect3"
	//	else if(update_state & UPSTATE_INFECTED4) //UPDATE MALWARED
	//		icon_state = "apcinfect4"
	//	else if(update_state & UPSTATE_INFECTED5) //UPDATE MALWARED
	//		icon_state = "apcinfect5"
	//	else if(update_state & UPSTATE_INFECTED6) //UPDATE MALWARED
	//		icon_state = "apcinfect6"
		else if(update_state & UPSTATE_WIREEXP)
			icon_state = "apcewires"



	if(!(update_state & UPSTATE_ALLGOOD))
		if(overlays.len)
			overlays = 0
			return



	if(update & 2)

		if(overlays.len)
			overlays = 0

		if(!(stat & (BROKEN|MAINT)) && update_state & UPSTATE_ALLGOOD)
			overlays += status_overlays_lock[locked+1]
			overlays += status_overlays_charging[charging+1]
			if(operating)
				overlays += status_overlays_equipment[equipment+1]
				overlays += status_overlays_lighting[lighting+1]
				overlays += status_overlays_environ[environ+1]


/obj/machinery/power/apc/proc/check_updates()

	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = 0
	update_overlay = 0

	if(cell)
		update_state |= UPSTATE_CELL_IN
	if(stat & BROKEN)
		update_state |= UPSTATE_BROKE
	if(stat & MAINT)
		update_state |= UPSTATE_MAINT
	if(opened)
		if(opened==1)
			update_state |= UPSTATE_OPENED1
		if(opened==2)
			update_state |= UPSTATE_OPENED2
	else if(emagged || malfai)
		update_state |= UPSTATE_BLUESCREEN
	//else if(infected == 1) //UPDATE MALWARE
	//	update_state |= UPSTATE_INFECTED
	//else if(infected == 2) //UPDATE MALWARE
	//	update_state |= UPSTATE_INFECTED2
//	else if(infected == 3) //UPDATE MALWARE
	//	update_state |= UPSTATE_INFECTED3
	//else if(infected == 4) //UPDATE MALWARE
	//	update_state |= UPSTATE_INFECTED4
	//else if(infected == 5) //UPDATE MALWARE
	//	update_state |= UPSTATE_INFECTED5
	//else if(infected == 6) //UPDATE MALWARE
	//	update_state |= UPSTATE_INFECTED6
	else if(wiresexposed)
		update_state |= UPSTATE_WIREEXP
	if(update_state <= 1)
		update_state |= UPSTATE_ALLGOOD

	if(operating)
		update_overlay |= APC_UPOVERLAY_OPERATING

	if(update_state & UPSTATE_ALLGOOD)
		if(locked)
			update_overlay |= APC_UPOVERLAY_LOCKED

		if(!charging)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == 1)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == 2)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if (!equipment)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment == 1)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment == 2)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(!lighting)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting == 1)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting == 2)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(!environ)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environ==1)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environ==2)
			update_overlay |= APC_UPOVERLAY_ENVIRON2

	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
	if(last_update_overlay != update_overlay && update_overlay != 0)
		results += 2
	return results

/obj/machinery/power/apc/proc/queue_icon_update()
	set waitfor = FALSE
	if(!updating_icon)
		updating_icon = 1
		// Start the update
		sleep(APC_UPDATE_ICON_COOLDOWN)
		update_icon()
		updating_icon = 0


//attack with an item - open/close cover, insert cell, or (un)lock interface

/obj/machinery/power/apc/attackby(obj/item/W, mob/user)

	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return src.attack_hand(user)
	//else if (istype(user, /obj/item/device/malware_injector))
	//	return
	src.add_fingerprint(user)
	if (istype(W, /obj/item/weapon/crowbar) && opened)
		if (has_electronics==1)
			if (terminal)
				to_chat(user, "\red Disconnect wires first.")
				return
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			to_chat(user, "You are trying to remove the power control board...")//lpeters - fixed grammar issues
			if(do_after(user, 50, target = src))
				has_electronics = 0
				if ((stat & BROKEN) || malfhack)
					user.visible_message(\
						"\red [user.name] has broken the power control board inside [src.name]!",\
						"You broke the charred power control board and remove the remains.",
						"You hear a crack!")
					//ticker.mode:apcs-- //XSI said no and I agreed. -rastaf0
				else
					user.visible_message(\
						"\red [user.name] has removed the power control board from [src.name]!",\
						"You remove the power control board.")
					new /obj/item/weapon/module/power_control(loc)
		else if (opened!=2) //cover isn't removed
			opened = 0
			update_icon()
	else if (istype(W, /obj/item/weapon/crowbar) && !((stat & BROKEN) || malfhack) )
		if(coverlocked && !(stat & MAINT))
			to_chat(user, "\red The cover is locked and cannot be opened.")
			return
		else
			opened = 1
			update_icon()
	else if	(istype(W, /obj/item/weapon/stock_parts/cell) && opened)	// trying to put a cell inside
		if(cell)
			to_chat(user, "There is a power cell already installed.")
			return
		else
			if (stat & MAINT)
				to_chat(user, "\red There is no connector for your power cell.")
				return
			user.drop_item()
			W.loc = src
			cell = W
			user.visible_message(\
				"\red [user.name] has inserted the power cell to [src.name]!",\
				"You insert the power cell.")
			chargecount = 0
			update_icon()
	else if	(istype(W, /obj/item/weapon/screwdriver))	// haxing
		if(opened)
			if (cell)
				to_chat(user, "\red Close the APC first.")//Less hints more mystery!
				return
			else
				if (has_electronics==1 && terminal)
					has_electronics = 2
					stat &= ~MAINT
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					to_chat(user, "You screw the circuit electronics into place.")
				else if (has_electronics==2)
					has_electronics = 1
					stat |= MAINT
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					to_chat(user, "You unfasten the electronics.")
				else /* has_electronics==0 */
					to_chat(user, "\red There is nothing to secure.")
					return
				update_icon()
		else if(emagged)
			to_chat(user, "The interface is broken.")
		//else if(infected)
		//	to_chat(user, "The interface not working.")
		else
			wiresexposed = !wiresexposed
			to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
			update_icon()

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged)
			to_chat(user, "The interface is broken.")
		//else if (infected)
		//	to_chat(user, "The interface not working.")
		else if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			to_chat(user, "You must close the panel")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "Nothing happens.")
		else
			if(src.allowed(usr) && !wires.is_index_cut(APC_WIRE_IDSCAN))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] the APC interface.")
				update_icon()
			else
				to_chat(user, "\red Access denied.")
	else if (istype(W, /obj/item/weapon/card/emag) && !(emagged || malfhack))		// trying to unlock with an emag card
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			to_chat(user, "You must close the panel first")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "Nothing happens.")
		else
			flick("apc-spark", src)
			if (do_after(user,6,target = src))
				if(prob(50))
					emagged = 1
					locked = 0
					to_chat(user, "You emag the APC interface.")
					update_icon()
				else
					to_chat(user, "You fail to [ locked ? "unlock" : "lock"] the APC interface.")
	else if (istype(W, /obj/item/weapon/cable_coil) && !terminal && opened && has_electronics!=2)
		if (src.loc:intact)
			to_chat(user, "\red You must remove the floor plating in front of the APC first.")
			return
		var/obj/item/weapon/cable_coil/C = W
		if(C.amount < 10)
			to_chat(user, "\red You need more wires.")
			return
		to_chat(user, "You start adding cables to the APC frame...")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 20, target = src) && C.amount >= 10)
			var/turf/T = get_turf_loc(src)
			var/obj/structure/cable/N = T.get_cable_node()
			if (prob(50) && electrocute_mob(usr, N, N))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return
			C.use(10)
			user.visible_message(\
				"\red [user.name] has added cables to the APC frame!",\
				"You add cables to the APC frame.")
			make_terminal()
			terminal.connect_to_network()
	else if (istype(W, /obj/item/weapon/wirecutters) && terminal && opened && has_electronics!=2)
		terminal.dismantle(user)
	else if (istype(W, /obj/item/weapon/module/power_control) && opened && has_electronics==0 && !((stat & BROKEN) || malfhack))
		to_chat(user, "You trying to insert the power control board into the frame...")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 10, target = src))
			has_electronics = 1
			to_chat(user, "You place the power control board inside the frame.")
			qdel(W)
	else if (istype(W, /obj/item/weapon/module/power_control) && opened && has_electronics==0 && ((stat & BROKEN) || malfhack))
		to_chat(user, "\red You cannot put the board inside, the frame is damaged.")
		return
	else if (istype(W, /obj/item/weapon/weldingtool) && opened && has_electronics==0 && !terminal)
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.get_fuel() < 3)
			to_chat(user, "\blue You need more welding fuel to complete this task.")
			return
		to_chat(user, "You start welding the APC frame...")
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
		if(do_after(user, 50, target = src))
			if(!src || !WT.remove_fuel(3, user)) return
			if (emagged || malfhack || (stat & BROKEN) || opened==2)
				new /obj/item/stack/sheet/metal(loc)
				user.visible_message(\
					"\red [src] has been cut apart by [user.name] with the weldingtool.",\
					"You disassembled the broken APC frame.",\
					"\red You hear welding.")
			//else if (infected) // Malwared. FIX MALWARE ��������.
			//	infected = 0
			//	user.visible_message(\
								"[user.name] has discarded infected power control board from [src.name]!",\
								"<span class='notice'>You discarded shorten board.</span>")
			//	return
			else
				new /obj/item/apc_frame(loc)
				user.visible_message(\
					"\red [src] has been cut from the wall by [user.name] with the weldingtool.",\
					"You cut the APC frame from the wall.",\
					"\red You hear welding.")
			qdel(src)
			return
	else if (istype(W, /obj/item/apc_frame) && opened && emagged)
		emagged = 0
		if (opened==2)
			opened = 1
		user.visible_message(\
			"\red [user.name] has replaced the damaged APC frontal panel with a new one.",\
			"You replace the damaged APC frontal panel with a new one.")
		qdel(W)
		update_icon()
	else if (istype(W, /obj/item/apc_frame) && opened && ((stat & BROKEN) || malfhack))
		if (has_electronics)
			to_chat(user, "You cannot repair this APC until you remove the electronics still inside.")
			return
		to_chat(user, "You begin to replace the damaged APC frame...")
		if(do_after(user, 50, target = src))
			user.visible_message(\
				"\red [user.name] has replaced the damaged APC frame with new one.",\
				"You replace the damaged APC frame with new one.")
			qdel(W)
			stat &= ~BROKEN
			malfai = null
			malfhack = 0
			if (opened==2)
				opened = 1
			update_icon()
	else
		if (((stat & BROKEN) || malfhack) \
				&& !opened \
				&& W.force >= 5 \
				&& W.w_class >= 3.0 \
				&& prob(20) )
			opened = 2
			user.visible_message("\red The APC cover was knocked down with the [W.name] by [user.name]!", \
				"\red You knock down the APC cover with your [W.name]!", \
				"You hear bang")
			update_icon()
		else
			if (istype(user, /mob/living/silicon))
				return src.attack_hand(user)
			if (!opened && wiresexposed && \
				(istype(W, /obj/item/device/multitool) || \
				istype(W, /obj/item/weapon/wirecutters)))
				return src.attack_hand(user)
			user.visible_message("\red The [src.name] has been hit with the [W.name] by [user.name]!", \
				"\red You hit the [src.name] with your [W.name]!", \
				"You hear bang")

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/user)
//	if (!can_use(user)) This already gets called in interact() and in topic()
//		return
	if(!user)
		return
	src.add_fingerprint(user)

	//Synthetic human mob goes here.
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.flags[IS_SYNTHETIC] && H.a_intent == "grab")
			if(emagged || (stat & BROKEN))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(3, 1, src)
				s.start()
				to_chat(H, "\red The APC power currents surge eratically, damaging your chassis!")
				H.adjustFireLoss(10,0)
			else if(src.cell && src.cell.charge > 0)
				if(H.nutrition < 450)

					if(src.cell.charge >= 500)
						H.nutrition += 50
						src.cell.charge -= 500
					else
						H.nutrition += src.cell.charge/10
						src.cell.charge = 0

					to_chat(user, "\blue You slot your fingers into the APC interface and siphon off some of the stored charge for your own use.")
					if(src.cell.charge < 0) src.cell.charge = 0
					if(H.nutrition > 500) H.nutrition = 500
					src.charging = 1

				else
					to_chat(user, "\blue You are already fully charged.")
			else
				to_chat(user, "There is no charge to draw from that APC.")
			return

	if(usr == user && opened && (!issilicon(user)))
		if(cell)
			user.put_in_hands(cell)
			cell.add_fingerprint(user)
			cell.updateicon()

			src.cell = null
			user.visible_message("\red [user.name] removes the power cell from [src.name]!", "You remove the power cell.")
			//user << "You remove the power cell."
			charging = 0
			src.update_icon()
		return
	if(stat & (BROKEN|MAINT))
		return

	// do APC interaction
	user.set_machine(src)
	src.interact(user)

/obj/machinery/power/apc/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(!user)
		return
	user.do_attack_animation(src)
	user.visible_message("\red [user.name] slashes at the [src.name]!", "\blue You slash at the [src.name]!")
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)

	if(beenhit >= pick(3, 4) && wiresexposed != 1)
		wiresexposed = 1
		src.update_icon()
		src.visible_message("\red The [src.name]'s cover flies open, exposing the wires!")

	else if(wiresexposed && !wires.is_all_cut())
		wires.cut_all()
		src.update_icon()
		src.visible_message("\red The [src.name]'s wires are shredded!")
	else
		beenhit += 1
	return



/obj/machinery/power/apc/interact(mob/user)
	if(!user)
		return
	if(wires.interact(user))
		return
	ui_interact(user)

/obj/machinery/power/apc/proc/get_malf_status(mob/user)
	if (ticker && ticker.mode && (user.mind in ticker.mode.malf_ai) && istype(user, /mob/living/silicon/ai))
		if (src.malfai == (user:parent ? user:parent : user))
			if (src.occupier == user)
				return 3 // 3 = User is shunted in this APC
			else if (istype(user.loc, /obj/machinery/power/apc))
				return 4 // 4 = User is shunted in another APC
			else
				return 2 // 2 = APC hacked by user, and user is in its core.
		else
			return 1 // 1 = APC not hacked.
	else
		return 0 // 0 = User is not a Malf AI

/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if(!user)
		return

	var/list/data = list(
		"locked" = locked,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = lastused_equip + lastused_light + lastused_environ,
		"coverLocked" = coverlocked,
		"siliconUser" = istype(user, /mob/living/silicon),
		"malfStatus" = get_malf_status(user),

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = lastused_equip,
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on"   = list("eqp" = 2),
					"off"  = list("eqp" = 1)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = lastused_light,
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on"   = list("lgt" = 2),
					"off"  = list("lgt" = 1)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = lastused_environ,
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on"   = list("env" = 2),
					"off"  = list("env" = 1)
				)
			)
		)
	)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "apc.tmpl", "[area.name] - APC", 520, data["siliconUser"] ? 465 : 440)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
//		if (area.name == "AI Chamber")
//			spawn(10)
//				world << " [area.name] [area.power_equip]"
	else
		area.power_light = 0
		area.power_equip = 0
		area.power_environ = 0
//		if (area.name == "AI Chamber")
//			world << "[area.power_equip]"
	area.power_change()

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0) //used by attack_hand() and Topic()
	if (IsAdminGhost(user))
		return 1
	if(!user.client)
		return 0
	autoflag = 5
	if(issilicon(user))
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if (                                                             \
			src.aidisabled ||                                            \
			malfhack && istype(malfai) &&                                \
			(                                                            \
				(istype(AI) && (malfai!=AI && malfai != AI.parent)) ||   \
				(istype(robot) && (robot in malfai.connected_robots))    \
			)                                                            \
		)
			if(!loud)
				to_chat(user, "\red \The [src] have AI control disabled!")
				nanomanager.close_user_uis(user, src)

			return 0
	else
		if ((!in_range(src, user) || !istype(src.loc, /turf)))
			nanomanager.close_user_uis(user, src)

			return 0

	return 1

/obj/machinery/power/apc/is_operational_topic()
	return !(stat & (BROKEN|MAINT|EMPED))

/obj/machinery/power/apc/Topic(href, href_list, usingUI = TRUE)
	. = ..(href, href_list)
	if(!.)
		return

	if(!can_use(usr, 1))
		return

	else if (href_list["lock"])
		coverlocked = !coverlocked

	else if (href_list["breaker"])
		operating = !operating
		if(malfai)
			if (ticker.mode.config_tag == "malfunction")
				if (src.z == ZLEVEL_STATION) //if (is_type_in_list(get_area(src), the_station_areas))
					operating ? ticker.mode:apcs++ : ticker.mode:apcs--

		src.update()
		update_icon()

	else if (href_list["cmode"])
		chargemode = !chargemode
		if(!chargemode)
			charging = 0
			update_icon()

	else if (href_list["eqp"])
		var/val = text2num(href_list["eqp"])

		equipment = setsubsystem(val)

		update_icon()
		update()

	else if (href_list["lgt"])
		var/val = text2num(href_list["lgt"])

		lighting = setsubsystem(val)

		update_icon()
		update()
	else if (href_list["env"])
		var/val = text2num(href_list["env"])

		environ = setsubsystem(val)

		update_icon()
		update()
	else if( href_list["close"] )
		nanomanager.close_user_uis(usr, src)
		return FALSE

	else if (href_list["overload"])
		if( istype(usr, /mob/living/silicon) && !src.aidisabled )
			src.overload_lighting()

	else if (href_list["malfhack"])
		var/mob/living/silicon/ai/malfai = usr
		if( istype(malfai, /mob/living/silicon/ai) && !src.aidisabled )
			if (malfai.malfhacking)
				to_chat(malfai, "You are already hacking an APC.")
				return FALSE
			to_chat(malfai, "Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process.")
			malfai.malfhack = src
			malfai.malfhacking = 1
			sleep(600)
			if(src)
				if (!src.aidisabled)
					malfai.malfhack = null
					malfai.malfhacking = 0
					if (ticker.mode.config_tag == "malfunction")
						if (src.z == ZLEVEL_STATION) //if (is_type_in_list(get_area(src), the_station_areas))
							ticker.mode:apcs++
					if(usr:parent)
						src.malfai = usr:parent
					else
						src.malfai = usr
					to_chat(malfai, "Hack complete. The APC is now under your exclusive control.")
					update_icon()

	/*else if (href_list["occupyapc"])
		malfoccupy(usr)


	else if (href_list["deoccupyapc"])
		malfvacate()*/

	if(usingUI)
		src.updateDialog()

/*/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, "<span class='warning'>You must evacuate your current apc first.</span>")
		return
	if(src.z != ZLEVEL_STATION)
		return
	src.occupier = new /mob/living/silicon/ai(src,malf.laws,null,1)
	src.occupier.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(src.occupier.name,"APC Copy"))
		src.occupier.name = "[malf.name] APC Copy"
	if(malf.parent)
		src.occupier.parent = malf.parent
	else
		src.occupier.parent = malf
	malf.mind.transfer_to(src.occupier)
	src.occupier.eyeobj.name = "[src.occupier.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
	src.occupier.verbs += /mob/living/silicon/ai/proc/corereturn
	src.occupier.verbs += /datum/game_mode/malfunction/proc/takeover
	src.occupier.cancel_camera()

/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!src.occupier)
		return
	if(src.occupier.parent && src.occupier.parent.stat != DEAD)
		src.occupier.mind.transfer_to(src.occupier.parent)
		src.occupier.parent.adjustOxyLoss(src.occupier.getOxyLoss())
		src.occupier.parent.cancel_camera()
		qdel(src.occupier)

	else
		to_chat(src.occupier, "\red Primary core damaged, unable to return core processes.")
		if(forced)
			src.occupier.loc = src.loc
			src.occupier.death()
			src.occupier.gib()*/


/obj/machinery/power/apc/proc/ion_act()
	//intended to be exactly the same as an AI malf attack
	if(!src.malfhack && src.z == ZLEVEL_STATION)
		if(prob(3))
			src.locked = 1
			if (src.cell.charge > 0)
//				world << "\red blew APC in [src.loc.loc]"
				src.cell.charge = 0
				cell.corrupt()
				src.malfhack = 1
				update_icon()
				var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
				smoke.set_up(3, 0, src.loc)
				smoke.attach(src)
				smoke.start()
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(3, 1, src)
				s.start()
				for(var/mob/M in viewers(src))
					M.show_message("\red The [src.name] suddenly lets out a blast of smoke and some sparks!", 3, "\red You hear sizzling electronics.", 2)


/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(amount)
	if(terminal && terminal.powernet)
		terminal.powernet.newload += amount

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()

	if(stat & (BROKEN|MAINT))
		return
	if(!area.requires_power)
		return


	lastused_light = area.usage(STATIC_LIGHT)
	lastused_light += area.usage(LIGHT)
	lastused_equip = area.usage(EQUIP)
	lastused_equip += area.usage(STATIC_EQUIP)
	lastused_environ = area.usage(ENVIRON)
	lastused_environ += area.usage(STATIC_ENVIRON)
	if(area.powerupdate)
		if(debug) log_debug("power update in [area.name] / [name]")
		area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()

	if(!src.avail())
		main_status = 0
	else if(excess < 0)
		main_status = 1
	else
		main_status = 2

	var/perapc = 0
	if(terminal && terminal.powernet)
		perapc = terminal.powernet.perapc

	if(debug)
		log_debug( "Status: [main_status] - Excess: [excess] - Last Equip: [lastused_equip] - Last Light: [lastused_light]")

	if(cell && !shorted)
		//var/cell_charge = cell.charge
		var/cell_maxcharge = cell.maxcharge

		// draw power from cell as before

		var/cellused = min(cell.charge, CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > 0 || perapc > lastused_total)		// if power excess, or enough anyway, recharge the cell
														// by the same amount just used
			cell.give(cellused)
			add_load(cellused/CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc

			if( (cell.charge/CELLRATE+perapc) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?

				cell.give(CELLRATE * perapc)	//recharge with what we can
				add_load(perapc)		// so draw what we can from the grid
				charging = 0

			else if (autoflag != 0)	// not enough power available to run the last tick!
				charging = 0
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)
				autoflag = 0


		// set channels depending on how much charge we have left

		// Allow the APC to operate as normal if the cell can charge
		if(charging && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2


		if(cell.charge >= 1250 || longtermpower > 0)              // Put most likely at the top so we don't check it last, effeciency 101
			if(autoflag != 3)
				equipment = autoset(equipment, 1)
				lighting = autoset(lighting, 1)
				environ = autoset(environ, 1)
				autoflag = 3
				area.poweralert(1, src)
				if(cell.charge >= 4000)
					area.poweralert(1, src)
		else if(cell.charge < 1250 && cell.charge > 750 && longtermpower < 0)                       // <30%, turn off equipment
			if(autoflag != 2)
				equipment = autoset(equipment, 2)
				lighting = autoset(lighting, 1)
				environ = autoset(environ, 1)
				area.poweralert(0, src)
				autoflag = 2
		else if(cell.charge < 750 && cell.charge > 10 && longtermpower < 0)        // <15%, turn off lighting & equipment
			if(autoflag != 1)
				equipment = autoset(equipment, 2)
				lighting = autoset(lighting, 2)
				environ = autoset(environ, 1)
				area.poweralert(0, src)
				autoflag = 1
		else if(cell.charge <= 0)                                   // zero charge, turn all off
			if(autoflag != 0)
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)
				area.poweralert(0, src)
				autoflag = 0

		// now trickle-charge the cell

		if(chargemode && charging == 1 && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is perapc share, capped to cell capacity, or % per second constant (Whichever is smallest)
				var/ch = min(perapc*CELLRATE, (cell_maxcharge - cell.charge), (cell_maxcharge*CHARGELEVEL))
				add_load(ch/CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = 0		// stop charging
				chargecount = 0

		// show cell as fully charged if so

		if(cell.charge >= cell_maxcharge)
			charging = 2

		if(chargemode)
			if(!charging)
				if(excess > cell_maxcharge*CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = 1

		else // chargemode off
			charging = 0
			chargecount = 0

	else // no cell, switch everything off

		charging = 0
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		area.poweralert(0, src)
		autoflag = 0


	// update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ)
		queue_icon_update()
		update()
	else if (last_ch != charging)
		queue_icon_update()
	src.updateDialog()

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff

/proc/autoset(val, on)

	if(on==0)
		if(val==2)			// if on, return off
			return 0
		else if(val==3)		// if auto-on, return auto-off
			return 1

	else if(on==1)
		if(val==1)			// if auto-off, return auto-on
			return 3

	else if(on==2)
		if(val==3)			// if auto-on, return auto-off
			return 1

	return val

// damage and destruction acts

/obj/machinery/power/apc/meteorhit(obj/O)

	set_broken()
	return

/obj/machinery/power/apc/emp_act(severity)
	flick("apc-spark", src)
	if(cell)
		cell.emp_act(severity)
	if(occupier)
		occupier.emp_act(severity)
	lighting = 0
	equipment = 0
	environ = 0
	update()
	spawn(600/severity)
		lighting = 3
		equipment = 3
		environ = 3
		update()
	..()

/obj/machinery/power/apc/ex_act(severity)

	switch(severity)
		if(1.0)
			//set_broken() //now Destroy() do what we need
			if (cell)
				cell.ex_act(1.0) // more lags woohoo
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				set_broken()
				if (cell && prob(50))
					cell.ex_act(2.0)
		if(3.0)
			if (prob(25))
				set_broken()
				if (cell && prob(25))
					cell.ex_act(3.0)
	return

/obj/machinery/power/apc/blob_act()
	if (prob(75))
		set_broken()
		if (cell && prob(5))
			cell.blob_act()

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		if (ticker.mode.config_tag == "malfunction")
			if (src.z == ZLEVEL_STATION) //if (is_type_in_list(get_area(src), the_station_areas))
				ticker.mode:apcs--
	stat |= BROKEN
	operating = 0
	/*if(occupier)
		malfvacate(1)*/
	update_icon()
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting(skip_sound_and_sparks = 0)
	if(/* !get_connection() || */ !operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.use(20);
		break_lights(skip_sound_and_sparks)

/obj/machinery/power/apc/proc/break_lights(skip_sound_and_sparks)
	set waitfor = FALSE

	for(var/area/A in area.related)
		for(var/obj/machinery/light/L in A)
			L.on = 1
			L.broken(skip_sound_and_sparks)
			stoplag()

/obj/machinery/power/apc/proc/shock(mob/user, prb)
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(isalien(user))
		return 0
	if (electrocute_mob(user, src, src))
		return 1
	else
		return 0
/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val==1) ? 0 : val
	else
		return (val == 3)
/*
/obj/machinery/power/apc/act_inject(mob/user, mode)
	var/area/F = get_area(src)
	if(!infected && !emagged)
		switch(mode)
			if(1)
				user.visible_message("<span class='notice'>You start inject Disabler to [src]</span>")
				infected = 1
				update_icon()
				if(do_after(user, 300, 1, target = src)) //TODO : ANTIMALWARE [CREATE -+ Time]
					spawn(120)
					for(var/obj/machinery/door/airlock/door in F)
						INVOKE_ASYNC(door, /obj/machinery/door/airlock.proc/open)
						spawn(15)
						INVOKE_ASYNC(door, /obj/machinery/door/airlock.proc/bolt)
						START_PROCESSING(SSobj, src)
						lighting = 0
						area.power_light = 0
						update()
				else
					infected = 0
					update_icon()
	else
		user.visible_message("<span class='notice'>This [src], already emagged or infected...</span>")
		return
/obj/machinery/power/apc/act_inject/process()
	var/area/T = get_area(src)
	if(!infected)
		return
	spawn(100)
	for(var/obj/machinery/door/airlock/door in T)
		if(INVOKE_ASYNC(door, /obj/machinery/door/airlock.proc/bolt))
			return
		else
			INVOKE_ASYNC(door, /obj/machinery/door/airlock.proc/bolt)
*/
#undef APC_UPDATE_ICON_COOLDOWN