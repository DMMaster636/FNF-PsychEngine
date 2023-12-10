package options;

class ParappaSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Parappa';
		rpcTitle = 'Parappa Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Require Good Rank',
			'If checked, requires you to beat a song with the Good rank.',
			'requireGood',
			'bool');
		addOption(option);

		var option:Option = new Option('Freestyling',
			'If checked, allows you to go into a Freestyle Mode.',
			'freestyling',
			'bool');
		addOption(option);

		var option:Option = new Option('Break Based',
			'If unchecked, Interval Based\n(Break Based is recommended in most cases)',
			'gradingStyle',
			'bool');
		addOption(option);

		var option:Option = new Option('Screen Effects',
			'If checked, screen effects will be applied when reaching BAD or AWFUL.',
			'parappaEffects',
			'bool');
		addOption(option);

		var option:Option = new Option('Health',
			'If checked, enables the use of the health.',
			'useHealth',
			'bool');
		addOption(option);

		// maybe some other time
		/*var option:Option = new Option('Cool Events',
			'If unchecked, any new stuff when reaching Cool gets disabled.',
			'coolEvents',
			'bool');
		addOption(option);*/

		super();
	}
}