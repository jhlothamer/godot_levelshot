class_name LevelshotSettings
extends Object

const PROJECT_SETTING_DATA_FOLDER_KEY = "levelshot/settings/data_folder"
const PROJECT_SETTING_DATA_FOLDER_DEFAULT = "res://assets/data"
const PROJECT_SETTING_DATA_FILENAME_PATTERN_KEY = "levelshot/settings/data_filename_pattern"
const PROJECT_SETTING_DATA_FILENAME_PATTERN_DEFAULT = "[PROJECTNAME].levelshot.json"


static func get_data_folder() -> String:
	if !ProjectSettings.has_setting(PROJECT_SETTING_DATA_FOLDER_KEY):
		ProjectSettings.set_setting(PROJECT_SETTING_DATA_FOLDER_KEY, PROJECT_SETTING_DATA_FOLDER_DEFAULT)
	ProjectSettings.set_initial_value(PROJECT_SETTING_DATA_FOLDER_KEY, PROJECT_SETTING_DATA_FOLDER_DEFAULT)
	ProjectSettings.add_property_info(
		{
			"name": PROJECT_SETTING_DATA_FOLDER_KEY,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_DIR
		}
	)

	return ProjectSettings.get_setting(PROJECT_SETTING_DATA_FOLDER_KEY)


static func get_data_file_name_pattern() -> String:
	if !ProjectSettings.has_setting(PROJECT_SETTING_DATA_FILENAME_PATTERN_KEY):
		ProjectSettings.set_setting(PROJECT_SETTING_DATA_FILENAME_PATTERN_KEY, PROJECT_SETTING_DATA_FILENAME_PATTERN_DEFAULT)
	ProjectSettings.set_initial_value(PROJECT_SETTING_DATA_FILENAME_PATTERN_KEY, PROJECT_SETTING_DATA_FILENAME_PATTERN_DEFAULT)
	ProjectSettings.add_property_info(
		{
			"name": PROJECT_SETTING_DATA_FILENAME_PATTERN_KEY,
			"type": TYPE_STRING,
		}
	)

	return ProjectSettings.get_setting(PROJECT_SETTING_DATA_FILENAME_PATTERN_KEY)
