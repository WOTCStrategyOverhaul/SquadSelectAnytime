//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to customize the soldier select list on the SS
//           for the fake mission, based on SSAAT_SquadSelectConfiguration
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_UIPersonnel_Select extends UIPersonnel;

var protected int SlotIndex;
var protected SSAAT_SlotConfiguration SlotConfig;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local UISquadSelect SquadSelect;

	SquadSelect = class'SSAAT_Helpers'.static.GetSquadSelect();
	SlotIndex = SquadSelect.m_iSelectedSlot;
	SlotConfig = class'SSAAT_Helpers'.static.GetCurrentConfiguration().GetSlotConfiguration(SlotIndex);

	// This line needs to be before super.InitScreen
	m_eListType = SlotConfig.PersonnelType;

	super.InitScreen(InitController, InitMovie, InitName);
}

simulated function UpdateList()
{
	local XComGameState_Unit Unit;
	local UIPersonnel_ListItem UnitItem;
	local delegate<SSAAT_SquadSelectConfiguration.CanUnitBeSelected> CanUnitBeSelectedFn;
	local int i;

	super.UpdateList();

	CanUnitBeSelectedFn = SlotConfig.CanUnitBeSelectedFn;

	// Disable any soldiers who are not eligible
	for (i = 0; i < m_kList.itemCount; ++i)
	{
		UnitItem = UIPersonnel_ListItem(m_kList.GetItem(i));
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitItem.UnitRef.ObjectID));

		if (!CanUnitBeSelectedFn(Unit, SlotIndex))
		{
			UnitItem.SetDisabled(true);
		}
	}
}

defaultproperties
{
	m_bRemoveWhenUnitSelected = true;
}