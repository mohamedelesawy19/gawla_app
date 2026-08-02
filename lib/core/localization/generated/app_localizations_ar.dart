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
  String get coins => 'العملات';

  @override
  String get gems => 'الجواهر';

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

  @override
  String playingSince(Object year) {
    return 'يلعب منذ $year';
  }

  @override
  String playerId(Object id) {
    return 'معرّف اللاعب · $id';
  }

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get avatarStyle => 'نمط الصورة الرمزية';

  @override
  String get displayName => 'اسم اللاعب';

  @override
  String get couldNotSaveChanges =>
      'تعذر حفظ التغييرات — يرجى المحاولة مرة أخرى.';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get or_divider => 'أو';

  @override
  String get enterInviteCode => 'أدخل رمز الدعوة';

  @override
  String get quickMatch => 'مباراة سريعة';

  @override
  String get public => 'عامة';

  @override
  String get publicDescription => 'يمكن لأي شخص الانضمام';

  @override
  String get private => 'خاصة';

  @override
  String get privateDescription => 'يتطلب رمز دعوة للانضمام';

  @override
  String get roomVisibility => 'خصوصية الغرفة';

  @override
  String get roomVisibilitySubtitle =>
      'حدد من يمكنه العثور على الغرفة والانضمام إليها';

  @override
  String get miniGameRotation => 'ترتيب الألعاب';

  @override
  String get miniGameRotationSubtitle => 'اختر ترتيب الألعاب التي ستُلعب';

  @override
  String gamesSelected(Object count) {
    return 'تم اختيار $count';
  }

  @override
  String get roomSettings => 'إعدادات الغرفة';

  @override
  String seatsSuffix(Object maxPlayers) {
    return ' / $maxPlayers مكان';
  }

  @override
  String get readyToStart => 'جاهز لبدء البطولة';

  @override
  String get openPlace => 'مكان متاح';

  @override
  String get openPlaceOptional => 'مكان متاح (اختياري)';

  @override
  String moreOpenPlaces(Object count) {
    return '+$count أماكن متاحة';
  }

  @override
  String waitingForMorePlayers(Object remainingPlayers) {
    return 'بانتظار $remainingPlayers لاعبين آخرين';
  }

  @override
  String get you => 'أنت';

  @override
  String get removePlayer => 'إزالة اللاعب';

  @override
  String get inviteCodeCopied => 'تم نسخ رمز الدعوة';
}
