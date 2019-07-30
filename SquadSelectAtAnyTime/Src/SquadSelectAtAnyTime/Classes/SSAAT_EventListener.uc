//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class contains the logic that responds to certain events in case when 
//           the player is in SSAAT
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_EventListener extends X2EventListener dependson(SSAAT_SquadSelectConfiguration);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreatePreventNarrativeEvents());
	Templates.AddItem(CreateRoboSquadSelectHooks());
	Templates.AddItem(CreatePreScreenSetupEvents());

	return Templates;
}

////////////////////////////////
/// Prevent narrative events ///
////////////////////////////////

static function CHEventListenerTemplate CreatePreventNarrativeEvents()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'SSAAT_PreventNarrativeEvents');
	Template.AddCHEvent('OnSizeLimitedSquadSelect', OnSizeLimitedSquadSelect,, 2000);
	Template.AddCHEvent('OnSuperSizeSquadSelect', OnSuperSizeSquadSelect,, 2000);
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn OnSizeLimitedSquadSelect(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local SSAAT_SquadSelectConfiguration Configuration;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	
	if (Configuration == none) return ELR_NoInterrupt;
	if (!Configuration.ShouldPreventOnSizeLimitedEvent()) return ELR_NoInterrupt;

	return ELR_InterruptListeners;
}

static protected function EventListenerReturn OnSuperSizeSquadSelect(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local SSAAT_SquadSelectConfiguration Configuration;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	
	if (Configuration == none) return ELR_NoInterrupt;
	if (!Configuration.ShouldPreventOnSuperSizeEvent()) return ELR_NoInterrupt;

	return ELR_InterruptListeners;
}

/////////////////////
/// rjSquadSelect ///
/////////////////////

static function CHEventListenerTemplate CreateRoboSquadSelectHooks()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'SSAAT_RoboSquadSelectHooks');
	Template.RegisterInStrategy = true;
	
	Template.AddCHEvent('rjSquadSelect_ExtraInfo', AddSquadSelectSlotNotes, ELD_Immediate);
	Template.AddCHEvent('rjSquadSelect_SelectUnitString', ModifySelectUnitString, ELD_Immediate);
	Template.AddCHEvent('rjSquadSelect_UseCinematic', ConfigureDepartureCinematic, ELD_Immediate);
	Template.AddCHEvent('rjSquadSelect_AllowAutoFilling', AllowSquadAutoFill, ELD_Immediate);
	Template.AddCHEvent('rjSquadSelect_UseIntro', ConfigureIntro, ELD_Immediate);
	Template.AddCHEvent('rjSquadSelect_AllowCollapseSquad', ConfigureSquadCollapse, ELD_Immediate);

	return Template;
}

