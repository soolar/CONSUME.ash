script "Capitalistic Optimal Noms Script (Ultra Mega Edition)";
notify "soolar the second";
since r20283; // Consumable tagging

import <CONSUME/INFO.ash>
import <CONSUME/CONSTANTS.ash>
import <CONSUME/RECORDS.ash>
import <CONSUME/HELPERS.ash>

boolean useSeasoning = false;
boolean use_seasoning() { return useSeasoning; } // for use in RECORDS.ash
boolean havePinkyRing = available_amount($item[mafia pinky ring]) > 0;
boolean haveTuxedoShirt = available_amount($item[tuxedo shirt]) > 0;
int mojoFiltersUseable = daily_limit($item[mojo filter]);
int songDuration = my_accordion_buff_duration();

boolean firstPassComplete = false;
boolean consumablesEvaluated = false;

int stomache_value(int space);
int liver_value(int space);
int spleen_value(int space);

Consumable [int] food;
Consumable [int] booze;
Consumable [int] spleenies;

Range get_adventures(DietAction da)
{
	Range advs = da.it.get_adventures();
	if(da.organ == ORGAN_STOMACHE)
	{
		if(useSeasoning)
			advs.add(1);
		if(da.mayo == $item[Mayoflex])
			advs.add(1);
		if(da.it.is_saucy() && have_skill($skill[Saucemaven]))
			advs.add($classes[Pastamancer, Sauceror] contains my_class() ? 5 : 3);
		if(da.it.is_lasagna() && !is_monday())
			advs.add(5); // account for potion of the field gar
		advs.add(da.space); // account for milk
	}
	else if(da.organ == ORGAN_LIVER)
	{
		if(havePinkyRing && da.it.is_wine())
			advs.multiply_round_nearest(1.125);
		if(haveTuxedoShirt && da.it.is_martini())
			advs.add(new Range(1, 3));
		if(have_skill($skill[The Ode to Booze]) && songDuration > 0)
			advs.add(da.space);
	}

	switch(da.tool)
	{
		case $item[Ol\' Scratch\'s salad fork]:
			advs.multiply_round_up(da.it.is_salad() ? 1.5 : 1.3);
			break;
		case $item[Frosty\'s frosty mug]:
			advs.multiply_round_up(da.it.is_beer() ? 1.5 : 1.3);
			break;
		case $item[fudge spork]:
			advs.add(3);
			break;
	}

	if(da.sk == $skill[Ancestral Recall])
		advs.add(3);
	if(da.it == $item[Hunger&trade; Sauce])
		advs.add(3);

	return advs;
}

float get_value(DietAction da)
{
	Range advs = da.get_adventures();
	float value = advs.average() * ADV_VALUE;
	if(da.it != $item[none])
		value -= da.it.item_price();
	if(da.tool != $item[none])
		value -= da.tool.item_price();
	if(da.mayo != $item[none])
		value -= da.mayo.item_price();
	if(da.organ == ORGAN_STOMACHE && useSeasoning)
		value -= $item[Special Seasoning].item_price();
	
	if(da.sk == $skill[Sweet Synthesis])
	{
		item [int] greedCandies = sweet_synthesis_pair($effect[Synthesis: Greed]);
		int greedPrice = greedCandies[0].item_price() + greedCandies[1].item_price();
		value += BASE_MEAT * 3 * 30 - greedPrice;
	}
	else if(da.sk == $skill[Ancestral Recall])
		value -= $item[blue mana].item_price();

	if(firstPassComplete)
	{
		foreach i,oc in da.cleanings
		{
			switch(oc.organ)
			{
				case ORGAN_STOMACHE: value += stomache_value(oc.space); break;
				case ORGAN_LIVER: value += liver_value(oc.space); break;
				case ORGAN_SPLEEN: value += spleen_value(oc.space); break;
				default: print("Something bad happened."); break;
			}
		}
	}

	return value;
}

float get_value(Consumable c, Diet d)
{
	DietAction da = c.to_action(d);
	return da.get_value();
}

void evaluate_special_items()
{
	if($item[Special Seasoning].item_price() < ADV_VALUE)
		useSeasoning = true;
	else
		useSeasoning = false;
}

void evaluate_consumable(Consumable c)
{
	item forkMug = c.get_fork_mug();
	if(forkMug != $item[none])
	{
		boolean forkMugBonus = (forkMug == $item[ol\' scratch\'s salad fork]) ?
			c.it.is_salad() : c.it.is_beer();
		float forkMugMult = forkMugBonus ? 0.5 : 0.3;
		Range forkMugAdvs = c.it.get_adventures();
		forkMugAdvs.multiply_round_up(forkMugMult);
		float forkMugValue = forkMugAdvs.average() * ADV_VALUE - forkMug.item_price();
		if(c.organ == ORGAN_STOMACHE)
		{
			float sporkValue = 3 * ADV_VALUE - $item[fudge spork].item_price();
			if(sporkValue > 0 && sporkValue > forkMugValue)
				c.useSporkIfPossible = true;
		}
		if(forkMugValue > 0)
			c.useForkMug = true;
	}

	if(c.organ == ORGAN_STOMACHE && npc_price($item[Mayoflex]) != 0)
	{
		if(item_price($item[Mayoflex]) < ADV_VALUE)
			c.bestMayo = $item[Mayoflex];
	}

	record OrganMatcher
	{
		matcher m;
		int organ;
	};
	OrganMatcher [int] organMatchers =
	{
		new OrganMatcher(create_matcher("-(\\d+) Fullness", c.it.notes), ORGAN_STOMACHE),
		new OrganMatcher(create_matcher("-(\\d+) Drunkesnness", c.it.notes), ORGAN_LIVER),
		new OrganMatcher(create_matcher("-(\\d+) spleen", c.it.notes), ORGAN_SPLEEN),
	};
	foreach i,om in organMatchers
	{
		if(om.m.find())
		{
			int space = om.m.group(1).to_int();
			c.cleanings[c.cleanings.count()] = new OrganCleaning(om.organ, space);
		}
	}
}

void evaluate_consumables()
{
	clear(food);
	clear(booze);
	clear(spleenies);
	boolean [item] lookups;
	// can't directly assign this to lookups or it becomes a constant
	foreach it in $items[
		frosty's frosty mug,
		ol' scratch's salad fork,
		Special Seasoning,
		mojo filter,
		fudge spork,
		essential tofu,
		milk of magnesium,
		alien plant pod,
		alien animal milk,
		Hunger&trade; Sauce,
		ultra mega sour ball,
		sweet tooth,
		cuppa Voraci tea,
		cuppa Sobrie tea,
		lupine appetite hormones,
	]
		lookups[it] = true;
	foreach it in $items[]
	{
		if(it.tradeable.to_boolean() == false || it == $item[Jeppson\'s Malort])
			continue;

		if(it.is_bloody())
			continue;

		if(it.levelreq > my_level())
			continue;

		if(it.chocolate)
		{
			lookups[it] = true;
			continue;
		}

		if(BASE_MEAT > 0 && have_skill($skill[Sweet Synthesis]) && it.candy_type == "complex" &&
			sweet_synthesis_pairing($effect[Synthesis: Greed], it).count() > 0)
		{
			lookups[it] = true;
			continue;
		}

		if(it == $item[blue mana] && have_skill($skill[Ancestral Recall]))
		{
			lookups[it] = true;
			continue;
		}

		Consumable c;
		c.it = it;
		c.space = 0;
		if(it.fullness > 0 && it.inebriety == 0)
		{
			c.space = it.fullness;
			c.organ = ORGAN_STOMACHE;
		}
		else if(it.inebriety > 0 && it.fullness == 0)
		{
			c.space = it.inebriety;
			c.organ = ORGAN_LIVER;
		}
		else if(it.spleen > 0)
		{
			c.space = it.spleen;
			c.organ = ORGAN_SPLEEN;
		}

		if(c.space == 0)
			continue;

		float advs_per_space = c.it.get_adventures().average() / c.space;
		if((c.organ == ORGAN_STOMACHE && advs_per_space >= 4.5) || // 4.5 for food idk
			(c.organ == ORGAN_LIVER && advs_per_space >= 6) || // 6 for liver because elemental caipiroska
			(c.organ == ORGAN_SPLEEN && advs_per_space > 0)) // anything for spleen
		{
			lookups[it] = true;
			if(care_about_ingredients(it))
			{
				foreach ingredient in get_ingredients(it)
					lookups[ingredient] = true;
			}
			switch(c.organ)
			{
				case ORGAN_STOMACHE: food[food.count()] = c; break;
				case ORGAN_LIVER: booze[booze.count()] = c; break;
				case ORGAN_SPLEEN: spleenies[spleenies.count()] = c; break;
				default: print("Consumable with no organ specified?");
			}
		}
	}
	print("Looking up the price of " + lookups.count() + " items");
	mall_prices(lookups);

	evaluate_special_items();

	foreach i,c in food
		evaluate_consumable(c);
	foreach i,c in booze
		evaluate_consumable(c);
	foreach i,c in spleenies
		evaluate_consumable(c);
	
	Diet d;
	sort food by -value.get_value(d) / value.space;
	sort booze by -value.get_value(d) / value.space;
	sort spleenies by -value.get_value(d) / value.space;

	// now get_value will try to account for cleared out organ space
	firstPassComplete = true;

	sort food by -value.get_value(d) / value.space;
	sort booze by -value.get_value(d) / value.space;
	sort spleenies by -value.get_value(d) / value.space;

	void print_some(Consumable [int] list)
	{
		for(int i = 0; i < 5; ++i)
		{
			Consumable c = list[i];
			buffer b;
			b.append(i);
			b.append(": ");
			b.append(c.it.to_string());
			if(c.useForkMug)
			{
				switch(c.organ)
				{
					case ORGAN_STOMACHE: b.append(" (w/fork)"); break;
					case ORGAN_LIVER: b.append(" (w/mug)"); break;
					default: b.append(" (useForkMug true but not food/booze...)"); break;
				}
			}
			b.append(" (");
			b.append(c.get_value(d) / c.space);
			b.append(")");
			print(b.to_string());
		}
	}
	/*
	print("food" + (useSeasoning ? " (use Special Seasoning)" : ""));
	print_some(food);
	print("booze");
	print_some(booze);
	print("spleenies");
	print_some(spleenies);
	*/

	consumablesEvaluated = true;
}

void evaluate_consumables_if_needed()
{
	if(!consumablesEvaluated)
		evaluate_consumables();
}

int space_value(Consumable [int] list, int space)
{
	if(space <= 0)
		return 0;

	float value = 0;

	foreach i,c in list
	{
		// assume the list is sorted already
		if(c.space <= space)
		{
			int amount = floor(space / c.space);
			value += c.get_value(new Diet()) * amount;
			space -= c.space * amount;
			if(space <= 0)
				break;
		}
	}

	return value;
}

int stomache_value(int space)
{
	return space_value(food, space);
}

int liver_value(int space)
{
	return space_value(booze, space);
}

int spleen_value(int space)
{
	return space_value(spleenies, space);
}

int organ_value(int stomache, int liver, int spleen)
{
	return stomache_value(stomache) + liver_value(liver) + spleen_value(spleen);
}

Consumable best_consumable(Diet d, Consumable [int] list, int space)
{
	if(space <= 0)
	{
		return new Consumable();
	}
	evaluate_consumables_if_needed();
	foreach i,c in list
	{
		if(c.space <= space && d.within_limit(c.it))
			return c;
	}

	Consumable nothing;
	return nothing;
}

Consumable best_spleen(Diet d, int space)
{
	Consumable res = d.best_consumable(spleenies, space);
	if(space > 0 && res.it == $item[none])
		print("Failed to find spleenie of size " + space + "!", "red");
	return res;
}

Consumable best_stomache(Diet d, int space)
{
	Consumable res = d.best_consumable(food, space);
	if(space > 0 && res.it == $item[none])
		print("Failed to find food of size " + space + "!", "red");
	return res;
}

Consumable best_liver(Diet d, int space)
{
	Consumable res = d.best_consumable(booze, space);
	if(space > 0 && res.it == $item[none])
		print("Failed to find booze of size " + space + "!", "red");
	return res;
}

void handle_organ_cleanings(Diet d, Consumable c, OrganSpace space, OrganSpace max);

void fill_spleen(Diet d, OrganSpace space, OrganSpace max)
{
	while(space.spleen > 0)
	{
		Consumable best = d.best_spleen(space.spleen);
		if(best.is_nothing())
			break;
		space.spleen -= best.space;
		DietAction da = best.to_action(d);
		d.add_action(da);
	}
	if(space.spleen > 0)
		print("Failed to fully fill spleen! " + space.spleen + " left...", "red");
}

void fill_stomache(Diet d, OrganSpace space, OrganSpace max)
{
	while(space.fullness > 0)
	{
		Consumable best = d.best_stomache(space.fullness);
		if(best.is_nothing())
			break;
		handle_organ_cleanings(d, best, space, max);
		space.fullness -= best.space;
		DietAction da = best.to_action(d);
		d.add_action(da);
		if(da.tool == $item[fudge spork])
			sort food by -value.get_value(d) / value.space;
	}
	if(space.fullness > 0)
		print("Failed to fully fill stomache! " + space.fullness + " left...", "red");
}

void fill_liver(Diet d, OrganSpace space, OrganSpace max)
{
	while(space.inebriety > 0)
	{
		Consumable best = d.best_liver(space.inebriety);
		if(best.is_nothing())
			break;
		handle_organ_cleanings(d, best, space, max);
		space.inebriety -= best.space;
		DietAction da = best.to_action(d);
		d.add_action(da);
	}
	if(space.inebriety > 0)
		print("Failed to fully fill liver! " + space.inebriety + " left...", "red");
}

void handle_special_items(Diet d, OrganSpace space, OrganSpace max)
{
	if(mojoFiltersUseable > 0)
	{
		float mojoValue = spleen_value(mojoFiltersUseable) / mojoFiltersUseable -
			item_price($item[mojo filter]);
		if(mojoValue > 0)
		{
			Consumable mojoFilter;
			mojoFilter.it = $item[mojo filter];
			mojoFilter.organ = ORGAN_NONE;
			mojoFilter.cleanings[0] = new OrganCleaning(ORGAN_SPLEEN, 1);
			for(int i = 0; i < mojoFiltersUseable; ++i)
			{
				d.handle_organ_cleanings(mojoFilter, space, max);
				d.add_action(mojoFilter.to_action(d));
			}
			mojoFiltersUseable = 0;
		}
	}

	if(d.within_limit($item[spice melange]))
	{
		float spiceValue = stomache_value(3) + liver_value(3) -
			$item[spice melange].item_price();
		if(spiceValue > 0)
		{
			Consumable spiceMelange;
			spiceMelange.it = $item[spice melange];
			spiceMelange.organ = ORGAN_NONE;
			spiceMelange.cleanings[0] = new OrganCleaning(ORGAN_STOMACHE, 3);
			spiceMelange.cleanings[1] = new OrganCleaning(ORGAN_LIVER, 3);
			d.handle_organ_cleanings(spiceMelange, space, max);
			d.add_action(spiceMelange.to_action(d));
		}
	}

	if(d.within_limit($item[Ultra Mega Sour Ball]))
	{
		float sourBallValue = stomache_value(3) + liver_value(3) -
			$item[Ultra Mega Sour Ball].item_price();
		if(sourBallValue > 0)
		{
			Consumable sourBall;
			sourBall.it = $item[Ultra Mega Sour Ball];
			sourBall.organ = ORGAN_NONE;
			sourBall.cleanings[0] = new OrganCleaning(ORGAN_STOMACHE, 3);
			sourBall.cleanings[1] = new OrganCleaning(ORGAN_LIVER, 3);
			d.handle_organ_cleanings(sourBall, space, max);
			d.add_action(sourBall.to_action(d));
		}
	}

	if(d.within_limit($item[alien animal milk]))
	{
		float alienMilkValue = stomache_value(3) - $item[alien animal milk].item_price();
		if(alienMilkValue > 0)
		{
			Consumable alienMilk;
			alienMilk.it = $item[alien animal milk];
			alienMilk.organ = ORGAN_NONE;
			alienMilk.cleanings[0] = new OrganCleaning(ORGAN_STOMACHE, 3);
			d.handle_organ_cleanings(alienMilk, space, max);
			d.add_action(alienMilk.to_action(d));
		}
	}

	if(d.within_limit($item[alien plant pod]))
	{
		float plantPodValue = liver_value(3) - $item[alien plant pod].item_price();
		if(plantPodValue > 0)
		{
			Consumable plantPod;
			plantPod.it = $item[alien plant pod];
			plantPod.organ = ORGAN_NONE;
			plantPod.cleanings[0] = new OrganCleaning(ORGAN_LIVER, 3);
			d.handle_organ_cleanings(plantPod, space, max);
			d.add_action(plantPod.to_action(d));
		}
	}

	if(d.within_limit($item[cuppa Sobrie tea]))
	{
		float sobrieTeaValue = liver_value(1) - $item[cuppa Sobrie tea].item_price();
		if(sobrieTeaValue > 0)
		{
			Consumable sobrieTea;
			sobrieTea.it = $item[cuppa Sobrie tea];
			sobrieTea.organ = ORGAN_NONE;
			sobrieTea.cleanings[0] = new OrganCleaning(ORGAN_LIVER, 1);
			d.handle_organ_cleanings(sobrieTea, space, max);
			d.add_action(sobrieTea.to_action(d));
		}
	}

	if(d.within_limit($item[essential tofu]))
	{
		DietAction useTofu;
		useTofu.it = $item[essential tofu];
		useTofu.organ = ORGAN_NONE;
		if(useTofu.get_value() > 0)
			d.add_action(useTofu);
	}

	if(have_skill($skill[Ancestral Recall]) && d.within_limit($item[blue mana]))
	{
		DietAction castRecall;
		castRecall.sk = $skill[Ancestral Recall];
		castRecall.organ = ORGAN_NONE;
		if(castRecall.get_value() > 0)
		{
			while(d.within_limit($item[blue mana]))
				d.add_action(castRecall);
		}
	}
}

void handle_organ_cleanings(Diet d, Consumable c, OrganSpace space, OrganSpace max)
{
	foreach i,oc in c.cleanings
	{
		switch(oc.organ)
		{
			case ORGAN_SPLEEN:
				if(space.spleen + oc.space > max.spleen)
					fill_spleen(d, space, max);
				space.spleen += oc.space;
				space.spleen = min(space.spleen, max.spleen);
				break;
			case ORGAN_STOMACHE:
				if(space.fullness + oc.space > max.fullness)
					fill_stomache(d, space, max);
				space.fullness += oc.space;
				space.fullness = min(space.fullness, max.fullness);
				break;
			case ORGAN_LIVER:
				if(space.inebriety + oc.space > max.inebriety)
					fill_liver(d, space, max);
				space.inebriety += oc.space;
				space.inebriety = min(space.inebriety, max.inebriety);
				break;
		}
	}
}

void handle_chocolates(Diet d)
{
	item classChoco = get_class_chocolate(my_class());
	item cheapestClass = get_cheapest($items[
		chocolate seal-clubbing club,
		chocolate turtle totem,
		chocolate pasta spoon,
		chocolate saucepan,
		chocolate disco ball,
		chocolate stolen accordion,
	]);
	item cheapestNormal = get_cheapest($items[
		fancy chocolate,
		fancy but probably evil chocolate,
		fancy chocolate car,
		beet-flavored Mr. Mediocrebar,
		cabbage-flavored Mr. Mediocrebar,
		sweet-corn-flavored Mr. Mediocrebar,
		choco-Crimbot,
	]);
	for(int chocount = get_property("_chocolatesUsed").to_int(); chocount < 3; ++chocount)
	{
		int normalAdvs = 5 - 2 * chocount;
		int classAdvs = 3 - chocount;
		int offClassAdvs = 2 - chocount;
		float normalVal = normalAdvs * ADV_VALUE - cheapestNormal.item_price();
		float classVal = classAdvs * ADV_VALUE - classChoco.item_price();
		float offClassVal = offClassAdvs * ADV_VALUE - cheapestClass.item_price();
		item best = $item[none];
		int bestVal = 0;
		if(normalVal > bestVal)
		{
			bestVal = normalVal;
			best = cheapestNormal;
		}
		if(classChoco != $item[none] && classVal > bestVal)
		{
			bestVal = classVal;
			best = classChoco;
		}
		if(offClassVal > bestVal)
		{
			bestVal = offClassVal;
			best = cheapestClass;
		}
		if(best != $item[none])
		{
			DietAction eatChoco;
			eatChoco.it = best;
			eatChoco.organ = ORGAN_NONE;
			d.add_action(eatChoco);
		}
	}
	// broken in to its own loop so the resulting diet looks better
	for(int vitaAdvs = 5 - 2 * get_property("_vitachocCapsulesUsed").to_int(); vitaAdvs > 0; vitaAdvs -= 2)
	{
		int vitaPrice = $item[vitachoconutriment capsule].item_price();
		int vitaVal = vitaAdvs * ADV_VALUE - vitaPrice;
		if(vitaVal > 0)
		{
			DietAction eatVita;
			eatVita.it = $item[vitachoconutriment capsule];
			eatVita.organ = ORGAN_NONE;
			d.add_action(eatVita);
		}
	}
	// once again, it's own loop just for the diet's appearance
	for(int cigarAdvs = 5 - 2 * get_property("_chocolateCigarsUsed").to_int(); cigarAdvs > 0; cigarAdvs -= 2)
	{
		int cigarPrice = $item[chocolate cigar].item_price();
		int cigarVal = cigarAdvs * ADV_VALUE - cigarPrice;
		if(cigarVal > 0)
		{
			DietAction eatCigar;
			eatCigar.it = $item[chocolate cigar];
			eatCigar.organ = ORGAN_NONE;
			d.add_action(eatCigar);
		}
	}
	// own loop for diet appearance, no chocolate preference for this one??
	for(int artAdvs = 5 - 2 * get_property("_chocolateSculpturesUsed").to_int(); artAdvs > 0; artAdvs -= 2)
	{
		int artPrice = $item[fancy chocolate sculpture].item_price();
		int artVal = artAdvs * ADV_VALUE - artPrice;
		if(artVal > 0)
		{
			DietAction eatArt;
			eatArt.it = $item[fancy chocolate sculpture];
			eatArt.organ = ORGAN_NONE;
			d.add_action(eatArt);
		}
	}
}

void handle_stomache_expander(Diet d, OrganSpace space, OrganSpace max, item expander, int expansion)
{
	if(!d.within_limit(expander))
		return;
	int valueExpander = stomache_value(space.fullness + expansion) -
		stomache_value(space.fullness) - expander.item_price();
	if(valueExpander > 0)
	{
		DietAction useExpander;
		useExpander.it = expander;
		useExpander.organ = ORGAN_NONE;
		d.add_action(useExpander);
		space.fullness += expansion;
		max.fullness += expansion;
	}
}

void handle_organ_expanders(Diet d, OrganSpace space, OrganSpace max, boolean nightcap)
{
	d.handle_stomache_expander(space, max, $item[cuppa Voraci tea], 1);
	d.handle_stomache_expander(space, max, $item[sweet tooth], 1);
	d.handle_stomache_expander(space, max, $item[lupine appetite hormones], 3);
	if(nightcap && my_familiar() != $familiar[stooper])
	{
		DietAction useStooper;
		useStooper.organ = ORGAN_STOOPER;
		d.add_action(useStooper);
		space.inebriety += 1;
		max.inebriety += 1;
	}
}

Diet get_diet(OrganSpace space, OrganSpace max, boolean nightcap)
{
	evaluate_consumables_if_needed();

	Diet d;
	d.nightcap = nightcap;

	d.handle_organ_expanders(space, max, nightcap);

	// do the shotglass drink first
	if(item_amount($item[mime army shotglass]) > 0 &&
		!get_property("_mimeArmyShotglassUsed").to_boolean())
	{
		int actualLiver = space.inebriety;
		space.inebriety = 1;
		fill_liver(d, space, max);
		space.inebriety += actualLiver;
	}

	if(space.fullness <= 0 && space.inebriety <= 0 && space.spleen <= 0)
	{
		handle_special_items(d, space, max);
	}

	while(space.fullness > 0 || (space.inebriety > 0 ||
		(nightcap && space.inebriety >= 0)) || space.spleen > 0)
	{
		if(space.spleen > 0)
		{
			fill_spleen(d, space, max);
			if(space.spleen > 0)
			 break;
		}
		if(space.fullness > 0)
		{
			fill_stomache(d, space, max);
			if(space.fullness > 0)
				break;
		}
		if(space.inebriety > 0)
		{
			fill_liver(d, space, max);
			if(space.inebriety > 0)
				break;
		}
		handle_special_items(d, space, max);

		if(nightcap && space.fullness <= 0 && space.inebriety <= 0 && space.spleen <= 0)
		{
			nightcap = false;
			sort booze by -value.get_value(d);
			d.add_action(booze[0].to_action(d));
			d.handle_organ_cleanings(booze[0], space, max);
			sort booze by -value.get_value(d) / value.space;
		}
	}
	handle_chocolates(d);

	// prepend hunger sauce if it's good and you're eating any food
	if(d.total_organ_fillers(ORGAN_STOMACHE) > 0)
	{
		DietAction useHungerSauce;
		useHungerSauce.it = $item[Hunger&trade; Sauce];
		useHungerSauce.organ = ORGAN_NONE;
		if(useHungerSauce.get_value() > 0)
			d.insert_action(useHungerSauce, 0);
	}

	// prepend potion of the field gar if necessary
	if(d.has_lasagna())
	{
		DietAction useGar;
		useGar.it = $item[potion of the field gar];
		useGar.organ = ORGAN_NONE;
		d.insert_action(useGar, 0);
	}

	// prepend equipping pinky ring is necessary
	if(havePinkyRing && d.has_wine())
	{
		DietAction equipPinkyRing;
		equipPinkyRing.it = $item[mafia pinky ring];
		equipPinkyRing.organ = ORGAN_EQUIP;
		d.insert_action(equipPinkyRing, 0);
	}

	// prepend equipping tuxedo shirt if necessary
	if(haveTuxedoShirt && d.has_martini())
	{
		DietAction equipTuxedoShirt;
		equipTuxedoShirt.it = $item[tuxedo shirt];
		equipTuxedoShirt.organ = ORGAN_EQUIP;
		d.insert_action(equipTuxedoShirt, 0);
	}

	// prepend maximizing for fork and mug if needed
	if(d.has_fork_mug())
	{
		DietAction maximizeForkMug;
		maximizeForkMug.organ = ORGAN_MAXIMIZE_FOR_FORK_MUG;
		d.insert_action(maximizeForkMug, 0);
	}

	// prepend milk and ode
	OrganSpace spaceTaken = d.total_space();
	if(spaceTaken.fullness > 0 && !get_property("_milkOfMagnesiumUsed").to_boolean())
	{
		float milkValue = ADV_VALUE * 5 - item_price($item[milk of magnesium]);
		if(milkValue > 0)
		{
			DietAction milk;
			milk.it = $item[milk of magnesium];
			milk.organ = ORGAN_NONE;
			d.insert_action(milk, 0);
		}
	}
	if(have_skill($skill[The Ode to Booze]) && songDuration > 0)
	{
		DietAction ode;
		ode.sk = $skill[The Ode to Booze];
		ode.organ = ORGAN_NONE;
		int turnsNeeded = spaceTaken.inebriety - have_effect($effect[Ode to Booze]);
		int casts = ceil(to_float(turnsNeeded) / songDuration);
		for(int i = 0; i < casts; ++i)
			d.insert_action(ode, 0);
	}

	// go through your spleen actions from the end and replace with
	// sweet synthesis as appropriate
	if(have_skill($skill[Sweet Synthesis]) && BASE_MEAT > 0)
	{
		DietAction synthesizeGreed;
		synthesizeGreed.sk = $skill[Sweet Synthesis];
		synthesizeGreed.organ = ORGAN_SPLEEN;
		synthesizeGreed.space = 1;
		float greedValue = synthesizeGreed.get_value();
		for(int i = d.actions.count() - 1; i >= 0; --i)
		{
			if(d.total_synthesis_turns() >= my_adventures() + d.total_adventures().average())
				break;

			if(d.actions[i].organ == ORGAN_SPLEEN && d.actions[i].sk != $skill[Sweet Synthesis])
			{
				if(d.actions[i].get_value() / d.actions[i].space < greedValue)
				{
					int spaceToFill = d.actions[i].space - 1;
					d.remove_action(i);
					while(spaceToFill > 0)
					{
						Consumable filler = d.best_spleen(spaceToFill);
						spaceToFill -= filler.space;
						d.insert_action(filler.to_action(d), i);
						++i;
					}
					d.insert_action(synthesizeGreed, i);
				}
			}
		}
	}

	if(d.has_equipment_changes())
	{
		DietAction checkpoint;
		checkpoint.organ = ORGAN_CHECKPOINT;
		DietAction restore;
		restore.organ = ORGAN_RESTORE;
		d.insert_action(checkpoint, 0);
		d.add_action(restore);
	}

	return d;
}

Diet get_diet(int stom, int liv, int sple, boolean nightcap)
{
	return get_diet(new OrganSpace(stom, liv, sple),
		new OrganSpace(fullness_limit(), inebriety_limit(), spleen_limit()),
		nightcap);
}

void append_item(buffer b, item it, int organ, int amount, boolean nightcap)
{
	switch(organ)
	{
		case ORGAN_STOMACHE: b.append("eat "); break;
		case ORGAN_LIVER: b.append(nightcap ? "drinksilent " : "drink "); break;
		case ORGAN_SPLEEN: b.append("chew "); break; // maybe someday?
		case ORGAN_NONE: b.append("use "); break;
		case ORGAN_EQUIP: b.append("equip "); break;
		default: print("Umm... Something happened?", "red"); break;
	}
	if(amount != 1)
	{
		b.append(amount);
		b.append(" ");
	}
	b.append(it.to_string());
	b.append("; ");
}

void append_diet_action(buffer b, DietAction da, int amount, Diet d)
{
	if(da.mayo != $item[none] && da.mayo != d.lastMayo)
	{
		if(item_amount($item[Mayo Minder&trade;]) == 0)
			b.append("acquire Mayo Minder; ");
		b.append("mayominder ");
		b.append(da.mayo);
		b.append("; ");
		d.lastMayo = da.mayo;
	}
	if(da.tool != $item[none])
		b.append_item(da.tool, da.organ, amount, d.nightcap);

	if(da.it != $item[none])
		b.append_item(da.it, da.organ, amount, d.nightcap);
	else if(da.sk == $skill[Sweet Synthesis])
	{
		for(int i = 0; i < amount; ++i)
			b.append("synthesize greed; ");
	}
	else if(da.sk != $skill[none])
	{
		b.append("cast ");
		if(amount != 1)
		{
			b.append(amount);
			b.append(" ");
		}
		b.append(da.sk.to_string());
		b.append("; ");
	}
	else if(da.organ == ORGAN_STOOPER)
		b.append("familiar stooper; ");
	else if(da.organ == ORGAN_MAXIMIZE_FOR_FORK_MUG)
		b.append("maximize hp,10cold res,10hot res; ");
	else if(da.organ == ORGAN_CHECKPOINT)
		b.append("checkpoint; ");
	else if(da.organ == ORGAN_RESTORE)
	{
		b.append("familiar ");
		b.append(my_familiar().to_string());
		b.append("; outfit checkpoint; ");
	}
	//else
		//print("BAD OCCURED", "red");
}

void append_diet(buffer b, Diet d)
{
	// get everything first, so that if something is too expensive your diet
	// isn't interrupted in the middle, since that's a pain in the butt
	foreach it,amount in d.counts
	{
		if(amount > 0)
		{
			b.append("acquire ");
			b.append(amount);
			b.append(" ");
			b.append(it.to_string());
			b.append("; ");
		}
	}
	DietAction last = d.actions[0];
	int count = 0;
	foreach i,da in d.actions
	{
		if(!da.is_same(last))
		{
			b.append_diet_action(last, count, d);
			count = 1;
			last = da;
		}
		else
			count++;
	}
	b.append_diet_action(last, count, d);
}

void print_diet(Diet d)
{
	buffer b;
	b.append("Your ideal diet: ");
	b.append_diet(d);
	print(b.to_string());
	int cost = d.total_cost();
	print("This should cost roughly " + cost.format() + " meat");
	Range advs = d.total_adventures();
	print("Adventure yield should be roughly " + advs.to_string());
	int profit = d.total_profit();
	print("That's an average profit of " + profit.format());
	profit += my_adventures() * ADV_VALUE;
	print("Including adventures you already have, you should profit " + profit.format() + " today");
	OrganSpace space = d.total_space();
	print("In total, you're filling up " + space.fullness + " fullness, " +
		space.inebriety + " liver, and " + space.spleen + " spleen");
}

void main(string command)
{
	if(command.to_upper_case() != command)
	{
		print("CONSUME only accepts superior capital letters!", "red");
		return;
	}

	boolean simulate = true;
	// this is set if SIM is present in the command, overrides NIGHTCAP and ALL
	boolean seriouslySimulate = false;
	boolean nightcap = false;
	int fullness = fullness_limit() - my_fullness();
	int fullnessLimit = fullness_limit();
	int inebriety = inebriety_limit() - my_inebriety();
	int inebrietyLimit = inebriety_limit();
	int spleen = spleen_limit() - my_spleen_use();
	int spleenLimit = spleen_limit();

	string [int] commands = command.split_string("\\s+");

	for(int i = 0; i < commands.count(); ++i)
	{
		switch(commands[i])
		{
			case "ALL":
				simulate = false;
				break;
			case "SIM":
				seriouslySimulate = true;
				break;
			case "NIGHTCAP":
				simulate = false;
				nightcap = true;
				break;
			case "ORGANS":
				if(i + 3 < commands.count())
				{
					simulate = false;
					fullness = commands[i + 1].to_int();
					inebriety = commands[i + 2].to_int();
					spleen = commands[i + 3].to_int();
					i += 3;
				}
				else
				{
					print("ORGANS requires three arguments: The amount of each organ " +
						"to fill, in the order stomache, liver, spleen.", "red");
					return;
				}
				break;
			case "NOMEAT":
				BASE_MEAT = 0;
				break;
			case "VALUE":
				if(i + 1 < commands.count())
				{
					ADV_VALUE = commands[i + 1].to_int();
					i += 1;
				}
				else
				{
					print("VALUE requires an argument: The amount to treat valueOfAdventure " +
						"as for this run.", "red");
					return;
				}
				break;
			case "HELP":
				print("CONSUME.ash Commands:", "blue");
				print("ALL - Fill all organs, for real.");
				print("SIM - Present a diet that would fill you up, but don't execute it.");
				print("NIGHTCAP - Fill all organs and then overdrink. Can be combined with SIM.");
				print("ORGANS X Y Z - Set the amount of each organ to fill. X Y and " +
					"Z should be numbers corresponding to stomache, liver, and spleen " +
					"respectively. Note that if you set these above your max, CONSUME " +
					"may behave oddly.");
				print("NOMEAT - Ignore CONSUME.BASEMEAT for this run.");
				print("VALUE X - Treat valueOfAdventure as X for this run.");
				print("CONSUME.ash Settings:", "blue");
				print('You can change these settings by typing "set SETTING=VALUE" in the gCLI.');
				print("valueOfAdventure - Technically a mafia property, not a CONSUME property, " +
					"but it is listed here because it is highly relevant to CONSUME. " +
					"Set this to however much meat you make in an adventure at the end of " +
					"the day (after brief buffs like meat.enh and A View to Some Meat wear off). " +
					"Or, more broadly, however much meat you consider an adventure to be worth.");
				print("CONSUME.BASEMEAT - The base meat of the area you are meatfarmings. " +
					"If you aren't meatfarming, leave this unset or set to 0. If you are farming " +
					"Barf Mountain, this should be 250, or 275 if you own and use a Songboom.");
				return;
			default:
				print('Unknown command "' + commands[i] + '"', "red");
				print('Try "CONSUME HELP" to get a list of valid commands.', "red");
				return;
		}
	}

	if(seriouslySimulate)
		simulate = true;

	evaluate_consumables();

	Diet d = get_diet(fullness, inebriety, spleen, nightcap);
	print_diet(d);

	if(!simulate)
	{
		buffer b;
		b.append_diet(d);
		cli_execute(b.to_string());
	}
}
