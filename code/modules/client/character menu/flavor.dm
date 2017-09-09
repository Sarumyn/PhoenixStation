/*
/datum/preferences
	var/list/flavor_texts        = list()
	var/list/flavour_texts_robot = list()
*/
/datum/preferences/proc/SetFlavorText(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='?src=\ref[user];preference=flavor_text;task=input;flavor_text=general'>General:</a> "
	HTML += TextPreview(flavor_texts["general"])
	HTML += "<br>"
	HTML += "<a href='?src=\ref[user];preference=flavor_text;task=input;flavor_text=head'>Head:</a> "
	HTML += TextPreview(flavor_texts["head"])
	HTML += "<br>"
	HTML += "<a href='?src=\ref[user];preference=flavor_text;task=input;flavor_text=face'>Face:</a> "
	HTML += TextPreview(flavor_texts["face"])
	HTML += "<br>"
	HTML += "<a href='?src=\ref[user];preference=flavor_text;task=input;flavor_text=eyes'>Eyes:</a> "
	HTML += TextPreview(flavor_texts["eyes"])
	HTML += "<br>"
	HTML += "<a href='?src=\ref[user];preference=flavor_text;task=input;flavor_text=torso'>Body:</a> "
	HTML += TextPreview(flavor_texts["torso"])
	HTML += "<br>"
	HTML += "<a href='?src=\ref[user];preference=flavor_text;task=input;flavor_text=arms'>Arms:</a> "
	HTML += TextPreview(flavor_texts["arms"])
	HTML += "<br>"
	HTML += "<a href='?src=\ref[user];preference=flavor_text;task=input;flavor_text=hands'>Hands:</a> "
	HTML += TextPreview(flavor_texts["hands"])
	HTML += "<br>"
	HTML += "<a href='?src=\ref[user];preference=flavor_text;task=input;flavor_text=legs'>Legs:</a> "
	HTML += TextPreview(flavor_texts["legs"])
	HTML += "<br>"
	HTML += "<a href='?src=\ref[user];preference=flavor_text;task=input;flavor_text=feet'>Feet:</a> "
	HTML += TextPreview(flavor_texts["feet"])
	HTML += "<br>"
	HTML += "<hr />"
	HTML += "<tt>"
	user << browse(HTML, "window=flavor_text;size=430x300")
	return
