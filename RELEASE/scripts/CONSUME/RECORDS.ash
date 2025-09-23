//=============================================================================
// ORGAN SPACE
//=============================================================================
record OrganSpace
{
	int fullness;
	int inebriety;
	int spleen;
};

//=============================================================================
// RANGE
//=============================================================================
record Range
{
	int min;
	int max;
};

void multiply_round_down(Range r, float x)
{
	r.min = floor(r.min.to_float() * x);
	r.max = floor(r.max.to_float() * x);
}

void multiply_round_up(Range r, float x)
{
	r.min = ceil(r.min.to_float() * x);
	r.max = ceil(r.max.to_float() * x);
}

void multiply_round_nearest(Range r, float x)
{
	r.min = round(r.min.to_float() * x);
	r.max = round(r.max.to_float() * x);
}

void add(Range r, int x)
{
	r.min += x;
	r.max += x;
}

void add(Range r, Range r2)
{
	r.min += r2.min;
	r.max += r2.max;
}

float average(Range r)
{
	return (r.min.to_float() + r.max.to_float()) / 2.0;
}

string format(int i);

string to_string(Range r)
{
	return r.min.format() + "-" + r.max.format();
}

//=============================================================================
// ORGAN CLEANING
//=============================================================================
record OrganCleaning
{
	int organ;
	int space;
};

//=============================================================================
// CONSUMABLE
//=============================================================================
record Consumable
{
	item it;
	skill sk;
	int space;
	int organ;
	boolean useForkMug;
	OrganCleaning [int] cleanings;
	boolean useSporkIfPossible;
	item bestMayo;
	boolean useSeasoning;
	boolean useWhetStone;
	boolean useKiwiAioli;
};

boolean is_nothing(Consumable c)
{
	return c.it == $item[none] && c.sk == $skill[none];
}

boolean is_same(Consumable c1, Consumable c2)
{
	return c1.it == c2.it && c1.sk == c2.sk;
}

//=============================================================================
// DIET ACTION
//=============================================================================
record DietAction
{
	item it;
	skill sk;
	int organ;
	int space;
	item [int] tools; // fork/mug/spork/seasoning
	item mayo;
	OrganCleaning [int] cleanings;
	effect shrug;
};

boolean is_same(DietAction da1, DietAction da2)
{
	if((da1.it != da2.it ||
		da1.sk != da2.sk ||
		da1.tools.count() != da2.tools.count() ||
		da1.mayo != da2.mayo ||
		da1.organ != da2.organ ||
		da1.shrug != da2.shrug))
	{
		return false;
	}

	for(int i = 0; i < da1.tools.count(); ++i)
	{
		if(da1.tools[i] != da2.tools[i])
			return false;
	}

	return true;
}

boolean has_spork(DietAction da)
{
	foreach i,tool in da.tools
	{
		if(tool == $item[fudge spork])
			return true;
	}
	return false;
}

//=============================================================================
// DIET
//=============================================================================
record Diet
{
	DietAction [int] actions;
	int [item] counts;
	int [skill] casts;
	item lastMayo;
	boolean nightcap;
};

boolean within_limit(Diet d, item it)
{
	return (daily_limit(it) == -1) || (d.counts[it] < daily_limit(it));
}

boolean within_limit(Diet d, skill sk)
{
	return (daily_limit(sk) == -1) || (d.casts[sk] < daily_limit(sk));
}

item get_fork_mug(Consumable c);

