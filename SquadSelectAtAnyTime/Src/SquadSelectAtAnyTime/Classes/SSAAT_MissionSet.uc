//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class defines the X2MissionTemplate for the fake mission
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_MissionSet extends X2Mission;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2MissionTemplate> Templates;

	Templates.AddItem(CreateFakeMission());

	return Templates;
}

static protected function X2MissionTemplate CreateFakeMission()
{
    local X2MissionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2MissionTemplate', Template, 'SSAAT_FakeMission');
    
	return Template;
}