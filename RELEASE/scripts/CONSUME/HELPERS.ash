import <CONSUME/RECORDS.ash>
import <CONSUME/CONSTANTS.ash>

// get the pure adventure value of the item itself, raw
Range get_adventures(item it)
{
	switch(it)
	{
		case $item[none]: return new Range(0, 0);
		case $item[essential tofu]: return new Range(4, 6);
	}
	Range r;
	string [int] adv_strs = split_string(it.adventures, "-");
	r.min = adv_strs[0].to_int();
	r.max = adv_strs[(adv_strs.count() > 1) ? 1 : 0].to_int();
	return r;
}

int get_fites(item it)
{
	switch(it)
	{
		case $item[Meteorite-Ade]: return 5;
		case $item[Jerks' Health&trade; Magazine]: return 1;
	}
	matcher fiteMatcher = create_matcher("\\+(\\d+) PvP fights?", it.notes);
	if(fiteMatcher.find())
		return fiteMatcher.group(1).to_int();
	return 0;
}

int get_drippiness(item it)
{
	matcher dripMatcher = create_matcher("(\\d+) .g of Drippy Juice", it.notes);
	if(dripMatcher.find())
		return dripMatcher.group(1).to_int();
	return 0;
}

item get_fork_mug(Consumable c)
{
	// Vampyre can't easily sustain the damage from forks and mugs
	if(my_class() == $class[Vampyre])
	{
		return $item[none];
	}

	switch(c.organ)
	{
		case ORGAN_STOMACHE: return $item[ol' scratch's salad fork];
		case ORGAN_LIVER: return $item[frosty's frosty mug];
		default: return $item[none];
	}
}

boolean care_about_ingredients(item it)
{
	// TODO: Care about wads if you have malus access
	boolean [item] dontCare = $items[
		flat dough,
		wad of dough,
		hacked gibson,
		browser cookie,
		hot wad,
		cold wad,
		spooky wad,
		sleaze wad,
		stench wad,
		disassembled clover,
	];
	return !(dontCare contains it) && (it.fullness > 0 || it.inebriety > 0 || it.spleen > 0);
}

int item_price(item it)
{
	switch(it)
	{
		case $item[Universal Seasoning]:
			return 0;
		case $item[distention pill]:
		case $item[synthetic dog hair pill]:
			return 2 * ADV_VALUE + 0.5 * item_price($item[transporter transponder]);
	}

	int price = it.mall_price();
	if(price < 100) // mall min is 100
		price = npc_price(it);
	if(price == 0) // not for sale in mall or npc stores...
		price = MAX_MEAT;

	if(it.care_about_ingredients())
	{
		int [item] ingredients = get_ingredients(it);
		if(ingredients.count() > 0)
		{
			int ingredientsPrice = 0;
			foreach ingredient,amount in ingredients
			{
				ingredientsPrice += amount * item_price(ingredient);
			}
			if(ingredientsPrice < price)
				price = ingredientsPrice;
		}
	}

	return price;
}

string format(int i)
{
	return to_string(i, "%,d");
}

string format(float f)
{
	return to_string(f, "%,.0f");
}

item get_cheapest(boolean [item] items)
{
	item cheapest = $item[none];
	int cheapestPrice = MAX_MEAT;
	foreach it in items
	{
		int price = it.item_price();
		if(price < cheapestPrice)
		{
			cheapestPrice = price;
			cheapest = it;
		}
	}
	return cheapest;
}

int get_tool_organ(item tool)
{
	switch(tool)
	{
		case $item[special seasoning]:
			return ORGAN_AUTOMATIC;
		case $item[fudge spork]:
		case $item[Ol' Scratch's salad fork]:
			return ORGAN_STOMACHE;
		case $item[Frosty's frosty mug]:
			return ORGAN_LIVER;
		case $item[Universal Seasoning]:
		case $item[whet stone]:
			return ORGAN_NONE;
		default:
			return ORGAN_ERROR;
	}
}