DietAction to_action(Consumable c, Diet d)
{
	DietAction da;
	da.it = c.it;
	da.sk = c.sk;
	da.organ = c.organ;
	da.space = c.space;
	da.cleanings = c.cleanings;
	// figure out the tool(s)
	if(c.useSeasoning)
		da.tools[da.tools.count()] = $item[special seasoning];
	if(c.useWhetStone)
		da.tools[da.tools.count()] = $item[whet stone];
	if(c.useKiwiAioli)
		da.tools[da.tools.count()] = $item[mini kiwi aioli];
	if(c.useForkMug)
	{
		item fork_mug = c.get_fork_mug();
		if(d.within_limit(fork_mug)) {
			da.tools[da.tools.count()] = c.get_fork_mug();
		}
	}
	if(c.useSporkIfPossible && d.within_limit($item[fudge spork]))
		da.tools[da.tools.count()] = $item[fudge spork];
	if(c.organ == ORGAN_STOMACHE && d.within_limit($item[Universal Seasoning]))
		da.tools[da.tools.count()] = $item[Universal Seasoning];

	if(c.bestMayo != $item[none])
		da.mayo = c.bestMayo;

	return da;
}

void change_counts(Diet d, DietAction da, int amount)
{
	// it won't recommend equipment you don't already have
	if(da.it != $item[none] && da.organ != ORGAN_EQUIP)
		d.counts[da.it] += amount;
	foreach i, tool in da.tools
	{
		d.counts[tool] += amount;
	}
	if(da.mayo != $item[none])
		d.counts[da.mayo] += amount;
	if(da.sk == $skill[Sweet Synthesis])
	{
		item [int] greedCandies = sweet_synthesis_pair($effect[Synthesis: Greed]);
		d.counts[greedCandies[0]] += amount;
		d.counts[greedCandies[1]] += amount;
	}
	else if(da.sk == $skill[Ancestral Recall])
		d.counts[$item[blue mana]] += amount;
	else
		d.casts[da.sk] += amount;
}

void add_counts(Diet d, DietAction da)
{
	d.change_counts(da, 1);
}

void remove_counts(Diet d, DietAction da)
{
	d.change_counts(da, -1);
}

boolean add_action(Diet d, DietAction da)
{
	if(!d.within_limit(da.it))
		return false;

	d.actions[d.actions.count()] = da;
	d.add_counts(da);
	return true;
}

boolean insert_action(Diet d, DietAction da, int index)
{
	if(!d.within_limit(da.it))
		return false;

	int preCount = d.actions.count();
	for(int i = preCount - 1; i >= index; --i)
		d.actions[i + 1] = d.actions[i];
	d.actions[index] = da;
	d.add_counts(da);
	return true;
}

boolean replace_action(Diet d, int index, DietAction replacement)
{
	if(!d.within_limit(replacement.it))
		return false;

	d.remove_counts(d.actions[index]);
	d.actions[index] = replacement;
	d.add_counts(replacement);
	return true;
}

void remove_action(Diet d, int index)
{
	d.remove_counts(d.actions[index]);
	for(int i = index + 1; i < d.actions.count(); ++i)
		d.actions[i - 1] = d.actions[i];
	remove d.actions[d.actions.count() - 1];
}

OrganSpace total_space(Diet d)
{
	OrganSpace os = new OrganSpace(0, 0, 0);
	foreach i,da in d.actions
	{
		switch(da.organ)
		{
			case ORGAN_STOMACHE: os.fullness += da.space; break;
			case ORGAN_LIVER: os.inebriety += da.space; break;
			case ORGAN_SPLEEN: os.spleen += da.space; break;
		}
	}
	return os;
}

int item_price(item it);

int total_cost(Diet d)
{
	int cost = 0;
	foreach it,amount in d.counts
		cost += amount * it.item_price();
	return cost;
}

Range get_adventures(DietAction da);

int get_choco_adventures(Diet d)
{
	int normalChocoUsed = get_property("_chocolatesUsed").to_int();
	int vitaChocoUsed = get_property("_vitachocCapsulesUsed").to_int();
	int cigarChocoUsed = get_property("_chocolateCigarsUsed").to_int();
	int artChocoUsed = get_property("_chocolateSculpturesUsed").to_int();

	item classChoco = get_class_chocolate(my_class());
	boolean [item] classChocos;
	foreach c in $classes[Seal Clubber, Turtle Tamer, Pastamancer,
		Sauceror, Disco Bandit, Accordion Thief]
		classChocos[get_class_chocolate(c)] = true;

	int advs = 0;

	foreach i,da in d.actions
	{
		if(da.it.chocolate)
		{
			if(da.it == classChoco)
				advs += 3 - normalChocoUsed++;
			else if(classChocos contains da.it)
				advs += 2 - normalChocoUsed++;
			else if(da.it == $item[vitachoconutriment capsule])
				advs += 5 - 2 * vitaChocoUsed++;
			else if(da.it == $item[chocolate cigar])
				advs += 5 - 2 * cigarChocoUsed++;
			else if(da.it == $item[fancy chocolate sculpture])
				advs += 5 - 2 * artChocoUsed++;
			else
				advs += 5 - 2 * normalChocoUsed++;
		}
	}

	return advs;
}

