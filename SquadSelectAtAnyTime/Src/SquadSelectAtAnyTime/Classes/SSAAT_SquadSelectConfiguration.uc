//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class holds the configuration which will be used to adjust the
//           behaviour of Squad Select screen as well as methods to simplify filling in
//           this object
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_SquadSelectConfiguration extends Object;

struct SSAAT_SlotNote
{
	var string Text;
	var string TextColor;
	var string BGColor;
};

struct SSAAT_SlotConfiguration
{
	var EUIPersonnelType PersonnelType;
	var delegate<CanUnitBeSelected> CanUnitBeSelectedFn;
	var array<SSAAT_SlotNote> Notes;
};

// Opening the screen
var protected delegate<AugmentFakeMissionSite> AugmentFakeMissionSiteFn;
var protected bool bDisallowAutoFill;
var protected bool bSkipIntroAnimation;

// Slots
var protected array<SSAAT_SlotConfiguration> Slots;

// Launch button
var protected delegate<CanClickLaunch> CanClickLaunchFn;
var protected delegate<OnLaunch> OnLaunchFn;
var protected bool bReplaceLaunchText;
var protected string LaunchLabelLine1;
var protected string LaunchLabelLine2;
var protected bool bConfirmLaunch;
var protected string LaunchConfirmTitle;
var protected string LaunchConfirmText;
var protected delegate<CanClickLaunch> ShouldShowConfirmFn;
var protected bool bShowSkyrangerTakeoff;

// Removal of default UI elements
var protected array<name> PanelsToRemove;
var protected array<name> PanelsToHide;
var protected bool bHideMissionInfo;

// Disable narratives/events
var protected bool bPreventOnSizeLimitedEvent;
var protected bool bPreventOnSuperSizeEvent;

// Frozen state (configuration is complete)
var private bool bIsFrozen;

// Useful when the configuration was created via CreateWithDefaults and then you want to modify aspects
var bool bDisableGetBeforeFreezeWarning;

// Delegate declarations
delegate bool CanUnitBeSelected(XComGameState_Unit Unit, int iSlot);
delegate bool CanClickLaunch();
delegate OnLaunch();
delegate AugmentFakeMissionSite(XComGameState_MissionSite MissionSite);

// Error checking helpers
`define ReportError(error) `REDSCREEN(`error); `REDSCREEN(GetScriptTrace());
`define EnsureNotFrozenForSetter if (bIsFrozen) {`ReportError("Cannot edit SSAAT_SquadSelectConfiguration after it was frozen"); return;}
`define WarnNotFrozenForGetter `log("Warning: SSAAT_SquadSelectConfiguration is not intended to be read before being frozen", !bIsFrozen && !bDisableGetBeforeFreezeWarning, 'SSAAT')

static function SSAAT_SquadSelectConfiguration CreateWithDefaults()
{
	local SSAAT_SquadSelectConfiguration Configuration;

	Configuration = new class'SSAAT_SquadSelectConfiguration';

	Configuration.SetDefaultSlots();
	Configuration.SetHideMissionInfo(true);
	Configuration.RemoveTerrainAndEnemiesPanels();
	
	Configuration.SetPreventOnSizeLimitedEvent(true);
	Configuration.SetPreventOnSuperSizeEvent(true);

	return Configuration;
}

////////////////////////////////////
/// Opening the screen - getters ///
////////////////////////////////////

function GetAugmentFakeMissionSiteFn(out delegate<AugmentFakeMissionSite> Fn)
{
	`WarnNotFrozenForGetter;
	Fn = AugmentFakeMissionSiteFn;
}

// Here to workaround "Can't call instance functions from within static functions" error when invoking delegates from static functions
function CallAugmentFakeMissionSiteFn(XComGameState_MissionSite MissionSite)
{
	local delegate<AugmentFakeMissionSite> LocalAugmentFakeMissionSiteFn;

	GetAugmentFakeMissionSiteFn(LocalAugmentFakeMissionSiteFn);
	if (LocalAugmentFakeMissionSiteFn != none) LocalAugmentFakeMissionSiteFn(MissionSite);
}

function bool ShouldDisallowAutoFill()
{
	`WarnNotFrozenForGetter;
	return bDisallowAutoFill;
}

function bool ShouldSkipIntroAnimation()
{
	`WarnNotFrozenForGetter;
	return bSkipIntroAnimation;
}

////////////////////////////////////
/// Opening the screen - setters ///
////////////////////////////////////

function SetAugmentFakeMissionSiteFn(delegate<AugmentFakeMissionSite> Fn)
{
	`EnsureNotFrozenForSetter;
	AugmentFakeMissionSiteFn = Fn;
}

function SetDisallowAutoFill(bool DisallowAutoFill)
{
	`EnsureNotFrozenForSetter;
	bDisallowAutoFill = DisallowAutoFill;
}

function SetSkipIntroAnimation(bool SkipIntroAnimation)
{
	`EnsureNotFrozenForSetter;
	bSkipIntroAnimation = SkipIntroAnimation;
}

///////////////////////
/// SLOTS - GETTERS ///
///////////////////////

