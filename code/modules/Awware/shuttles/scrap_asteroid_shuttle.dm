#define CD_SHUTTLE 150

#define DOCK_ST /area/shuttle/junkyard_shuttle/station
#define SCRAP_BASE_DOCK /area/shuttle/junkyard_shuttle/outpost

#define F_S_SCRAP /turf/simulated/shuttle/floor

var/global/obj/machinery/computer/scrap_shuttle_console/flight_comp/main_pilot = null
var/global/area/scrap_shuttle_loc = null

/obj/machinery/computer/scrap_shuttle_console
	name = "Scrap Asteroid Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	circuit = /obj/item/weapon/circuitboard/scrap_shuttle_console

/obj/machinery/computer/scrap_shuttle_console/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/scrap_shuttle_console/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/computer/scrap_shuttle_console/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)

	var/dat
	if(main_pilot)
		var/shuttle_location = "NSS Exodus"
		if(istype(main_pilot.scrap_shuttle_loc, SCRAP_BASE_DOCK))
			shuttle_location = "Scrap Asteroid Base"
		dat = {"Location: [shuttle_location]<br>
		Ready to move[max(main_pilot.lastMove + CD_SHUTTLE - world.time, 0) ? " in [max(round((main_pilot.lastMove + CD_SHUTTLE - world.time) * 0.1), 0)] seconds" : ": now"]<br>
		<a href='?src=\ref[src];mine=1'>Scrap Asteroid Base</a> |
		<a href='?src=\ref[src];station=1'>NSS Exodus</a> |
		<a href='?src=\ref[user];mach_close=flightcomputer2'>Close</a>"}
	else
		dat = "Cannot find shuttle"

	user << browse(dat, "window=flightcomputer2;size=575x450")
	onclose(user, "flightcomputer2")
	return

/obj/machinery/computer/scrap_shuttle_console/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!main_pilot)
		to_chat(usr, "\red Shuttle not found!")
		return FALSE
	if(main_pilot.moving)
		to_chat(usr, "\blue Shuttle is already moving.")
		return FALSE

	var/result = FALSE
	if(href_list["mine"])
		result = main_pilot.scrap_shuttle_move_to(SCRAP_BASE_DOCK)
	else if(href_list["station"])
		result = main_pilot.scrap_shuttle_move_to(DOCK_ST)
	if(result)
		to_chat(usr, "\blue Shuttle recieved message and will be sent shortly.")

	updateUsrDialog()

//-------------------------------------------
//------------FLIGHT COMPUTER----------------
//-------------------------------------------

/obj/machinery/computer/scrap_shuttle_console/flight_comp
	name = "Shuttle Console"
	icon = 'code/modules/locations/shuttles/computer_shuttle_mining.dmi'
	icon_state = "scrap_shuttle"
	circuit = /obj/item/weapon/circuitboard/scrap_shuttle_console/flight_comp
	var/area/scrap_shuttle_loc
	var/moving = 0
	var/lastMove = 0

/obj/machinery/computer/scrap_shuttle_console/flight_comp/New()
	..()
	var/area/my_area = get_area(src)
	if(istype(get_turf(src),F_S_SCRAP) &&\
		   is_type_in_list(my_area,list(DOCK_ST, SCRAP_BASE_DOCK))) //if we build console not in shuttle area
		main_pilot = src
		dir = WEST
		if(!scrap_shuttle_loc)
			scrap_shuttle_loc = my_area

/obj/machinery/computer/scrap_shuttle_console/flight_comp/Destroy()
	if(main_pilot == src) //if we have more than one flight comp! (look imbossible)
		main_pilot = null
	return ..()

/obj/machinery/computer/scrap_shuttle_console/flight_comp/proc/scrap_shuttle_move_to(area/destination)
	if(moving)
		return FALSE
	if((lastMove + CD_SHUTTLE) > world.time)
		return FALSE
	var/area/dest_location = locate(destination)
	if(scrap_shuttle_loc == dest_location)
		return FALSE

	moving = TRUE
	lastMove = world.time
	addtimer(CALLBACK(src, .proc/scrap_shuttle_do_move, dest_location), CD_SHUTTLE, TIMER_UNIQUE)
	return TRUE

/obj/machinery/computer/scrap_shuttle_console/flight_comp/proc/scrap_shuttle_do_move(area/destination)
	if(moving)
		var/list/dstturfs = list()
		var/throwx = world.maxx

		for(var/turf/T in destination)
			dstturfs += T
			if(T.x < throwx)
				throwx = T.x

		// hey you, get out of the way!
		for(var/turf/T in dstturfs)
			// find the turf to move things to
			var/turf/D = locate(throwx - 1, T.y, T.z)
			for(var/atom/movable/AM as mob|obj in T)
				AM.Move(D)

			if(istype(T, /turf/simulated))
				qdel(T)

		for(var/mob/living/carbon/bug in destination) // If someone somehow is still in the shuttle's docking area...
			bug.gib()

		for(var/mob/living/simple_animal/pest in destination) // And for the other kind of bug...
			pest.gib()

		scrap_shuttle_loc.move_contents_to(destination)

		for(var/mob/M in destination)
			if(M.client)
				spawn(0)
					if(M.buckled)
						shake_camera(M, 3, 1) // buckled, not a lot of shaking
					else
						shake_camera(M, 10, 1) // unbuckled, HOLY SHIT SHAKE THE ROOM
			if(istype(M, /mob/living/carbon))
				if(!M.buckled)
					M.Weaken(3)

		scrap_shuttle_loc = destination
		moving = FALSE

#undef F_S_SCRAP

#undef CD_SHUTTLE

#undef DOCK_ST
#undef SCRAP_BASE_DOCK
