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
	item tool; // fork/mug/spork
	item mayo;
};

boolean is_same(DietAction da1, DietAction da2)
{
	return da1.it == da2.it &&
		da1.sk == da2.sk &&
		da1.tool == da2.tool &&
		da1.mayo == da2.mayo;
}

//=============================================================================
// DIET
//=============================================================================
record Diet
{
	DietAction [int] actions;
	int [item] counts;
	item lastMayo;
};

boolean within_limit(Diet d, item it)
{
	return (daily_limit(it) == -1) || (d.counts[it] < daily_limit(it));
}

item get_fork_mug(Consumable c);
boolean use_seasoning();

DietAction to_action(Consumable c, Diet d)
{
	DietAction da;
	da.it = c.it;
	da.sk = c.sk;
	da.organ = c.organ;
	da.space = c.space;
	// figure out the tool
	if(c.useForkMug)
		da.tool = c.get_fork_mug();
	if(c.useSporkIfPossible && d.counts[$item[fudge spork]] == 0)
		da.tool = $item[fudge spork];
	if(c.bestMayo != $item[none])
		da.mayo = c.bestMayo;

	return da;
}

void add_counts(Diet d, DietAction da)
{
	if(da.it != $item[none])
		d.counts[da.it]++;
	if(da.tool != $item[none])
		d.counts[da.tool]++;
	if(da.mayo != $item[none])
		d.counts[da.mayo]++;
	if(da.organ == ORGAN_STOMACHE && use_seasoning())
		d.counts[$item[special seasoning]]++;
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

Range total_adventures(Diet d)
{
	Range totalAdventures = new Range(0, 0);
	foreach i,da in d.actions
		totalAdventures.add(da.get_adventures());
	return totalAdventures;
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
