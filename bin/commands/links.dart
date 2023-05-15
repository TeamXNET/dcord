// Links channel slash command handler. The "links" channel is a channel with a single embedded message,
// which literally neatly displays all official XNET/ XSPUNKS  project(s) social media links.
//
// Author: spunk-developer

import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx/nyxx.dart';

/**
 * Set links channel command description.
 *
 * *Private*
 */
const COMMAND_SET_OPTION_DESCRIPTION = 'The channnel where the "Official" links embed will appear in.';

/**
 * Set links channel option description.
 *
 * *Private*
 */
const COMMAND_SET_LINK_DESCRIPTION = 'Sets which channel the "Official Links" embed is shown in.';

/**
 * Set links channel command name.
 *
 * *Private*
 */
const COMMAND_SET_LINK_NAME = 'set_links_channel';

/**
 * Set links channel option name.
 *
 * *Private*
 */
const COMMAND_SET_OPTION_NAME = 'channel';

/**
 * Currently active `links` channel.
 *
 * *Private*
 */
ITextChannel? active_channel;

/**
 * Links embed message display instance.
 *
 * *Private*
 */
IMessage? active_message;

/**
 * `set_links_channel` Command.
 */
final command_set_links = SlashCommandBuilder(

  COMMAND_SET_LINK_NAME,

  COMMAND_SET_LINK_DESCRIPTION,

  [
    CommandOptionBuilder(

      CommandOptionType.channel,

      COMMAND_SET_OPTION_NAME,

      COMMAND_SET_OPTION_DESCRIPTION,

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

      final channel = event.interaction.guild!.getFromCache()!.channels.firstWhere((element) =>  element.id == option.value) as ITextGuildChannel;

      if (channel.messageCache.isNotEmpty) {

        event.respond(

          MessageBuilder(content: 'Channel <#$channel> is not an empty channel. Please make sure the target channel has no messages in it!'),

          hidden: true
        );

        return;
      }

      // We delete the active message if it's already defined to prevent multiple copies of the embed
      await active_message?.delete();

      active_message = await channel.sendMessage(

        MessageBuilder(

          embeds: [
            EmbedBuilder(

              color: DiscordColor.fromHexString('591CAE'),

              fields: [
                EmbedFieldBuilder.named(

                  name: 'XSPUNKS collections',

                  content: 'https://sologenic.org/profile/xspunks?network=mainnet'
                ),

                EmbedFieldBuilder.named(

                  name: 'XSPUNKS Website',

                  content: 'https://www.xspunk.xyz/'
                ),

                EmbedFieldBuilder.named(

                  name: 'XNET Website',

                  content: 'https://xnet.cam/'
                ),

                EmbedFieldBuilder.named(

                  name: 'Twitter',

                  content: 'https://twitter.com/xspunksxrpl'
                ),

                EmbedFieldBuilder.named(

                  name: 'Discord',

                  content: 'https://discord.gg/uhr2XT8dGu'
                ),

                EmbedFieldBuilder.named(

                  name: 'Instagram',

                  content: 'https://www.instagram.com/xspunks/'
                ),

                EmbedFieldBuilder.named(

                  name: 'Telegram',

                  content: 'https://t.me/+SsFw4oqH93c0YTI0'
                )
              ],

              footer: EmbedFooterBuilder(

                iconUrl: 'https://placehold.co/8',

                text: 'Team XNET'
              ),

              imageUrl: 'https://placehold.co/512x196',

              title: 'XNET & XSPUNKS Official Links'
            )
          ]
        )
      );

      active_channel = channel;

      event.respond(

        MessageBuilder(content: 'Successfully set <#$active_channel> as the XNET & XSPUNKS links channel.'),

        hidden: true
      );
    }
  }
);
