/obj/machinery/computer/atompc
	name = "Atom Portable Terminal"
	desc = "OS - AtomOS"
	icon = 'icons/obj/apt.dmi'
	icon_state = "inactive_apt"
	density = 1
	var/temp_data = "<b>AtomOS System v0.1</b>"
	var/temp_add = null
	var/dat

	var/bypass_mode = FALSE
	var/setup_font_color = "#a2a122"
	var/setup_bg_color = "#383a38"
//	power_usage = 250

/obj/machinery/computer/atompc/attack_hand(mob/user as mob)
	if(..())
		return
	if (user.set_machine(src))
		if (!src.temp_data)
			user << output(null, "atompc.browser:con_clear")
		if (src.temp_add)
			user << output(url_encode(src.temp_add), "atompc.browser:con_output")
	else
		user.set_machine(src)

		if(src.temp_add)
			src.temp_data += temp_add
			temp_add = null

		dat = {"<title>TEST</title>
		<style type="text/css">

		img
		{
			border-style: none;
		}

		#consolelog
		{
			border: 1px grey solid;
			height: 280px;
			width: 410px;
			overflow-y: scroll;
			word-wrap: break-word;
			word-break: break-all;
			background-color:[src.setup_bg_color];
			color:[src.setup_font_color];
			font-family: "Consolas", monospace;
			font-size:10pt;
		}

		#consoleshell
		{
			border: 1px grey solid;
			height: 280px;
			width: 410px;
			overflow-x: hidden;
			overflow-y: hidden;
			word-wrap: break-word;
			word-break: break-all;
			background-color:#1B1E1B;
			color:#19A319;
			font-family: "Consolas", monospace;
			font-size:10pt;
		}

		</style>
		<body scroll=no>
		<div id=\"consolelog\">[src.temp_data]</div>
		<script language="JavaScript">
			var objDiv = document.getElementById("consolelog");
			objDiv.scrollTop = objDiv.scrollHeight;

var lastVals = new Array();
var lastValsOffset = 0;
function keydownfunc (event)
{
	var theKey = (event.which) ? event.which : event.keyCode;
	if (theKey == 38)
	{
		if (lastVals.length > lastValsOffset)
		{
			document.getElementById("consoleinput").value = lastVals\[lastVals.length - lastValsOffset - 1];
			lastValsOffset++;
			if (lastValsOffset >= lastVals.length)
			{
				lastValsOffset = 0;
			}
		}
	}
	else if (theKey == 40)
	{
		if (lastValsOffset > 0)
		{
			lastValsOffset--;
			document.getElementById("consoleinput").value = lastVals\[lastVals.length - lastValsOffset - 1];
		}
	}
}

function lineEnter ()
{
	if (document.getElementById("consoleinput").value != null)
	{
		lastVals.push(document.getElementById("consoleinput").value);
		if (lastVals.length > 10)
		{
			lastVals.shift();
		}
	}
}

		</script>
		<br>
		<form name="consoleinput" action="byond://?src=\ref[src]" method="get" onsubmit="javascript:return lineEnter()">
			<input type="hidden" name="src" value="\ref[src]">
			<input id = "-" type="text" name="command" maxlength="120" size="55" onKeyDown="javascript:return keydownfunc(event)">
			<input type="submit" value="Enter">
		</form>
		<table cellspacing=5><tr>"}
		dat += {"<script language="JavaScript">
		document.consoleinput.command.focus();
		var printing = "";
		var t_count = 0;
		var last_output;

		function input_clear()
		{
			document.getElementById("consoleinput").value = '';
		}

		function con_output(t)
		{
			if (printing.length > 0)
			{
				var toadd = t.split("<br>");
				if (t.substr(t.length - 4,4) == "<br>")
				{
					toadd.pop();
				}
				printing = printing.concat(toadd);
			}
			else
			{
				printing = t.split("<br>");
				if (t.substr(t.length - 4,4) == "<br>")
				{
					printing.pop();
				}
				last_output = window.setInterval((function () {real_con_output();}), 10);
			}

		}

		function real_con_output()
		{
			if (printing.length > 0)
			{
				var t_bit = printing.shift();
				if (t_bit != undefined)
				{
					objDiv.innerHTML += t_bit + "<br>";
				}
				objDiv.scrollTop = objDiv.scrollHeight;
				return;
			}

			window.clearTimeout(last_output);
			return;
		}

		function con_clear()
		{
			printing.length = 0;
			objDiv.innerHTML = "";
		}

		</script>"}
	var/datum/browser/atompc = new(user, "atompc", name, 445, 405)
	atompc.set_content(dat)
	atompc.open()
	onclose(user, "atompc")

/obj/machinery/computer/atompc/updateUsrDialog()
	..()
	if (src.temp_add)
		src.temp_data += src.temp_add
		src.temp_add = null

/obj/machinery/computer/atompc/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if((href_list["command"]))
		usr << output(null, "atompc.browser:input_clear")
		src.updateUsrDialog()
		src.input_text(href_list["command"])
	src.updateUsrDialog()

/obj/machinery/computer/atompc/proc/input_text(var/text)
	var/list/command_list = text
	var/command = lowertext(command_list[1])
	command_list -= command_list[1]

	src.print_to_console(strip_html(text))

	switch(lowertext(command))
		if("test")
			src.print_to_console("<b>UNKNOWN TEST COMMAND.</b>")
	return

/obj/machinery/computer/atompc/proc/print_to_console(var/text)
	src.temp_add += "<br>[text]"
	src.updateUsrDialog()
	return 0