import 'package:dotenv/dotenv.dart';

import 'dart:io' as io;

/// Environment configuration value.
class Config {

  /**
   * Environment variables.
   *
   * *Private*
   */
  static final _env = DotEnv(includePlatformEnvironment: true)
    ..load(
      [
        './.env'
      ]
    );

  /**
   * Required environment variables.
   *
   * *Private*
   */
  static const List<String> _REQUIRED_ENV_VARS = [ ];

  /// Denotes wether we are in production environment.
  static bool get IS_PROD => _env['DART_ENV'] == 'production';

  /// Denotes wether we are in development environment.
  static bool get IS_DEV => _env['DART_ENV'] != 'production';

  /// Discord API key. Is production key if we're in prod environment, otherwise development.
  static String get API_KEY => !IS_DEV && IS_PROD
    ? _env['PRODUCTION_API_KEY']!
    : _env['DEVELOPMENT_API_KEY']!;

  /// Validates the existence of all required environment variables. If a required variable is missing,
  /// we log the missing variables to console and kill the process.
  static void validateEnv() {

    final List<String> missing_vars = [];

    // We exit the program if we don't find either of the keys.
    if (!_env.isDefined('PRODUCTION_API_KEY') && !_env.isDefined('DEVELOPMENT_API_KEY')) {

      print('Expected PRODUCTION_API_KEY or DEVELOPMENT_API_KEY to be defined, found neither');

      io.exit(1);
    }

    for (final variable in _REQUIRED_ENV_VARS) {

      if (_env.isDefined(variable)) continue;

      missing_vars.add(variable);
    }

    // Kill process if environment variables are not set.
    if (missing_vars.isNotEmpty) {

      print('Missing required environment variables: ${ missing_vars.join(', ') }');

      io.exit(1);
    }
  }
}