function int GetNumSlots()
{
	`WarnNotFrozenForGetter;
	return Slots.Length;
}

function SSAAT_SlotConfiguration GetSlotConfiguration(int i)
{
	`WarnNotFrozenForGetter;
	return Slots[i];
}

function array<SSAAT_SlotConfiguration> GetSlots()
{
	`WarnNotFrozenForGetter;
	return Slots;
}

function bool IsUnitEligible(XComGameState_Unit Unit, int iSlot)
{
	local delegate<CanUnitBeSelected> CanUnitBeSelectedFn;

	`WarnNotFrozenForGetter;

	CanUnitBeSelectedFn = Slots[iSlot].CanUnitBeSelectedFn;
	return CanUnitBeSelectedFn(Unit, iSlot);
}

///////////////////////
/// SLOTS - SETTERS ///
///////////////////////

function SetDefaultSlots()
{
	local array<SSAAT_SlotConfiguration> arrSlots;
	local int i, MaxSlots;

	MaxSlots = class'X2StrategyGameRulesetDataStructures'.static.GetMaxSoldiersAllowedOnMission();
	arrSlots.Length = MaxSlots;

	for(i = 0; i < MaxSlots; i++)
	{
		arrSlots[i].PersonnelType = eUIPersonnel_Soldiers;
		arrSlots[i].CanUnitBeSelectedFn = static.DefaultCanSoldierBeSelected;
	}

	SetSlots(arrSlots);
}

function SetSlots(array<SSAAT_SlotConfiguration> InSlots)
{
	local int i;
	
	`EnsureNotFrozenForSetter;

	if (InSlots.Length == 0)
	{
		`ReportError("Got an empty array");
	}

	// No foreach cuz we might change the contents of the array
	for(i = 0; i < InSlots.Length; i++)
	{
		InternalValidateSlot(InSlots[i]);
	}

	Slots = InSlots;
}

function SetSlot(int i, SSAAT_SlotConfiguration InSlot)
{
	InternalValidateSlot(InSlot);
	Slots[i] = InSlot;
}

function protected InternalValidateSlot(out SSAAT_SlotConfiguration InSlot)
{
	// Check staff type
	if (
		InSlot.PersonnelType != eUIPersonnel_Soldiers && 
		InSlot.PersonnelType != eUIPersonnel_Scientists && 
		InSlot.PersonnelType != eUIPersonnel_Engineers
	) {
		`ReportError(InSlot.PersonnelType @ "is not supported by SSAAT_SlotConfiguration, defaulting to eUIPersonnel_Soldiers");
		InSlot.PersonnelType = eUIPersonnel_Soldiers;
	}

	// check delegate
	if (InSlot.CanUnitBeSelectedFn == none) {
		`ReportError("Slot has no CanUnitBeSelectedFn set, defaulting to base Squad Select behaviour");
		InSlot.CanUnitBeSelectedFn = static.DefaultCanSoldierBeSelected;
	}
}

static function bool DefaultCanSoldierBeSelected(XComGameState_Unit Unit, int iSlot)
{
	return Unit.CanGoOnMission() && !`XCOMHQ.IsUnitInSquad(Unit.GetReference());
}

///////////////////////////////
/// LAUNCH BUTTON - GETTERS ///
///////////////////////////////

function bool ShouldShowLaunchButton()
{
	`WarnNotFrozenForGetter;
	return CanClickLaunchFn != none;
}

function GetCanClickLaunchFn(out delegate<CanClickLaunch> Fn)
{
	`WarnNotFrozenForGetter;
	Fn = CanClickLaunchFn;
}

function GetOnLaunchFn(out delegate<OnLaunch> Fn)
{
	`WarnNotFrozenForGetter;
	Fn = OnLaunchFn;
}

function GetShouldShowConfirmFn(out delegate<CanClickLaunch> Fn)
{
	`WarnNotFrozenForGetter;
	Fn = ShouldShowConfirmFn;
}

function bool ShouldShowSkyrangerTakeoff()
{
	`WarnNotFrozenForGetter;
	return bShowSkyrangerTakeoff;
}

function bool ShouldReplaceLaunchText()
{
	`WarnNotFrozenForGetter;
	return bReplaceLaunchText;
}

function bool ShouldConfirmLaunch()
{
	`WarnNotFrozenForGetter;
	return bConfirmLaunch;
}

function string GetLauchLabelLine1()
{
	`WarnNotFrozenForGetter;
	return LaunchLabelLine1;
}

function string GetLauchLabelLine2()
{
	`WarnNotFrozenForGetter;
	return LaunchLabelLine2;
}

function string GetLaunchConfirmTitle()
{
	`WarnNotFrozenForGetter;
	return LaunchConfirmTitle;
}

function string GetLaunchConfirmText()
{
	`WarnNotFrozenForGetter;
	return LaunchConfirmText;
}

///////////////////////////////
/// LAUNCH BUTTON - SETTERS ///
///////////////////////////////

