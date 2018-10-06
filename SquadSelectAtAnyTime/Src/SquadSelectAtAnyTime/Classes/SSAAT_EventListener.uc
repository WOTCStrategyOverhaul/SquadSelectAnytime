//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class contains the logic that responds to certain events in case when 
//           the player is in SSAAT
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_EventListener extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreatePreventNarrativeEvents());

	return Templates;
}

// OnSizeLimitedSquadSelect

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