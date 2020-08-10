int ORGAN_STOMACHE = 1;
int ORGAN_LIVER = 2;
int ORGAN_SPLEEN = 3;
int ORGAN_NONE = 4;
int ORGAN_EQUIP = 5;
// anything from here on is less of an organ and more of a specific command
int ORGAN_STOOPER = 6; // familiar stooper
int ORGAN_MAXIMIZE_FOR_FORK_MUG = 7; // maximize hp,10cold res,10hot res
int ORGAN_CHECKPOINT = 8; // checkpoint
int ORGAN_RESTORE = 9; // familiar currfam; outfit checkpoint

int MAX_MEAT = 999999999999;

int ADV_VALUE = get_property("valueOfAdventure").to_int();
int BASE_MEAT = get_property("CONSUME.BASEMEAT").to_int();
int PVP_VALUE = get_property("CONSUME.PVPVAL").to_int();
