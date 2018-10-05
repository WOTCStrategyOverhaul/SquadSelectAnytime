//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to add a button to "Armory" menu to open the Squad Select
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_Listener_AvengerHud extends UIScreenListener;

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
	class'SSAAT_Opener'.static.ShowSquadSelect();
}