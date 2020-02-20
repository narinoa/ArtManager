Global("localization", nil)

Global("Locales", {
	["rus"] = { -- Russian, Win-1251
	["Add new set"] = "�������� ���",
	["Artefact Manager"] = "���� ����������",
	["Grail of Awakening"] = "������ �����������",
	["Pilgrim's Crown"] = "������ ���������",
	["Dragon Aspis"] = "����� �������",
	["Victory Cross"] = "����� ������",
	["Unity Triquetrum"] = "�������� ��������",
	["Codex of Life"] = "������ �����",
	["Freedom Mirror"] = "������� �������",
	},
		
	["eng_eu"] = { -- English, Latin-1

	}
})

--We can now use an official method to get the client language
localization = common.GetLocalization()
function GTL( strTextName )
	return Locales[ localization ][ strTextName ] or Locales[ "eng_eu" ][ strTextName ] or strTextName
end
