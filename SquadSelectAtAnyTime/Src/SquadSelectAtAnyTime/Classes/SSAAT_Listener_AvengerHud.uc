//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to add a button to "Armory" menu to open the Squad Select
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_Listener_AvengerHud extends UIScreenListener dependson(SSAAT_SquadSelectConfiguration); 

var localized string Button_Label;
var localized string Button_Description;

event OnInit(UIScreen Screen)
{
	local UIAvengerHUD AvengerHud;
	local UIAvengerShortcutSubMenuItem MenuItem;

	AvengerHud = UIAvengerHUD(Screen);
	if (AvengerHud == none) return;

	MenuItem.Id = 'SSAAT_OpenSquadSelect';
	MenuItem.Message.Label = Button_Label;
	MenuItem.Message.Description = Button_Description;
	MenuItem.Message.OnItemClicked = OnButtonClicked;

	AvengerHud.Shortcuts.AddSubMenu(eUIAvengerShortcutCat_Barracks, MenuItem);
}

static protected function OnButtonClicked(optional StateObjectReference Facility)
{
	local SSAAT_SquadSelectConfiguration Configuration;
	local array<SSAAT_SlotConfiguration> Slots;

	Configuration = class'SSAAT_SquadSelectConfiguration'.static.CreateWithDefaults();
	Slots = Configuration.GetSlots();
	Slots.Length = 3;

	Slots[0].PersonnelType = eUIPersonnel_Engineers;
	Slots[0].CanUnitBeSelectedFn = CanCivilianBeSelected;

	Slots[1].PersonnelType = eUIPersonnel_Scientists;
	Slots[1].CanUnitBeSelectedFn = CanCivilianBeSelected;

	//Slots[2].PersonnelType = eUIPersonnel_Scientists;
	Slots[2].CanUnitBeSelectedFn = IsMajorAndCanGoOnMission;

	Configuration.SetSlots(Slots);
	Configuration.SetFrozen();

	class'SSAAT_Opener'.static.ShowSquadSelect(Configuration);
}

static function bool CanCivilianBeSelected(XComGameState_Unit Unit)
{
	return Unit.IsAlive() && Unit.IsActive(true);
}

static function bool IsMajorAndCanGoOnMission(XComGameState_Unit Unit)
{
	return class'SSAAT_SquadSelectConfiguration'.static.DefaultCanSoldierBeSelected(Unit) && Unit.GetSoldierRank() > 5;
}