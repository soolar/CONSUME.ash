# CONSUME.ash

CONSUME.ash is a script that will handle your diet in Kingdom of Loathing for you.

## Installation

Run this command in the graphical CLI:
<pre>
svn checkout https://github.com/soolar/CONSUME.ash/trunk/RELEASE/
</pre>
Will require [a recent build of KoLMafia](http://builds.kolmafia.us/job/Kolmafia/lastSuccessfulBuild/).

## Usage

First, work out how much meat an adventure is worth to you, and then enter
<pre>
set valueOfAdventure=that number
</pre>
After that, type CONSUME in the gCLI. The output will be a sequence of commands you can copy/paste in to the gCLI to execute your chosen diet.

You can also set CONSUME.BASEMEAT to the base meat of whatever zone you meatfarm (if you meatfarm)
in order to have CONSUME consider the value of meat buffs in your diet. So far it only supports
sweet synthesis, but more is coming soon! As an example:
<pre>
set CONSUME.BASEMEAT=275
</pre>
is what you would want to do if you are farming barf mountain and have the songboom boombox.

## Todo

In rough order of importance:
* Actually execute the diet, instead of just printing a series of commands
* Optionally consider meat buffs from food/booze/spleen
* Improve item price calculation
* Consider drunki-bears (maybe)
* Handle pvp fight generation
* Consider spice melange and such
* Consider mayonnaise other than mayoflex
* Consider refined palate
* Probably much more I haven't though of yet

## Special Thanks

I'm writing this script for my own sake, but my clannies at Reddit United have been very supportive!

Especially Rag Nymph (#2662313), JorGen Van Doe (#3069483), and aurumbos (#2343846), all of whom have 
made my time all the more worthwhile with their kind donations!
