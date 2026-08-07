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
  String get tapToFindTournament => 'Tap to find a tournament';

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

  @override
  String playingSince(Object year) {
    return 'Playing since $year';
  }

  @override
  String playerId(Object id) {
    return 'Player ID · $id';
  }

  @override
  String get editProfile => 'Edit profile';

  @override
  String get avatarStyle => 'Avatar style';

  @override
  String get displayName => 'Display name';

  @override
  String get couldNotSaveChanges =>
      'Couldn\'t save changes — please try again.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get logoutTitle => 'Log out?';

  @override
  String get logoutDescription =>
      'You\'ll need to sign in again to access your account.';

  @override
  String get logout => 'Log out';

  @override
  String get or_divider => 'Or';

  @override
  String get enterInviteCode => 'Enter invite code';

  @override
  String get quickTournament => 'Quick Tournament';

  @override
  String get public => 'Public';

  @override
  String get publicDescription => 'Anyone can find and join';

  @override
  String get private => 'Private';

  @override
  String get privateDescription => 'Invite code required to join';

  @override
  String get roomVisibility => 'Room visibility';

  @override
  String get roomVisibilitySubtitle => 'Who can find and join your lobby';

  @override
  String get miniGameRotation => 'Mini-game rotation';

  @override
  String get miniGameRotationSubtitle =>
      'Tap games in the order you want them played';

  @override
  String gamesSelected(Object count) {
    return '$count selected';
  }

  @override
  String get roomSettings => 'Room settings';

  @override
  String seatsSuffix(Object maxPlayers) {
    return ' / $maxPlayers seats';
  }

  @override
  String get readyToStart => 'Ready to start';

  @override
  String get openPlace => 'Open place';

  @override
  String get openPlaceOptional => 'Open (optional)';

  @override
  String moreOpenPlaces(Object count) {
    return '+$count more open';
  }

  @override
  String waitingForMorePlayers(Object remainingPlayers) {
    return 'Waiting for $remainingPlayers more';
  }

  @override
  String get you => 'You';

  @override
  String get removePlayer => 'Remove player';

  @override
  String get inviteCodeCopied => 'Invite code copied';

  @override
  String get leaveRoomTitle => 'Leave room?';

  @override
  String get leaveRoomDescription =>
      'You\'ll need a new invite or code to rejoin.';

  @override
  String get leave => 'Leave';

  @override
  String get cancel => 'Cancel';

  @override
  String get waitingRoom => 'Waiting Room';

  @override
  String get players => 'Players';

  @override
  String get tournamentStartingGetReady => 'Tournament starting — get ready!';

  @override
  String get startTournament => 'Start Tournament';

  @override
  String get tournamentGetReady => 'Get Ready!';

  @override
  String tournamentRoundLabel(Object current, Object total) {
    return 'Round $current of $total';
  }

  @override
  String tournamentPlayersRemaining(Object count) {
    return '$count players remaining';
  }

  @override
  String get tournamentEliminated => 'Eliminated';

  @override
  String tournamentRankLabel(Object rank) {
    return 'Rank #$rank';
  }

  @override
  String tournamentRoundResultsTitle(Object round) {
    return 'Round $round Results';
  }

  @override
  String get tournamentSpectating => 'You are now spectating';

  @override
  String get tournamentCancelled => 'Tournament Cancelled';

  @override
  String get tournamentVictoryTitle => 'Victory!';

  @override
  String get tournamentEndedTitle => 'Tournament Complete';

  @override
  String get tournamentFinalStandings => 'Final Standings';

  @override
  String get continueLabel => 'Continue';
}
