// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Gawla';

  @override
  String get tagline => 'Outplay. Outlast. Win.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get playAsGuest => 'Play as Guest';

  @override
  String get home => 'Home';

  @override
  String get ranks => 'Ranks';

  @override
  String get profile => 'Profile';

  @override
  String get moreWaysToPlay => 'Discover More Games';

  @override
  String get createRoom => 'Create Room';

  @override
  String get joinRoom => 'Join Room';

  @override
  String get punchIn => 'PUNCH IN';

  @override
  String get todaysTournament => 'TODAY\'S TOURNAMENT';

  @override
  String get tournamentSlogan => 'CHALLENGE · SURVIVE · WIN';

  @override
  String numPlayers(Object count) {
    return '$count players';
  }

  @override
  String numRounds(Object count) {
    return '$count rounds';
  }

  @override
  String get tapToFindMatch => 'Tap to find a match';

  @override
  String get coins => 'Coins';

  @override
  String get gems => 'Gems';

  @override
  String get milestones => 'Milestones';

  @override
  String milestoneUnlockTooltip(Object level) {
    return 'Reach level $level to unlock';
  }

  @override
  String levelShort(Object level) {
    return 'Lv $level';
  }

  @override
  String get milestoneRookie => 'Rookie';

  @override
  String get milestoneContender => 'Contender';

  @override
  String get milestoneRisingStar => 'Rising Star';

  @override
  String get milestoneChampion => 'Champion';

  @override
  String get milestoneElite => 'Elite';

  @override
  String get milestoneLegend => 'Legend';
}
