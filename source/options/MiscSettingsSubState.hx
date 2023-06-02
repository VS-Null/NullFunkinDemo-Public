package options;

using StringTools;

class MiscSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Misc';
		rpcTitle = 'Misc Settings Menu'; // for Discord Rich Presence

		// I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Show warnings', // Name
			'If unchecked, disables warnings shown in the beginning of the game.', // Description
			'warnings', // Save data variable name
			'bool', // Variable type
			true); // Default value
		addOption(option);

		super();
	}
}
