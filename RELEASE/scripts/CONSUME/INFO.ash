boolean is_salad(item it)
{
	boolean [item] saladList = $items[
		Crimbo salad,
		Delicious salad,
		Delicious star salad,
		Kudzu salad,
		Nutty organic salad,
		Primitive alien salad,
		Super salad,
		Tofu wonton,
	];
	return saladList contains it;
}

boolean is_beer(item it)
{
	boolean [item] beerList = $items[
		Alewife&trade; Ale,
		Amnesiac Ale,
		Bark rootbeer,
		Beertini,
		Blood Light,
		Bloody beer,
		Bottle of Fishhead 900-Day IPA,
		Bottle of Greedy Dog,
		Bottle of Lambada Lambic,
		Bottle of Old Pugilist,
		Bottle of Professor Beer,
		Bottle of Race Car Red,
		Bottle of Rapier Witbier,
		Breaded beer,
		can of Br&uuml;talbr&auml;u,
		Can of Drooling Monk,
		Can of Impetuous Scofflaw,
		Can of Swiller,
		Can of the cheapest beer,
		Cheap Chinese beer,
		Cinco Mayo Lager,
		Cobb's Knob Wurstbrau,
		Cold One,
		Cream stout,
		CSA cheerfulness ration,
		Cup of primitive beer,
		Day-old beer,
		Ginger beer,
		Green beer,
		Highest Bitter,
		Ice porter,
		Ice stein,
		Ice-cold fotie,
		Ice-cold Sir Schlitz,
		Ice-cold Willer,
		Imp Ale,
		Large tankard of ale,
		McMillicancuddy's Special Lager,
		Mt. Noob Pale Ale,
		Overpriced &quot;imported&quot; beer,
		Paint A Vulgar Pitcher,
		Party beer bomb,
		Pebblebr&auml;u,
		Plain old beer,
		Plastic cup of beer,
		Pumpkin beer,
		Ram's Face Lager,
		Red ale,
		Saison du Lune,
		Silver Bullet beer,
		Tankard of ale,
		Thriller Ice,
		TRIO cup of beer,
	];
	return beerList contains it;
}

boolean is_wine(item it)
{
	boolean [item] wineList = $items[
		Bartles and BRAAAINS wine cooler,
		Beignet Milgranet,
		Bilge wine,
		Blackfly Chardonnay,
		Blood-red mushroom wine,
		Bordeaux Marteaux,
		Bottle of cooking sherry,
		Bottle of fruity &quot;wine&quot;,
		Bottle of laundry sherry,
		Bottle of Pinot Renoir,
		Bottle of realpagne,
		Bottle of wine,
		Boxed champagne,
		Bucket of wine,
		Buzzing mushroom wine,
		Canteen of wine,
		Carrot claret,
		Complex mushroom wine,
		Cool mushroom wine,
		CRIMBCO wine,
		Cruelty-free wine,
		Dusty bottle of Marsala,
		Dusty bottle of Merlot,
		Dusty bottle of Muscat,
		Dusty bottle of Pinot Noir,
		Dusty bottle of Port,
		Dusty bottle of Zinfandel,
		Expensive champagne,
		Flaming mushroom wine,
		Flask of port,
		Flat mushroom wine,
		Flute of flat champagne,
		Fromage Pinotage,
		Gingerbread wine,
		Gloomy mushroom wine,
		High-end ginger wine,
		Icy mushroom wine,
		Knob mushroom wine,
		Knoll mushroom wine,
		Lumineux Limnio,
		Magnum of fancy champagne,
		Mid-level medieval mead,
		Missing wine,
		Morto Moreto,
		Mulled berry wine,
		Muschat,
		Oily mushroom wine,
		Overpowering mushroom wine,
		Plum wine,
		Pointy mushroom wine,
		Psychotic Train wine,
		Red red wine,
		Sacramento wine,
		Smooth mushroom wine,
		Space port,
		Spooky mushroom wine,
		Stinky mushroom wine,
		Supernova Champagne,
		Swirling mushroom wine,
		Temps Tempranillo,
		Thistle wine,
		Warbear bearserker mead,
		Warbear blizzard mead,
		Warbear feasting mead,
		White wine,
		Ye Olde Meade,
	];
	return wineList contains it;
}

boolean is_martini(item it)
{
	boolean [item] martiniList = $items[
		dry martini,
		martini,
		dry vodka martini,
		gibson,
		vodka martini,
		vodka gibson,
		rockin' wagon,
		soft green echo eyedrop antidote martini,
	];
	return martiniList contains it;
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
		// TODO: MOOOOOOOOOOOOOORE
		default: return -1;
	}
}
