// Hello feature implementation.
//
// The hello feature is basically just a fancier version of the welcome message feature
// built in to all Discord servers, except ours has a customized message, along with a
// styled image that is shown.


import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:nyxx/nyxx.dart';
import 'package:http/http.dart';

import 'dart:math';
import 'dart:io';

import '../commands/hello.dart';

/**
 * Factor of which the user image is sized up by.
 *
 * *Private*
 */
const RESIZE_FACTOR = 1.25;

/**
 * Height of each rendered text line.
 *
 * *Private*
 */
const LINE_HEIGHT = 72;

/**
 * Padding between user image & edge, user image & label.
 *
 * *Private*
 */
const PADDING = 128;

/**
 * Background images which get used whenever someone joins the server.
 *
 * *Private*
 */
final List<Image> hello_background_images = [];

/**
 * Font we use when rendering text on the welcome image.
 *
 * *Private*
 */
BitmapFont? poppins_font;

/// Loads all `.png` images from the given [base_path].
Future<void> preloadHelloImages(String base_path) async {

  final files = Directory(base_path)
    .listSync(

      followLinks: false,

      recursive: false
    );

  for (final file in files) {

    if (file is! File) continue;

    if (file.path.endsWith('.png')) {

      final image = decodePng(file.readAsBytesSync());

      if (image != null) hello_background_images.add(image);
      else continue;
    }

    else if (file.path.endsWith('.zip')) {

      poppins_font = BitmapFont.fromZip(file.readAsBytesSync());
    }
  }
}

/// Builds the [Image], returning it in byte form to be displayed with the welcome message.
Uint8List buildJoinImage(Image background_image, Image user_image, int user_number) {

  // Circle user image
  final modified_user_image = copyResize(

    copyCropCircle(user_image),

    height: (user_image.height * RESIZE_FACTOR).round(),

    width: (user_image.width * RESIZE_FACTOR).round()
  );

  // Composited image with background
  final modified_background_image = compositeImage(

    background_image,

    modified_user_image,

    dstX: PADDING,

    dstY: ((background_image.height / 2) - (user_image.height / 2)).round()
  );

  // Compose welcome message onto the image
  final composed_image = drawString(

    modified_background_image,

    'Welcome to the club.\n',

    font: poppins_font!,

    x: (PADDING * 2) + user_image.width,

    y: (background_image.height / 2).round() - (LINE_HEIGHT / 2).round()
  );

  // Draw user number
  final final_image = drawString(

    composed_image,

    'You are member #$user_number.',

    color: ColorUint8.rgb(223, 223, 223),

    font: poppins_font!,

    x: (PADDING * 2) + user_image.width,

    y: (background_image.height / 2).round() + (LINE_HEIGHT / 2).round()
  );

  return encodePng(final_image);
}

/// Handles member join events, automatically sending a new join message in the appropriate channel.
Future<void> handleUserJoin(IGuildMemberAddEvent event) async {

  if (active_channel == null || rules_channel == null) return;

  final guild = await event.guild.download();

  sendUserJoin(event.user, active_channel!, rules_channel!, guild.members.length + 1);
}

/// Sends a new stylized welcome message in the specified channel.
Future<void> sendUserJoin(IUser user, ITextChannel welcome_channel, IGuildChannel rules_channel, int user_number) async {

  final user_image = await get(Uri.parse(user.avatarUrl(size: 512)))..bodyBytes;
  final random     = Random();

  // Send the message.
  welcome_channel.sendMessage(

    MessageBuilder(

      files: [

        AttachmentBuilder.bytes(

          buildJoinImage(

            hello_background_images[random.nextInt(hello_background_images.length)],

            decodeWebP(user_image.bodyBytes)!,

            user_number
          ),

          'welcome-image.png'
        )
      ],

      content: '<@$user> Welcome to the official XNET & XSPUNKS server!\n\nHead over to <#$rules_channel> and read our server rules.'
    )
  );
}