int get_extra_time_adventures(Diet d)
{
	int extraTimeUsed = get_property("_extraTimeUsed").to_int();
	int advs = 0;
	foreach i,da in d.actions
	{
		if (da.it == $item[extra time])
		{
			advs += 5 - 2 * extraTimeUsed;
			extraTimeUsed++;
		}
	}
	return advs;
}

int get_clock_adventures(Diet d)
{
	int clocksUsed = get_property("_clocksUsed").to_int();
	int advs = 0;
	foreach i,da in d.actions
	{
		if (da.it == $item[clock])
		{
			advs += 3 - 1 * clocksUsed;
			clocksUsed++;
		}
	}
	return advs;
}

Range total_adventures(Diet d)
{
	Range totalAdventures = new Range(0, 0);
	foreach i,da in d.actions
		totalAdventures.add(da.get_adventures());
	totalAdventures.add(d.get_choco_adventures());
	totalAdventures.add(d.get_extra_time_adventures());
	totalAdventures.add(d.get_clock_adventures());
	return totalAdventures;
}

int get_fites(item it);

int total_fites(Diet d)
{
	int res = 0;
	foreach i,da in d.actions
		res += da.it.get_fites();
	return res;
}

int get_drippiness(item it);

int total_drippiness(Diet d)
{
	int res = 0;
	foreach i,da in d.actions
		res += da.it.get_drippiness();
	return res;
}

int total_organ_fillers(Diet d, int organ)
{
	int fillers = 0;
	foreach i,da in d.actions
	{
		if(da.organ == organ)
			fillers += 1;
	}
	return fillers;
}

int total_synthesis_turns(Diet d)
{
	int turns = 0;
	foreach i,da in d.actions
	{
		if(da.sk == $skill[Sweet Synthesis])
			turns += 30;
	}
	return turns;
}

float get_value(DietAction da);

float total_profit(Diet d)
{
	float profit = 0;
	foreach i,da in d.actions
		profit += da.get_value();
	return profit;
}

boolean has_lasagna(Diet d)
{
	foreach i,da in d.actions
	{
		if(da.it.is_lasagna())
			return true;
	}
	return false;
}

boolean has_wine(Diet d)
{
	foreach i,da in d.actions
	{
		if(da.it.is_wine())
			return true;
	}
	return false;
}

boolean has_martini(Diet d)
{
	foreach i,da in d.actions
	{
		if(da.it.is_martini())
			return true;
	}
	return false;
}

boolean has_equipment_changes(Diet d)
{
	foreach i,da in d.actions
	{
		if(da.organ == ORGAN_EQUIP || da.organ == ORGAN_MAXIMIZE_FOR_FORK_MUG)
			return true;
	}
	return false;
}

boolean has_fork_mug(Diet d)
{
	foreach i,da in d.actions
	{
		foreach i,tool in da.tools
		{
			if($items[Ol' Scratch's salad fork, Frosty's frosty mug] contains tool)
				return true;
		}
	}
	return false;
}

boolean has_unseasoned(Diet d)
{
	foreach i,da in d.actions
	{
		boolean isSeasoned = false;
		foreach i,tool in da.tools
		{
			if(tool == $item[special seasoning])
			{
				isSeasoned = true;
				break;
			}
		}
		if(!isSeasoned)
			return true;
	}
	return false;
}
