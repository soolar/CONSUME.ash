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

## Todo

In rough order of importance:
* Handle chocolates
* Care about how much organ space is already full
* Actually execute the diet, instead of just printing a series of commands
* Optionally consider meat buffs from food/booze/spleen (including sweet synthesis)
* Improve item price calculation
* Consider drunki-bears (maybe)
* Handle pvp fight generation
* Consider spice melange and such
* Consider mayonnaise
* Consider refined palate
* Probably much more I haven't though of yet
