//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to remove or hide UIPanels (and children) that are not
//           needed when showing Squad Select for the fake mission
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_ElementRemover extends UIPanel;

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
	local SSAAT_SquadSelectConfiguration Configuration;
	local UISquadSelect SquadSelect;

	local array<name> Panels;
	local UIPanel ChildPanel;
	local name ChildName;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	SquadSelect = GetParentSquadSelect();

	Panels = Configuration.GetPanelsToRemove();
	foreach Panels(ChildName) {
		ChildPanel = SquadSelect.GetChildByName(ChildName, false);

		if (ChildPanel != none) ChildPanel.Remove();
	}

	Panels = Configuration.GetPanelsToHide();
	foreach Panels(ChildName) {
		ChildPanel = SquadSelect.GetChildByName(ChildName, false);

		if (ChildPanel != none) ChildPanel.Hide();
	}

	// Mission info and launch button need to be hidden via property as they uses auto-generated names
	// They aren't destroyed since that will cause "none accessed errors"
	if(Configuration.ShouldHideMissionInfo()) SquadSelect.m_kMissionInfo.Hide();
	if(!Configuration.ShouldShowLaunchButton()) SquadSelect.LaunchButton.Hide();

	// We are no longer needed
	Destroy();
}