function SetCanClickLaunchFn(delegate<CanClickLaunch> Fn)
{
	`EnsureNotFrozenForSetter;
	CanClickLaunchFn = Fn;
}

function SetLaunchBehaviour(delegate<OnLaunch> Fn, bool ShowSkyrangerTakeoff)
{
	`EnsureNotFrozenForSetter;
	
	OnLaunchFn = Fn;
	bShowSkyrangerTakeoff = ShowSkyrangerTakeoff;
}

function EnableLaunchLabelReplacement(string Line1, string Line2)
{
	`EnsureNotFrozenForSetter;

	bReplaceLaunchText = true;
	LaunchLabelLine1 = Line1;
	LaunchLabelLine2 = Line2;
}

function DisableLaunchLabelReplacement()
{
	`EnsureNotFrozenForSetter;

	bReplaceLaunchText = false;
	LaunchLabelLine1 = "";
	LaunchLabelLine2 = "";
}

function EnableLaunchConfirmation(string Title, string Text, delegate<CanClickLaunch> Fn)
{
	`EnsureNotFrozenForSetter;

	bConfirmLaunch = true;
	LaunchConfirmTitle = Title;
	LaunchConfirmText = Text;
	ShouldShowConfirmFn = Fn;
}

function DisableLaunchConfirmation()
{
	`EnsureNotFrozenForSetter;

	bConfirmLaunch = false;
	LaunchConfirmTitle = "";
	LaunchConfirmText = "";
	ShouldShowConfirmFn = none;
}

////////////////////////////
/// UI REMOVAL - GETTERS ///
////////////////////////////

function bool ShouldHideMissionInfo()
{
	`WarnNotFrozenForGetter;
	return bHideMissionInfo;
}

function array<name> GetPanelsToRemove()
{
	`WarnNotFrozenForGetter;
	return PanelsToRemove;
}

function array<name> GetPanelsToHide()
{
	`WarnNotFrozenForGetter;
	return PanelsToHide;
}

////////////////////////////
/// UI REMOVAL - SETTERS ///
////////////////////////////

function SetHideMissionInfo(bool HideMissionInfo)
{
	`EnsureNotFrozenForSetter;
	bHideMissionInfo = HideMissionInfo;
}

// Panel names of "Show Enemies and Terrain on Mission Planning" mod
function RemoveTerrainAndEnemiesPanels()
{
	local array<name> Panels;

	// Enemies
	Panels.AddItem('EnemiesPanel');
	Panels.AddItem('EnemiesPanelDetail');
	Panels.AddItem('EnemiesDetectedTitle');
	Panels.AddItem('EnemiesList');
	Panels.AddItem('EnemiesIconsPanel');
	Panels.AddItem('EnemiesIcons');
	//Panels.AddItem('DebugText');

	// Terrain
	Panels.AddItem('PlotPanel');
	Panels.AddItem('BiomePanel');
	Panels.AddItem('TimePanel');
	Panels.AddItem('Plot');
	Panels.AddItem('Biome');
	Panels.AddItem('Time');

	AddPanelsToRemove(Panels);
}

function SetPanelsToRemove(array<name> Panels)
{
	`EnsureNotFrozenForSetter;
	PanelsToRemove = Panels;
}

function AddPanelsToRemove(array<name> Panels)
{
	local name Panel;

	`EnsureNotFrozenForSetter;

	if (PanelsToRemove.Length == 0)
	{
		// Avoid the checks
		SetPanelsToRemove(Panels);
		return;
	}

	foreach Panels(Panel)
	{
		if(PanelsToRemove.Find(Panel) == INDEX_NONE) {
			PanelsToRemove.AddItem(Panel);
		}
	}
}

function SetPanelsToHide(array<name> Panels)
{
	`EnsureNotFrozenForSetter;
	PanelsToHide = Panels;
}

function AddPanelsToHide(array<name> Panels)
{
	local name Panel;

	`EnsureNotFrozenForSetter;

	if (PanelsToHide.Length == 0)
	{
		// Avoid the checks
		SetPanelsToHide(Panels);
		return;
	}

	foreach Panels(Panel)
	{
		if(PanelsToHide.Find(Panel) == INDEX_NONE) {
			PanelsToHide.AddItem(Panel);
		}
	}
}

////////////////////////////////////
/// EVENT INTERCEPTION - GETTERS ///
////////////////////////////////////

function bool ShouldPreventOnSizeLimitedEvent()
{
	`WarnNotFrozenForGetter;
	return bPreventOnSizeLimitedEvent;
}

function bool ShouldPreventOnSuperSizeEvent()
{
	`WarnNotFrozenForGetter;
	return bPreventOnSuperSizeEvent;
}

////////////////////////////////////
/// EVENT INTERCEPTION - SETTERS ///
////////////////////////////////////

function SetPreventOnSizeLimitedEvent(bool NewValue)
{
	`EnsureNotFrozenForSetter;
	bPreventOnSizeLimitedEvent = NewValue;
}

function SetPreventOnSuperSizeEvent(bool NewValue)
{
	`EnsureNotFrozenForSetter;
	bPreventOnSuperSizeEvent = NewValue;
}

//////////////////////////////
/// CONFIGURATION FREEZING ///
//////////////////////////////

function SetFrozen()
{
	bIsFrozen = true;
}

function bool IsFrozen()
{
	return bIsFrozen;
}