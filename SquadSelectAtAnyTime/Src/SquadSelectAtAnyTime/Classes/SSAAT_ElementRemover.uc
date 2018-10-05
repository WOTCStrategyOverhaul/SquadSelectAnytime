//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to remove or hide UIPanels (and children) that are not
//           needed when showing Squad Select for the fake mission
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_ElementRemover extends UIPanel config(SSAAT);

var config array<name> PanelsToRemove;
var config array<name> PanelsToHide;

var config bool HideMissionInfo;
var config bool HideLaunchButton;

simulated function InitRemover() 
{
	InitPanel('SSAAT_ElementRemover');

	if (GetParentSquadSelect() == none) {
		`REDSCREEN("SSAAT_ElementRemover needs to be a child of UISquadSelect");
		Destroy();
	}

	// Delayed proccessing so that everything is created for sure
	SetTimer(1.0, false, nameof(DoRemoval));
}

simulated function UISquadSelect GetParentSquadSelect() 
{
	return UISquadSelect(ParentPanel);
}

simulated protected function DoRemoval()
{
	local UISquadSelect SquadSelect;
	local UIPanel ChildPanel;
	local name ChildName;

	SquadSelect = GetParentSquadSelect();

	foreach PanelsToRemove(ChildName) {
		ChildPanel = SquadSelect.GetChildByName(ChildName, false);

		if (ChildPanel != none) ChildPanel.Remove();
	}

	foreach PanelsToHide(ChildName) {
		ChildPanel = SquadSelect.GetChildByName(ChildName, false);

		if (ChildPanel != none) ChildPanel.Hide();
	}

	// Mission info and launch button need to be hidden via property as they uses auto-generated names
	// They aren't destroyed since that will cause "none accessed errors"
	if(HideMissionInfo) SquadSelect.m_kMissionInfo.Hide();
	if(HideLaunchButton) SquadSelect.LaunchButton.Hide();

	// We are no longer needed
	Destroy();
}