static protected function EventListenerReturn AddSquadSelectSlotNotes(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local SSAAT_SquadSelectConfiguration Configuration;
	local LWTuple Tuple;
	local int SlotIndex;

	local array<SSAAT_SlotNote> Notes;
	local LWTuple NoteTuple;
	local LWTValue Value;
	local int i;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	Tuple = LWTuple(EventData);
	
	// Check that we are interested in actually doing something
	if (Configuration == none || Tuple == none || Tuple.Id != 'rjSquadSelect_ExtraInfo') return ELR_NoInterrupt;

	SlotIndex = Tuple.Data[0].i;
	Notes = Configuration.GetSlotConfiguration(SlotIndex).Notes;

    Value.kind = LWTVObject;
    for (i = 0; i < Notes.Length; ++i)
    {
        NoteTuple = new class'LWTuple';
		NoteTuple.Data.Length = 3;

        NoteTuple.Data[0].kind = LWTVString;
        NoteTuple.Data[0].s = Notes[i].Text;
        
		NoteTuple.Data[1].kind = LWTVString;
        NoteTuple.Data[1].s = Notes[i].TextColor;
        
		NoteTuple.Data[2].kind = LWTVString;
        NoteTuple.Data[2].s = Notes[i].BGColor;

        Value.o = NoteTuple;
        Tuple.Data.AddItem(Value);
    }

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn ModifySelectUnitString(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local SSAAT_SquadSelectConfiguration Configuration;
	local LWTuple Tuple;
	local int SlotIndex;
	
	local EUIPersonnelType PersonnelType;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	Tuple = LWTuple(EventData);
	
	// Check that we are interested in actually doing something
	if (Configuration == none || Tuple == none || Tuple.Id != 'rjSquadSelect_SelectUnitString') return ELR_NoInterrupt;

	SlotIndex = Tuple.Data[0].i;
	PersonnelType = Configuration.GetSlotConfiguration(SlotIndex).PersonnelType;

	switch(PersonnelType)
	{
		case eUIPersonnel_Scientists:
			Tuple.Data[1].s = class'UIPersonnel_ChooseResearch'.default.m_strTitle;
			break;

		case eUIPersonnel_Engineers:
			Tuple.Data[1].s = class'UIPersonnel_BuildFacility'.default.m_strTitle;
			break;
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn ConfigureDepartureCinematic(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local SSAAT_SquadSelectConfiguration Configuration;
	local LWTuple Tuple;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	Tuple = LWTuple(EventData);
	
	// Check that we are interested in actually doing something
	if (Configuration == none || Tuple == none || Tuple.Id != 'rjSquadSelect_UseCinematic') return ELR_NoInterrupt;

	// Don't change anything if the button isn't supposed to be there
	if (!Configuration.ShouldShowLaunchButton()) return ELR_NoInterrupt;

	// We do not use the fadeout in any case
	Tuple.Data[0].i = Configuration.ShouldShowSkyrangerTakeoff() ? 0 : 2;

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn AllowSquadAutoFill(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local SSAAT_SquadSelectConfiguration Configuration;
	local LWTuple Tuple;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	Tuple = LWTuple(EventData);
	
	// Check that we are interested in actually doing something
	if (Configuration == none || Tuple == none || Tuple.Id != 'rjSquadSelect_AllowAutoFilling') return ELR_NoInterrupt;

	Tuple.Data[0].b = !Configuration.ShouldDisallowAutoFill();

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn ConfigureIntro(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local SSAAT_SquadSelectConfiguration Configuration;
	local LWTuple Tuple;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	Tuple = LWTuple(EventData);
	
	// Check that we are interested in actually doing something
	if (Configuration == none || Tuple == none || Tuple.Id != 'rjSquadSelect_UseIntro') return ELR_NoInterrupt;

	Tuple.Data[0].i = Configuration.ShouldSkipIntroAnimation() ? 1 : 0;

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn ConfigureSquadCollapse(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local SSAAT_SquadSelectConfiguration Configuration;
	local LWTuple Tuple;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	Tuple = LWTuple(EventData);
	
	// Check that we are interested in actually doing something
	if (Configuration == none || Tuple == none || Tuple.Id != 'rjSquadSelect_AllowCollapseSquad') return ELR_NoInterrupt;

	// We never allow squad collapse in SSAAT since the slots can have very strict requirments (and can differ)
	Tuple.Data[0].b = false;

	return ELR_NoInterrupt;
}

////////////////////////////
/// Pre-UISS squad setup ///
////////////////////////////

static function CHEventListenerTemplate CreatePreScreenSetupEvents()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'SSAAT_PreScreenSetup');
	Template.AddCHEvent('EnterSquadSelect', OnEnterSquadSelect); // This we want to trigger post gamestate submission
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn OnEnterSquadSelect(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local SSAAT_SquadSelectConfiguration Configuration;
	local XComGameStateHistory History;
	
	local XComGameState_HeadquartersXCom XcomHQ;
	local XComGameState NewGameState;
	local bool HasChanges;

	local array<XComGameState_Unit> KickedUnits;
	local array<int> SlotsToEmpty;

	local StateObjectReference UnitRef;
	local XComGameState_Unit Unit;
	local bool NeedsToBeKicked;
	local int iSlot;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("SSAAT: Pre-UISS squad setup");
	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	foreach XcomHQ.Squad(UnitRef, iSlot)
	{
		Unit = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));

		if (Unit == none)
		{
			continue;
		}

		if (Configuration == none)
		{
			// Normal mission, kick non-soldiers out
			NeedsToBeKicked = !Unit.IsSoldier();
		}
		else
		{
			if (iSlot > Configuration.GetNumSlots() - 1)
			{
				// We aren't even planning on having this slot at all, so kick in any case (maybe find another suitable slot later?)
				NeedsToBeKicked = true;
			}
			else
			{
				NeedsToBeKicked = !Configuration.IsUnitEligible(Unit, iSlot);
			}
		}

		if (NeedsToBeKicked)
		{
			SlotsToEmpty.AddItem(iSlot);
			KickedUnits.AddItem(Unit);
		}
	}
	
	foreach SlotsToEmpty(iSlot)
	{
		XcomHQ.Squad[iSlot].ObjectID = 0;
		HasChanges = true;
	}

	if (Configuration != none)
	{
		// We are in a SSAAT session, so do 2 things. Note that the order is very important

		// (a) Adjust the squad size to match the config
		if (XComHQ.Squad.Length != Configuration.GetNumSlots())
		{
			XComHQ.Squad.Length = Configuration.GetNumSlots();
			HasChanges = true;
		}

		// (b) Attempt to fill in empty slots with kicked units (so that we retain selection if slots were changed places)
		for (iSlot = 0; iSlot < XComHQ.Squad.Length; iSlot++)
		{
			if (XComHQ.Squad[iSlot].ObjectID != 0) continue;
			
			foreach KickedUnits(Unit)
			{
				if (Configuration.IsUnitEligible(Unit, iSlot))
				{
					XcomHQ.Squad[iSlot].ObjectID = Unit.ObjectID;
					KickedUnits.RemoveItem(Unit);
					break; // Stop the subtitution loop for current unit
				}
			}
		}
	}

	if (HasChanges)
	{
		History.AddGameStateToHistory(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}