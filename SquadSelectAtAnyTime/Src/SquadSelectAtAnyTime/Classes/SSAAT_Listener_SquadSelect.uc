class SSAAT_Listener_SquadSelect extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UISquadSelect SquadSelect;
	local SSAAT_ElementRemover Remover;
	local SSAAT_DummyMissionRemover MissionRemover;

	SquadSelect = UISquadSelect(Screen);
	if (SquadSelect == none) return;

	if (SquadSelect.GetMissionState().Source != 'SSAAT_MissionSource_FakeMission') {
		return;
	}

	Remover = SquadSelect.Spawn(class'SSAAT_ElementRemover', SquadSelect);
	Remover.InitRemover();

	MissionRemover = SquadSelect.Spawn(class'SSAAT_DummyMissionRemover', SquadSelect);
	MissionRemover.MissionObjectId = `XCOMHQ.MissionRef.ObjectID;
	MissionRemover.InitPanel();
}