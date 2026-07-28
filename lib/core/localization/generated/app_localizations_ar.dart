// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'جولة';

  @override
  String get tagline => 'العب بذكاء... وكن آخر من يصمد.';

  @override
  String get continueWithGoogle => 'متابعة مع جوجل';

  @override
  String get playAsGuest => 'العب كضيف';

  @override
  String get home => 'الرئيسية';

  @override
  String get ranks => 'التصنيف';

  @override
  String get profile => 'حسابي';

  @override
  String get moreWaysToPlay => 'اكتشف ألعابًا جديدة';

  @override
  String get createRoom => 'أنشئ بطولة';

  @override
  String get joinRoom => 'انضم إلى بطولة';

  @override
  String get punchIn => 'ابدأ المنافسة';

  @override
  String get todaysTournament => 'بطولة اليوم';

  @override
  String get tournamentSlogan => 'تحدَّ · اصمد · انتصر';

  @override
  String numPlayers(Object count) {
    return '$count لاعب';
  }

  @override
  String numRounds(Object count) {
    return '$count جولات';
  }

  @override
  String get tapToFindMatch => 'اضغط للعثور على مباراة';

  @override
  String get milestones => 'الإنجازات';

  @override
  String milestoneUnlockTooltip(Object level) {
    return 'صل إلى المستوى $level لفتحها';
  }

  @override
  String levelShort(Object level) {
    return 'م $level';
  }

  @override
  String get milestoneRookie => 'مبتدئ';

  @override
  String get milestoneContender => 'منافس';

  @override
  String get milestoneRisingStar => 'نجم صاعد';

  @override
  String get milestoneChampion => 'بطل';

  @override
  String get milestoneElite => 'نخبة';

  @override
  String get milestoneLegend => 'أسطورة';
}
