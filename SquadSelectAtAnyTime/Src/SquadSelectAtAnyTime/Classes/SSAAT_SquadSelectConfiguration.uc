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

// Slots
var protected array<SSAAT_SlotConfiguration> Slots;

// Launch button
var protected delegate<CanClickLaunch> CanClickLaunchFn;

// Removal of default UI elements
var protected array<name> PanelsToRemove;
var protected array<name> PanelsToHide;
var protected bool bHideMissionInfo;

// Frozen state (configuration is complete)
var private bool bIsFrozen;

// Delegate declarations
delegate bool CanUnitBeSelected(XComGameState_Unit Unit);
delegate bool CanClickLaunch();

// Error checking helpers
`define ReportError(error) `REDSCREEN(`error); `REDSCREEN(GetScriptTrace());
`define EnsureNotFrozenForSetter if (bIsFrozen) {`ReportError("Cannot edit SSAAT_SquadSelectConfiguration after it was frozen"); return;}
`define WarnNotFrozenForGetter `log("Warning: SSAAT_SquadSelectConfiguration is not intended to be read before being frozen", !bIsFrozen, 'SSAAT')

static function SSAAT_SquadSelectConfiguration CreateWithDefaults()
{
	local SSAAT_SquadSelectConfiguration Configuration;

	Configuration = new class'SSAAT_SquadSelectConfiguration';

	Configuration.SetDefaultSlots();
	Configuration.SetHideMissionInfo(true);
	Configuration.RemoveTerrainAndEnemiesPanels();

	return Configuration;
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

static function bool DefaultCanSoldierBeSelected(XComGameState_Unit Unit)
{
	return Unit.CanGoOnMission();
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

///////////////////////////////
/// LAUNCH BUTTON - SETTERS ///
///////////////////////////////

function SetCanClickLaunchFn(delegate<CanClickLaunch> Fn)
{
	`EnsureNotFrozenForSetter;
	CanClickLaunchFn = Fn;
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