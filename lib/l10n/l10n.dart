import 'package:flutter/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/app_localizations.dart';

export 'package:flutter_instagram_offline_first_clone/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
