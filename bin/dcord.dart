// DCORD bot entrypoint.
//
// Author: spunk-developer

import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx/nyxx.dart';

import 'commands/links.dart';
import 'commands/hello.dart';

import 'features/hello.dart';

import 'env.dart';

import 'dart:io';
void main(List<String> args) async {

  // Preload hello feature background images
  preloadHelloImages('${ Directory.current.path }\\assets\\');

  final client = NyxxFactory
    .createNyxxWebsocket(

      env['DISCORD_API_KEY']!,

      GatewayIntents.allUnprivileged
    )
    ..registerPlugin(Logging())
    ..registerPlugin(IgnoreExceptions());

  // We register all interactions (slash commands).
  IInteractions.create(WebsocketInteractionBackend(client))
    // ..registerSlashCommand(command_set_links)
    ..registerSlashCommand(command_set_hello)
    ..registerSlashCommand(command_set_rules)
    ..registerSlashCommand(command_simulate_user_joined)
    ..syncOnReady();

  // @NOTE(spunk-developer): We have to wait for ready event before setting presence,
  //                otherwise it throws a fatal Error.
  client.eventsWs.onReady.listen(
    (_) => client.setPresence(PresenceBuilder.of(activity: ActivityBuilder.watching('https://xnet.cam/')))
  );

  // Register new member join listener
  client.eventsWs.onGuildMemberAdd.listen(handleUserJoin);

  // Connect to the Discord API
  await client.connect();
}
