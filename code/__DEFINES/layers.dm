//Defines for atom layers and planes
//KEEP THESE IN A NICE ACSCENDING ORDER, PLEASE

#define CLICKCATCHER_PLANE -99

#define PLANE_SPACE -95
#define PLANE_SPACE_PARALLAX -90

#define GAME_PLANE 0

#define LIGHTING_PLANE 15
#define LIGHTING_LAYER 15

//HUD layer defines

#define FULLSCREEN_PLANE 18
#define FLASH_LAYER 18
#define FULLSCREEN_LAYER 18.1

#define HUD_PLANE 19
#define HUD_LAYER 19
#define ABOVE_HUD_PLANE 20
#define ABOVE_HUD_LAYER 20

#define UNDER_HUD_LAYER 0


#define HIDING_MOB_PLANE -16 // for hiding mobs like MoMMIs or spiders or whatever, under most objects but over pipes & such.
#define HIDING_MOB_LAYER 0

#define LYING_MOB_PLANE -14 // other mobs that are lying down.

#define LYING_MOB_LAYER 0

/atom/proc/reset_plane_and_layer()
	plane = initial(plane)
	layer = initial(layer)
