/datum/disease/jungle_fever
	name = "Jungle Fever"
	max_stages = 1
	cure = "None"
	spread = "Bites"
	spread_type = SPECIAL
	affected_species = list(HUMAN , MONKEY)
	curable = 0
	desc = "Monkeys with this disease will bite humans, causing humans to spontaneously mutate into a monkey."
	severity = "Medium"
	//stage_prob = 100
	agent = "Kongey Vibrion M-909"