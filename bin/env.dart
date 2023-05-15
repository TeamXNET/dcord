import 'package:dotenv/dotenv.dart';

import 'dart:io';

/**
 * Required environment variables.
 *
 * *Private*
 */
const REQUIRED_ENV_VARS = [
  'DISCORD_API_KEY'
];

/// Environment variables.
final env = DotEnv(includePlatformEnvironment: true)
    ..load(
      [
        './.env'
      ]
    );

/// Validates the existence of all required environment variables.
void validateEnv() => env.isEveryDefined(REQUIRED_ENV_VARS) ? null : exit(1);

