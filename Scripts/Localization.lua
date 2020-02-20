Global("localization", nil)

Global("Locales", {
	["rus"] = { -- Russian, Win-1251
	["Add new set"] = "Добавить сет",
	["Artefact Manager"] = "Сеты артефактов",
	["Grail of Awakening"] = "Грааль Пробуждения",
	["Pilgrim's Crown"] = "Корона Скитальца",
	["Dragon Aspis"] = "Аспис Дракона",
	["Victory Cross"] = "Крест Победы",
	["Unity Triquetrum"] = "Трикветр Единства",
	["Codex of Life"] = "Кодекс Бытия",
	["Freedom Mirror"] = "Зерцало Свободы",
	},
		
	["eng_eu"] = { -- English, Latin-1

	}
})

--We can now use an official method to get the client language
localization = common.GetLocalization()
function GTL( strTextName )
	return Locales[ localization ][ strTextName ] or Locales[ "eng_eu" ][ strTextName ] or strTextName
end
