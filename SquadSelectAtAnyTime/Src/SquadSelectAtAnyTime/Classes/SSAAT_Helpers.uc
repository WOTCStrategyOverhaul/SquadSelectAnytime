//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class houses a couple of global helper methods that do not belong in 
//           other places
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_Helpers extends Object;

static function SSAAT_SessionDataHolder GetCurrentDataHolder(optional bool ErrorIfNotFound = true)
{
	local XComHQPresentationLayer HQPres;
	local SSAAT_SessionDataHolder DataHolder;

	HQPres = `HQPRES;
	DataHolder = SSAAT_SessionDataHolder(HQPres.m_kAvengerHUD.GetChildByName(class'SSAAT_SessionDataHolder'.default.PanelName, ErrorIfNotFound));

	// Can be none
	return DataHolder;
}

static function SSAAT_SquadSelectConfiguration GetCurrentConfiguration()
{
	local SSAAT_SessionDataHolder DataHolder;

	DataHolder = GetCurrentDataHolder(false);

	// Avoid "none accessed" warnings
	if (DataHolder == none) return none;

	return DataHolder.Configuration;
}

static function UISquadSelect GetSquadSelect()
{
	return GetSquadSelectFromStack(`HQPRES.ScreenStack);
}

static function UISquadSelect GetSquadSelectFromStack(UIScreenStack ScreenStack)
{
	return UISquadSelect(ScreenStack.GetFirstInstanceOf(class'UISquadSelect'));
}