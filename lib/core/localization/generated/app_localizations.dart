import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Gawla'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Outplay. Outlast. Win.'**
  String get tagline;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @playAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Play as Guest'**
  String get playAsGuest;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @ranks.
  ///
  /// In en, this message translates to:
  /// **'Ranks'**
  String get ranks;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @moreWaysToPlay.
  ///
  /// In en, this message translates to:
  /// **'Discover More Games'**
  String get moreWaysToPlay;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createRoom;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get joinRoom;

  /// No description provided for @punchIn.
  ///
  /// In en, this message translates to:
  /// **'PUNCH IN'**
  String get punchIn;

  /// No description provided for @todaysTournament.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S TOURNAMENT'**
  String get todaysTournament;

  /// No description provided for @tournamentSlogan.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE · SURVIVE · WIN'**
  String get tournamentSlogan;

  /// No description provided for @numPlayers.
  ///
  /// In en, this message translates to:
  /// **'{count} players'**
  String numPlayers(Object count);

  /// No description provided for @numRounds.
  ///
  /// In en, this message translates to:
  /// **'{count} rounds'**
  String numRounds(Object count);

  /// No description provided for @tapToFindTournament.
  ///
  /// In en, this message translates to:
  /// **'Tap to find a tournament'**
  String get tapToFindTournament;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @gems.
  ///
  /// In en, this message translates to:
  /// **'Gems'**
  String get gems;

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestones;

  /// No description provided for @milestoneUnlockTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reach level {level} to unlock'**
  String milestoneUnlockTooltip(Object level);

  /// No description provided for @levelShort.
  ///
  /// In en, this message translates to:
  /// **'Lv {level}'**
  String levelShort(Object level);

  /// No description provided for @milestoneRookie.
  ///
  /// In en, this message translates to:
  /// **'Rookie'**
  String get milestoneRookie;

  /// No description provided for @milestoneContender.
  ///
  /// In en, this message translates to:
  /// **'Contender'**
  String get milestoneContender;

  /// No description provided for @milestoneRisingStar.
  ///
  /// In en, this message translates to:
  /// **'Rising Star'**
  String get milestoneRisingStar;

  /// No description provided for @milestoneChampion.
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get milestoneChampion;

  /// No description provided for @milestoneElite.
  ///
  /// In en, this message translates to:
  /// **'Elite'**
  String get milestoneElite;

  /// No description provided for @milestoneLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get milestoneLegend;

  /// No description provided for @playingSince.
  ///
  /// In en, this message translates to:
  /// **'Playing since {year}'**
  String playingSince(Object year);

  /// No description provided for @playerId.
  ///
  /// In en, this message translates to:
  /// **'Player ID · {id}'**
  String playerId(Object id);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @avatarStyle.
  ///
  /// In en, this message translates to:
  /// **'Avatar style'**
  String get avatarStyle;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @couldNotSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save changes — please try again.'**
  String get couldNotSaveChanges;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutTitle;

  /// No description provided for @logoutDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to access your account.'**
  String get logoutDescription;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @or_divider.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or_divider;

  /// No description provided for @enterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter invite code'**
  String get enterInviteCode;

  /// No description provided for @quickTournament.
  ///
  /// In en, this message translates to:
  /// **'Quick Tournament'**
  String get quickTournament;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @publicDescription.
  ///
  /// In en, this message translates to:
  /// **'Anyone can find and join'**
  String get publicDescription;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @privateDescription.
  ///
  /// In en, this message translates to:
  /// **'Invite code required to join'**
  String get privateDescription;

  /// No description provided for @roomVisibility.
  ///
  /// In en, this message translates to:
  /// **'Room visibility'**
  String get roomVisibility;

  /// No description provided for @roomVisibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who can find and join your lobby'**
  String get roomVisibilitySubtitle;

  /// No description provided for @miniGameRotation.
  ///
  /// In en, this message translates to:
  /// **'Mini-game rotation'**
  String get miniGameRotation;

  /// No description provided for @miniGameRotationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap games in the order you want them played'**
  String get miniGameRotationSubtitle;

  /// No description provided for @gamesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String gamesSelected(Object count);

  /// No description provided for @roomSettings.
  ///
  /// In en, this message translates to:
  /// **'Room settings'**
  String get roomSettings;

  /// No description provided for @seatsSuffix.
  ///
  /// In en, this message translates to:
  /// **' / {maxPlayers} seats'**
  String seatsSuffix(Object maxPlayers);

  /// No description provided for @readyToStart.
  ///
  /// In en, this message translates to:
  /// **'Ready to start'**
  String get readyToStart;

  /// No description provided for @openPlace.
  ///
  /// In en, this message translates to:
  /// **'Open place'**
  String get openPlace;

  /// No description provided for @openPlaceOptional.
  ///
  /// In en, this message translates to:
  /// **'Open (optional)'**
  String get openPlaceOptional;

  /// No description provided for @moreOpenPlaces.
  ///
  /// In en, this message translates to:
  /// **'+{count} more open'**
  String moreOpenPlaces(Object count);

  /// No description provided for @waitingForMorePlayers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {remainingPlayers} more'**
  String waitingForMorePlayers(Object remainingPlayers);

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @removePlayer.
  ///
  /// In en, this message translates to:
  /// **'Remove player'**
  String get removePlayer;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied'**
  String get inviteCodeCopied;

  /// No description provided for @leaveRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave room?'**
  String get leaveRoomTitle;

  /// No description provided for @leaveRoomDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need a new invite or code to rejoin.'**
  String get leaveRoomDescription;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @waitingRoom.
  ///
  /// In en, this message translates to:
  /// **'Waiting Room'**
  String get waitingRoom;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @tournamentStartingGetReady.
  ///
  /// In en, this message translates to:
  /// **'Tournament starting — get ready!'**
  String get tournamentStartingGetReady;

  /// No description provided for @startTournament.
  ///
  /// In en, this message translates to:
  /// **'Start Tournament'**
  String get startTournament;

  /// No description provided for @tournamentGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get Ready!'**
  String get tournamentGetReady;

  /// No description provided for @tournamentRoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Round {current} of {total}'**
  String tournamentRoundLabel(Object current, Object total);

  /// No description provided for @tournamentPlayersRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} players remaining'**
  String tournamentPlayersRemaining(Object count);

  /// No description provided for @tournamentEliminated.
  ///
  /// In en, this message translates to:
  /// **'Eliminated'**
  String get tournamentEliminated;

  /// No description provided for @tournamentRankLabel.
  ///
  /// In en, this message translates to:
  /// **'Rank #{rank}'**
  String tournamentRankLabel(Object rank);

  /// No description provided for @tournamentRoundResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Round {round} Results'**
  String tournamentRoundResultsTitle(Object round);

  /// No description provided for @tournamentSpectating.
  ///
  /// In en, this message translates to:
  /// **'You are now spectating'**
  String get tournamentSpectating;

  /// No description provided for @tournamentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Tournament Cancelled'**
  String get tournamentCancelled;

  /// No description provided for @tournamentVictoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Victory!'**
  String get tournamentVictoryTitle;

  /// No description provided for @tournamentEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Tournament Complete'**
  String get tournamentEndedTitle;

  /// No description provided for @tournamentFinalStandings.
  ///
  /// In en, this message translates to:
  /// **'Final Standings'**
  String get tournamentFinalStandings;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
