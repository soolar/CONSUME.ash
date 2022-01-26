boolean is_salad(item it)
{
	return it.notes.contains_text("SALAD");
}

boolean is_beer(item it)
{
	return it.notes.contains_text("BEER");
}

boolean is_wine(item it)
{
	return it.notes.contains_text("WINE");
}

boolean is_martini(item it)
{
	return it.notes.contains_text("MARTINI");
}

boolean is_saucy(item it)
{
	return it.notes.contains_text("SAUCY");
}

boolean is_lasagna(item it)
{
	return it.notes.contains_text("LASAGNA");
}

boolean is_monday()
{
	return numeric_modifier($item[tuesday's ruby], "muscle percent") == 5.0;
}

int daily_limit(item it)
{
	switch(it)
	{
		case $item[mojo filter]:
			return 3 - get_property("currentMojoFilters").to_int();
		case $item[spice melange]:
			return get_property("spiceMelangeUsed").to_boolean() ? 0 : 1;
		case $item[ultra mega sour ball]:
			return get_property("_ultraMegaSourBallUsed").to_boolean() ? 0 : 1;
		case $item[sweet tooth]:
			return get_property("_sweetToothUsed").to_boolean() ? 0 : 1;
		case $item[fudge spork]:
			return get_property("_fudgeSporkUsed").to_boolean() ? 0 : 1;
		case $item[essential tofu]:
			return get_property("_essentialTofuUsed").to_boolean() ? 0 : 1;
		case $item[blue mana]:
			return 10 - get_property("_ancestralRecallCasts").to_int();
		case $item[alien animal milk]:
			return get_property("_alienAnimalMilkUsed").to_boolean() ? 0 : 1;
		case $item[alien plant pod]:
			return get_property("_alienPlantPodUsed").to_boolean() ? 0 : 1;
		case $item[affirmation cookie]:
			return get_property("_affirmationCookieEaten").to_boolean() ? 0 : 1;
		case $item[Hunger&trade; Sauce]:
			return get_property("_hungerSauceUsed").to_boolean() ? 0 : 1;
		case $item[cuppa Voraci tea]:
			return get_property("_voraciTeaUsed").to_boolean() ? 0 : 1;
		case $item[cuppa Sobrie tea]:
			return get_property("_sobrieTeaUsed").to_boolean() ? 0 : 1;
		case $item[lupine appetite hormones]:
			return get_property("_lupineHormonesUsed").to_boolean() ? 0 : 1;
		case $item[distention pill]:
			return (get_property("_distentionPillUsed").to_boolean() || available_amount($item[distention pill]) == 0) ? 0 : 1;
		case $item[synthetic dog hair pill]:
			return (get_property("_syntheticDogHairPillUsed").to_boolean() || available_amount($item[synthetic dog hair pill]) == 0) ? 0 : 1;
		// pvp stuff
		case $item[Meteorite-Ade]:
			return 3 - get_property("_meteoriteAdesUsed").to_int();
		case $item[Jerks' Health&trade; Magazine]:
			return 5 - get_property("_jerksHealthMagazinesUsed").to_int();
		// drippy consumables
		case $item[drippy nugget]:
			return get_property("_drippyNuggetUsed").to_boolean() ? 0 : 1;
		case $item[glass of drippy wine]:
			return get_property("_drippyWineUsed").to_boolean() ? 0 : 1;
		case $item[drippy caviar]:
			return get_property("_drippyCaviarUsed").to_boolean() ? 0 : 1;
		case $item[drippy plum(?)]:
			return get_property("_drippyPlumUsed").to_boolean() ? 0 : 1;
		case $item[drippy pilsner]:
			return get_property("_drippyPilsnerUsed").to_boolean() ? 0 : 1;
		// batfellow consumables
		case $item[Kudzu salad]:
		case $item[Mansquito Serum]:
		case $item[Miss Graves' vermouth]:
		case $item[The Plumber's mushroom stew]:
		case $item[The Author's ink]:
		case $item[The Mad Liquor]:
		case $item[Doc Clock's thyme cocktail]:
		case $item[Mr. Burnsger]:
		case $item[The Inquisitor's unidentifiable object]:
			return 1;
		// Universal Seasoning
		case $item[Universal Seasoning]:
			return item_amount($item[Universal Seasoning]) - get_property("_universalSeasoningsUsed").to_int();
		// TODO: MOOOOOOOOOOOOOORE
		default: return -1;
	}
}

int accordion_buff_duration(item accordion)
{
	switch(accordion)
	{
		case $item[stolen accordion]:
		case $item[toy accordion]:
			return 5;
		case $item[beer-battered accordion]:
			return 6;
		case $item[baritone accordion]:
		case $item[calavera concertina]:
			return 7;
		case $item[mama's squeezebox]:
			return 8;
		case $item[guancertina]:
			return 9;
		case $item[accord ion]:
		case $item[accordion file]:
		case $item[Aerogel accordion]:
		case $item[Antique accordion]:
		case $item[Bal-musette accordion]:
		case $item[Cajun accordion]:
		case $item[quirky accordion]:
		case $item[Rock and Roll Legend]:
		case $item[Skipper's accordion]:
		case $item[warbear exhaust manifold]:
			return 10;
		case $item[bone bandoneon]:
			return 11;
		case $item[pentatonic accordion]:
			return 12;
		case $item[Accordion of Jordion]:
			return 14;
		case $item[autocalliope]:
		case $item[non-Euclidean non-accordion]:
		case $item[Shakespeare's Sister's Accordion]:
		case $item[Squeezebox of the Ages]:
			return 15;
		case $item[ghost accordion]:
			return 16;
		case $item[pygmy concertinette]:
			return 17;
		case $item[accordionoid rocca]:
			return 18;
		case $item[peace accordion]:
			return 19;
		case $item[alarm accordion]:
		case $item[The Trickster's Trikitixa]:
		case $item[zombie accordion]:
			return 20;
		default:
			return 0;
	}
}

boolean is_legal_accordion(item it)
{
	boolean [item] legalAccordions = $items[
		toy accordion,
		antique accordion,
		aerogel accordion,
	];
	return legalAccordions contains it;
}

int my_accordion_buff_duration()
{
	int longest = 0;
	foreach it in get_inventory()
	{
		int duration = accordion_buff_duration(it);
		if(duration > longest && (my_class() == $class[Accordion Thief]
			|| is_legal_accordion(it)))
			longest = duration;
	}
	if(item_amount($item[jewel-eyed wizard hat]) > 0)
		longest += 5;
	return longest;
}

item get_class_chocolate(class c)
{
	switch(c)
	{
		case $class[Seal Clubber]: return $item[chocolate seal-clubbing club];
		case $class[Turtle Tamer]: return $item[chocolate turtle totem];
		case $class[Pastamancer]: return $item[chocolate pasta spoon];
		case $class[Sauceror]: return $item[chocolate saucepan];
		case $class[Disco Bandit]: return $item[chocolate disco ball];
		case $class[Accordion Thief]: return $item[chocolate stolen accordion];
		default: return $item[none];
	}
}

boolean is_bloody(item it)
{
	return it.notes.contains_text("Vampyre");
}

boolean is_unwanted_text_effect(effect ef)
{
	return $effects[
		Just the Best Anapests,
	] contains ef;
}

boolean has_unwanted_text_effect(item it)
{
	return it.string_modifier("Effect").to_effect().is_unwanted_text_effect();
}

