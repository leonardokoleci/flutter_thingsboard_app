import 'package:thingsboard_app/modules/main/model/navigation_type.dart';

abstract final class ThingsboardAppConstants {
  /// Hardcoded server host – change this to your Thingsboard instance.
  static const thingsBoardApiEndpoint = 'https://demo.thingsboard.io';

  static const thingsboardOAuth2CallbackUrlScheme = String.fromEnvironment(
    'thingsboardOAuth2CallbackUrlScheme',
  );
  static const thingsboardIOSAppSecret = String.fromEnvironment(
    'thingsboardIosAppSecret',
  );
  static const thingsboardAndroidAppSecret = String.fromEnvironment(
    'thingsboardAndroidAppSecret',
  );
  // Always treat the hardcoded endpoint as the "default" so Firebase works.
  static const ignoreRegionSelection = true;
  static final navigationType = TbNavigationType.fromString(
    const String.fromEnvironment('navigationType'),
  );
}
