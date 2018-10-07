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

	return Templates;
}

// PreventNarrativeEvents

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

// rjSquadSelect

static function CHEventListenerTemplate CreateRoboSquadSelectHooks()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'SSAAT_RoboSquadSelectHooks');
	Template.AddCHEvent('rjSquadSelect_ExtraInfo', AddSquadSelectSlotNotes, ELD_Immediate);
	Template.AddCHEvent('rjSquadSelect_SelectUnitString', ModifySelectUnitString, ELD_Immediate);
	Template.RegisterInStrategy = true;

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
			Tuple.Data[1].s = "Select Scientist";
			break;

		case eUIPersonnel_Engineers:
			Tuple.Data[1].s = "Select Engineer";
			break;
	}

	return ELR_NoInterrupt;
}