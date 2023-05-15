// Welcome feature & command handler. Handles the welcome message/ picture feature, which is
// essentially just the built-in Discord server join message, except using a picture.
//
// Author: spunk-developer

import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx/nyxx.dart';

import '../features/hello.dart';

/**
 * Simulate user joined command description.
 *
 * *Private*
 */
const COMMAND_SIMULATE_USER_JOINED_DESCRIPTION = 'Simulates user joined event.';

/**
 * Set welcome messages channel option description.
 *
 * *Private*
 */
const COMMAND_SET_HELLO_OPTION_DESCRIPTION = 'Channel where "hello" messages appear in.';

/**
 * Set rules channel option description.
 *
 * *Private*
 */
const COMMAND_SET_RULES_OPTION_DESCRIPTION = 'Channel where all the server rules appear in.';

/**
 * Simulate user joined command name.
 *
 * *Private*
 */
const COMMAND_SIMULATE_USER_JOINED_NAME = 'simulate_user_joined';

/**
 * Set rules channel command description.
 *
 * *Private*
 */
const COMMAND_SET_RULES_DESCRIPTION = 'Sets the channel where all rules are listed.';

/**
 * Set welcome messages channel command description.
 *
 * *Private*
 */
const COMMAND_SET_HELLO_DESCRIPTION = 'Sets the channel where welcome messages appear.';

/**
 * Set rules channel option name.
 *
 * *Private*
 */
const COMMAND_SET_RULES_OPTION_NAME = 'channel';

/**
 * Set welcome messages channel option name.
 *
 * *Private*
 */
const COMMAND_SET_HELLO_OPTION_NAME = 'channel';

/**
 * Set welcome messages channel command name.
 *
 * *Private*
 */
const COMMAND_SET_HELLO_NAME = 'set_hello_channel';

/**
 * Set rules channel command name.
 *
 * *Private*
 */
const COMMAND_SET_RULES_NAME = 'set_rules_channel';

/**
 * Currently active channel where the welcome.
 *
 * *Private*
 */
ITextGuildChannel? active_channel;

/**
 * Channel where all the rules are displayed.
 *
 * *Private*
 */
IGuildChannel? rules_channel;

/**
 * `set_rules_channel` Command.
 */
final command_set_rules = SlashCommandBuilder(

  COMMAND_SET_RULES_NAME,

  COMMAND_SET_RULES_DESCRIPTION,

  [
    CommandOptionBuilder(

      CommandOptionType.channel,

      COMMAND_SET_RULES_OPTION_NAME,

      COMMAND_SET_RULES_OPTION_DESCRIPTION,

      required: true
    )
  ],

  canBeUsedInDm: false,

  requiredPermissions: PermissionsConstants.administrator
)
  ..registerHandler(

    (event) async {

      for (final option in event.args) {

        rules_channel = event.interaction.guild!.getFromCache()!.channels.firstWhere((element) =>  element.id == option.value);

        event.respond(

          MessageBuilder(content: 'Successfully set <#$rules_channel> as the rules channel.'),

          hidden: true
        );
      }
    }
  );

/**
 * `set_hello_channel` Command.
 */
final command_set_hello = SlashCommandBuilder(

  COMMAND_SET_HELLO_NAME,

  COMMAND_SET_HELLO_DESCRIPTION,

  [
    CommandOptionBuilder(

      CommandOptionType.channel,

      COMMAND_SET_HELLO_OPTION_NAME,

      COMMAND_SET_HELLO_OPTION_DESCRIPTION,

      required: true,

      channelTypes: [
        ChannelType.text
      ]
    )
  ],

  canBeUsedInDm: false,

  requiredPermissions: PermissionsConstants.administrator
)
  ..registerHandler(

    (event) async {

      for (final option in event.args) {

        active_channel = event.interaction.guild!.getFromCache()!.channels.firstWhere((element) =>  element.id == option.value) as ITextGuildChannel;

        event.respond(

          MessageBuilder(content: 'Successfully set <#$active_channel> as the welcome message channel.'),

          hidden: true
        );
      }
    }
  );

/**
 * `simulate_user_joined` Command.
 */
final command_simulate_user_joined = SlashCommandBuilder(

  COMMAND_SIMULATE_USER_JOINED_NAME,

  COMMAND_SIMULATE_USER_JOINED_DESCRIPTION,

  [ ],

  canBeUsedInDm: false,

  requiredPermissions: PermissionsConstants.administrator
)
  ..registerHandler(

    (event) async {

      if (active_channel != null && rules_channel != null) {

        final guild = await event.interaction.guild?.download();

        sendUserJoin(event.interaction.userAuthor!, active_channel!, rules_channel!, (guild?.members.length ?? 0) + 1);

        event.respond(

          MessageBuilder(content: 'Simulated welcome message sent to <#$active_channel>.'),

          hidden: true
        );

        return;
      }

      else {
        event.respond(

          MessageBuilder(content: 'No welcome message channel or rules channel set. Please make sure both channels are set first before executing this command.'),

          hidden: true
        );
      }
    }
  );
