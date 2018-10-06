//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to only hold data about the current "session" of SSAAT.
//           It is intended to be attached to UIAvengerHUD to be accessible globaly.
//           It doesn't contain any visual or interactive elements
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_SessionDataHolder extends UIPanel;

var const name PanelName;

var protectedwrite SSAAT_SquadSelectConfiguration Configuartion;

function InitDataHolder(SSAAT_SquadSelectConfiguration InConfiguartion)
{
	InitPanel(PanelName);
	Configuartion = InConfiguartion;
	
	if (UIAvengerHUD(ParentPanel) == none)
	{
		`REDSCREEN("SSAAT_SessionDataHolder is intended to be attached to UIAvengerHUD, instead attached to" @ ParentPanel.Name);
	}
}

function RegisterOnRemovedCallback(UISquadSelect TheScreen)
{
	TheScreen.AddOnRemovedDelegate(OnSquadSelectRemoved);
}

function protected OnSquadSelectRemoved(UIPanel Panel)
{
	// Shedule our removal in 0.5 seconds so that we are removed after all callbacks have fired
	SetTimer(0.5, false, nameof(Remove));
}

defaultproperties
{
	PanelName = "SSAAT_DataHolder";
}