//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to replace UIPersonnel_SquadSelect with our custom
//           variant in case we are 
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_Listener_UIPersonnel_SquadSelect extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIPersonnel_SquadSelect OldPersonnel;
	local SSAAT_UIPersonnel_Select NewPersonnel;
	local XComPresentationlayerBase Pres;

	OldPersonnel = UIPersonnel_SquadSelect(Screen);
	if (OldPersonnel == none) return;

	// Check that we are inside SSAAT
	if (class'SSAAT_Helpers'.static.GetCurrentConfiguration() == none) return;

	Pres = OldPersonnel.Movie.Pres;

	// See XComHQPresentationLayer::UIPersonnel_SquadSelect
	NewPersonnel = Pres.Spawn(class'SSAAT_UIPersonnel_Select', Pres);
	NewPersonnel.onSelectedDelegate = OldPersonnel.onSelectedDelegate;
	NewPersonnel.GameState = OldPersonnel.GameState;
	NewPersonnel.HQState = OldPersonnel.HQState;

	Pres.ScreenStack.Pop(OldPersonnel);
	Pres.ScreenStack.Push(NewPersonnel);
}