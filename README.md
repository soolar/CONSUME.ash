# CONSUME.ash

CONSUME.ash is a script that will handle your diet in Kingdom of Loathing for you.

## Installation

Run this command in the graphical CLI:
<pre>
git checkout soolar/CONSUME.ash
</pre>
Will require [a recent build of KoLMafia](http://builds.kolmafia.us/job/Kolmafia/lastSuccessfulBuild/).

## Usage

First, work out how much meat an adventure is worth to you, and then enter
<pre>
set valueOfAdventure=that number
</pre>
After that, type `CONSUME HELP` in the gCLI to get a list of what you can do.
The output from `CONSUME SIM` can simply be copy/pasted in to the gCLI, if you so
desire, but repeat runs within the same session barely take any additional time,
so running `CONSUME ALL` after `CONSUME SIM` should be fine.

You can also set CONSUME.BASEMEAT to the base meat of whatever zone you meatfarm (if you meatfarm)
in order to have CONSUME consider the value of meat buffs in your diet. So far it only supports
sweet synthesis, but more is coming soon! As an example:
<pre>
set CONSUME.BASEMEAT=275
</pre>
is what you would want to do if you are farming barf mountain and have the songboom boombox.

## Supported

* General diet
* Nightcapping
* Saucemaven
* Pizza Lover
* Potion of the field gar
* Mojo filters
* Spice melange
* Ultra Mega Sour Ball
* Sweet Synthesis (optional)
* Mayoflex
* Frosty's Frosty Mug
* Ol' Scratch's Salad Fork
* Fudge Spork
* Special Seasoning
* Milk of Magnesium
* The Ode to Booze
* Mime army shotglass
* All chocolates other than LOV Extraterrestrial Chocolate (for now).
* Organ cleaning consumables (hobopolis/batfellow consumables)
* Considers cost of ingredients to make an item
* Essential tofu
* Ancestral Recall
* Alien plant pod
* Alien animal milk
* Hunger&trade; Sauce
* cuppa Voraci tea
* cuppa Sobrie tea
* sweet tooth
* lupine appetite hormones
* Universal Seasoning
* Meteorite Ade
* Jerks' Health&trade; Magazine
* synthetic dog hair pill (from Map to Safety Shelter Grimace Prime)
* distention pill (from Map to Safety Shelter Grimace Prime)
* Drip consumables (nugget/wine/caviar/plum(?)/pilsner)
* whet stone (from rock garden)
* Sweat Out Some Booze (from designer sweatpants)
* Aug. 16th: Roller Coaster Day! (from august scepter)
* extra time (from pile of burning leaves)
* mini kiwi aioli (from mini kiwi)
* clock (from Möbius ring)
* Stooper (when nightcapping)
* Maximizing for hp, hot res, and cold res if using any forks or mugs
* Restoring equipment to how it was before running the script if anything changed

# Calculating valueOfAdventure

valueOfAdventure can be a little tricky to get right. Contrary to popular belief,
it is NOT your gross profit divided by your # of adventures spent. It should
actually represent your worst case MPA, the MPA you achieve after any buffs that
don't last all day have worn off, because that's what you'r going to get from any
extra adventures that you add on to your diet.

First, look at your +meat% at the end of a day of farming. This is on top of the
base 100% meat you get from a monster without any +meat%, so add 100%. Multiply
this (the % number divided by 100) by the base meat of the area you farm. Then,
add any additional meat sources you have, such as screege's spectacles. This
should get you what you need to set valueOfAdventure to for optimal results.



For example:

Let's say I have 1000% +meat drops, and am farming barf mountain with songboom.
Barf mountain's base meat is 250, and songboom adds 25 to this, so you would
first multiply 275 by 11 to get 3025.

Now for the tricky part. We need to add
every additional source of meat from our shiny toys. First of all, the widely
popular mafia pointer finger ring. This does NOT count the songboom addition to
+meat, but is otherwise 200% meat dropped on a crit on average, so add 500 for 3525.

Next, Mr. Screege's spectacles. Between the meat items it drops and the pure
meat it drops, from what I hear it drops an average of roughly 180 MPA, besides
the +meat if provides (already factored in), so add 180 for 4325.

Next, lets consider the songboom's gathered meatclip drops. These give an average
of 520 meat according to the wiki, and drop every 11th combat. That gives us
roughly 47 MPA, so now we're up to 4372.

Moving along, the meat provided by the dark horse from the horsery. This grants
10-15 meat per combat, for an average of 13ish (I rounded down on the meat clip,
so I'm rounding up here). Now we're at 4385 MPA.

Next, let's look at the drops from the Robortender, from giving it a Feliz Navidad.
Frankly, I have absolutely no idea how much MPA this adds. Candy is worth a
decent bit though since the advent of Sweet Synthesis. Going by a brief grepping
of my log files, it looks like the robort drops candy roughly... a quarter of the
time? Let's go with that. Candy can be worth anywhere from 400 to 3000 meat, give
or take. Let's err on the side of caution and say that on average it will probably
be around 1000 meat or so, which means this is another 250 MPA. Up to 4635 MPA.

The robort also drops stuff from I Refuse! if you feed it a hobo drink. Most of
this stuff is truly worthless though, so I'm not even going to bother accounting
for it. Still worth it though, since you can get urinal cakes to throw at people.

Next up is the buddy bjorn. The best bjorn familiar (to my understanding) is the
warbear drone. This drops a warbear whosit every 4th or 5th combat, and those
sell for about 885 at the time of this writing, so that averages to 197 MPA.
Now we're at 4832.

Now, normal barrels from the shrine of the barrel god. Grepping my logs shows
something along the lines of a 1/10 drop rate. Most of the drops from a normal
barrel sell for 115 meat, so let's just call it 11.5 meat, and round that to 12.
Now we're at 4844.

Finally, hilarious drops from pantogram pants. There's roughly a 1/20 chance for
a drop, and a 1/23 chance for that to be a fake hand. Fake hands go for 60k meat
on the low end, so that's about 130 MPA. We're at 4974.

Now, we have to account for the fact that 1/30 adventures are replaced with a
non-combat. Multiply the results by 29/30, and add 1/30 times 1750, the average
yield of the noncombat. That puts us squarely at 4867 meat or so.

Lastly, we can multiply this by 1.05 if you use the mafia thumb ring, since that
gives an extra adventure 5% of the time. Final result is 5110 MPA.

After accounting for everything other than just the base meat, we've gone up by
a whopping 2085 MPA.

Obviously not everyone has every shiny listed here, so you'll have to work out
your MPA on your own based on this example. I also don't have every shiny that
exists, so I may have missed some things too. But hopefully this example makes
it completely clear how to find out your valueOfAdventure on your own!

## Special Thanks

I'm writing this script for my own sake, but my clannies at Reddit United have been very supportive!

Especially Rag Nymph (#2662313),
JorGen Van Doe (#3069483),
aurumbos (#2343846),
Lyft (#3045223),
and LordHaplo (#3165152),
all of whom have made my time all the more worthwhile with their kind donations!
