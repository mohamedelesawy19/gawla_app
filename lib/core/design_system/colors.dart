import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// GAWLA — GAME COLOR SYSTEM
/// ═══════════════════════════════════════════════════════════════════════
///
/// The single source of truth for every color used across the game.
///
/// This is NOT a Material Design ColorScheme. Gawla is a fast, competitive,
/// real-time party-tournament game (think Stumble Guys / Brawl Stars /
/// Fall Guys energy) — the palette is built around *gameplay states*
/// (alive, eliminated, countdown, victory, rank...) rather than generic
/// UI roles (primary/secondary/surface).
///
/// Visual language:
/// - A near-black violet "night arena" backdrop makes every mini-game,
///   card, and piece of UI pop like a spotlighted stage.
/// - Electric violet is the brand's home base; hot magenta is the jolt
///   of energy for calls-to-action, live tags, and hype moments.
///   Cyan reads as "live / online / active"; gold always means
///   "reward, rank #1, or premium".
/// - Status and gameplay colors (timer, elimination, rank) are kept
///   perceptually distinct from each other so a player can read game
///   state at a glance, mid-match, without reading text.
///
/// Organization: colors are grouped by *where and why* they're used,
/// not by hue. Each constant documents intent, not appearance — never
/// name or describe a color by what it looks like.
/// ═══════════════════════════════════════════════════════════════════════
class AppColors {
  const AppColors._();

  // ═════════════════════════════════════════════════════════════════════
  // BRAND
  // Gawla's core identity colors. These anchor the entire visual system —
  // logo, splash screen, primary CTAs, and any moment the game needs to
  // say "this is Gawla" rather than "this is a generic control."
  // ═════════════════════════════════════════════════════════════════════

  /// The game's signature color. Used for the logo, primary buttons,
  /// the main CTA on the home screen ("Play"), and selected navigation
  /// tabs. This is the color a player should associate with Gawla itself.
  static const Color brandPrimary = Color(0xFF7C3AED);

  /// A lighter tint of the brand color. Used for glows, focus rings on
  /// brand-colored elements, and selected-state borders where the full
  /// saturation of [brandPrimary] would be too heavy (e.g. a card outline).
  static const Color brandPrimaryLight = Color(0xFFA78BFA);

  /// A deeper shade of the brand color. Used for pressed/active button
  /// states and for text or icons placed on top of light brand surfaces
  /// where extra contrast is needed.
  static const Color brandPrimaryDark = Color(0xFF5B21B6);

  /// The game's secondary "jolt" color — used sparingly for high-energy
  /// moments that need to grab attention: the "LIVE" tag on an active
  /// tournament, urgent CTAs, hype banners, and celebratory accents.
  /// Because it's so saturated, this is a spice, not a base — never use
  /// it as a large background fill.
  static const Color brandSecondary = Color(0xFFFF2E8A);

  /// A softened tint of [brandSecondary]. Used for secondary hype
  /// elements that sit near or behind text (chips, small badges) where
  /// the full-strength color would hurt legibility.
  static const Color brandSecondaryLight = Color(0xFFFF6BAE);

  /// Gawla's "premium / reward" color. Anything a player earns and is
  /// proud of — currency, trophies, the host's crown, 1st place — uses
  /// this gold. Reserve it for things that are actually valuable; if
  /// everything is gold, nothing feels special.
  static const Color brandAccentGold = Color(0xFFFFB627);

  /// Gawla's "alive / online / active" color. Used wherever something
  /// is currently happening in real time: live player counts, active
  /// timers, matchmaking search state, and connection indicators.
  static const Color brandAccentCyan = Color(0xFF22E8D8);

  /// A warm, energetic blaze accent used for progression-driven moments:
  /// level-ups, XP streaks, milestone celebrations, and "on fire" effects.
  /// Unlike [brandAccentGold], which represents prestige and rewards,
  /// Blaze communicates momentum, growth, and excitement.
  static const Color brandAccentBlazeStart = Color(0xFFFF3D7F);

  /// End color of the Blaze accent gradient. Pair with
  /// [brandAccentBlazeStart] to create the signature progression glow.
  static const Color brandAccentBlazeEnd = Color(0xFFFF9F43);

  /// Signature gradient used for progression-focused UI such as XP,
  /// milestone highlights, streaks, and level-up celebrations.
  static const LinearGradient brandAccentBlazeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandAccentBlazeStart, brandAccentBlazeEnd],
  );

  // ═════════════════════════════════════════════════════════════════════
  // BACKGROUNDS
  // The "night arena" backdrop the whole game sits on. Deliberately dark
  // and desaturated so mini-game content, cards, and reward colors read
  // as bright and exciting by contrast — like a stage under spotlights.
  // ═════════════════════════════════════════════════════════════════════

  /// The default background for full screens: Home, Room, Tournament
  /// flow, Settings, Profile. The "floor" every other surface sits on.
  static const Color backgroundPrimary = Color(0xFF130A24);

  /// A slightly lifted background used for secondary screens or large
  /// sub-sections within a primary screen (e.g. a tab's content area)
  /// where a subtle separation from [backgroundPrimary] helps hierarchy.
  static const Color backgroundSecondary = Color(0xFF1C1033);

  /// A further-lifted background used behind grouped content blocks,
  /// such as a settings section or a rewards summary panel.
  static const Color backgroundTertiary = Color(0xFF261645);

  /// The darkest background in the system, reserved for the mini-game
  /// play surface itself. Going darker than every other screen makes
  /// gameplay content (which is often colorful) the clear visual focus
  /// the instant a round starts.
  static const Color backgroundArena = Color(0xFF0D0619);

  /// Top stop of the ambient gradient used behind hero moments — the
  /// waiting room, the tournament bracket screen, the winner reveal.
  /// Pair with [backgroundGradientBottom].
  static const Color backgroundGradientTop = Color(0xFF2A1458);

  /// Bottom stop of the ambient hero gradient. Pair with
  /// [backgroundGradientTop].
  static const Color backgroundGradientBottom = Color(0xFF0D0619);

  // ═════════════════════════════════════════════════════════════════════
  // SURFACES
  // Non-card container surfaces: panels, sheets, bars, and any block
  // that groups content but isn't a tappable "card."
  // ═════════════════════════════════════════════════════════════════════

  /// Default surface for panels, bottom sheets, app bars, and tab bars.
  /// One step brighter than [backgroundPrimary] so containers read as
  /// clearly separate from the screen behind them.
  static const Color surfaceDefault = Color(0xFF1F1238);

  /// A raised surface used for panels that should feel "on top of"
  /// default surfaces — dialogs, popovers, dropdown menus, toasts.
  static const Color surfaceElevated = Color(0xFF2C1B4D);

  /// A recessed surface used for input fields, search bars, and any
  /// container that should read as "carved into" the screen rather
  /// than sitting on top of it.
  static const Color surfaceSunken = Color(0xFF150B29);

  // ═════════════════════════════════════════════════════════════════════
  // CARDS
  // Tappable card surfaces: mini-game tiles, reward cards, room list
  // items, cosmetic items. Distinct from generic surfaces because cards
  // carry interactive states (selected, locked, disabled).
  // ═════════════════════════════════════════════════════════════════════

  /// Default background for any tappable card: mini-game selector tiles,
  /// room list entries, shop items, achievement tiles.
  static const Color cardDefault = Color(0xFF231640);

  /// Background shown while a card is being pressed or hovered (desktop/
  /// web builds), giving immediate tactile feedback before the tap
  /// action resolves.
  static const Color cardHover = Color(0xFF2E1D52);

  /// Background for a card the player has actively selected — a chosen
  /// avatar, a picked mini-game in room settings, a highlighted reward
  /// tier. Pair with [borderSelected] for a full selected treatment.
  static const Color cardSelected = Color(0xFF3A2564);

  /// Background for a card representing content the player hasn't
  /// unlocked yet — a locked cosmetic, an un-reached leaderboard tier,
  /// a future mini-game. Deliberately closer to the background color so
  /// locked content visually recedes.
  static const Color cardLocked = Color(0xFF1A1130);

  /// Background for a card that cannot currently be interacted with
  /// (e.g. a mini-game unavailable in the current room mode). Distinct
  /// from [cardLocked] — this is a temporary state, not a progression
  /// gate.
  static const Color cardDisabled = Color(0xFF17102A);

  // ═════════════════════════════════════════════════════════════════════
  // TEXT
  // ═════════════════════════════════════════════════════════════════════

  /// Primary reading text: headlines, player names, main body copy.
  /// The highest-contrast text color in the system.
  static const Color textPrimary = Color(0xFFF5F3FF);

  /// Secondary text: descriptions, sub-labels, helper copy beneath a
  /// headline, timestamps on important content.
  static const Color textSecondary = Color(0xFFB8ADD6);

  /// Muted/tertiary text: least-important metadata — fine print, disabled
  /// hints, placeholder copy in empty states.
  static const Color textTertiary = Color(0xFF7C6FA0);

  /// Text on a disabled control (a locked button label, a greyed-out
  /// menu item). Kept legible but unmistakably inactive.
  static const Color textDisabled = Color(0xFF4A4066);

  /// Text placed on top of a saturated brand-colored surface (a filled
  /// primary button, a brand-colored banner). Always paired with
  /// [brandPrimary], [brandSecondary], or [brandAccentGold] backgrounds.
  static const Color textOnBrand = Color(0xFFFFFFFF);

  /// Dark text used on light/gold surfaces where white text would fail
  /// contrast — e.g. copy printed directly on a gold reward banner.
  static const Color textInverse = Color(0xFF130A24);

  // ═════════════════════════════════════════════════════════════════════
  // BORDERS
  // ═════════════════════════════════════════════════════════════════════

  /// Default hairline border for cards, inputs, and dividers between
  /// grouped content.
  static const Color borderDefault = Color(0xFF3A2A5C);

  /// A quieter border used where a division is needed but shouldn't
  /// draw the eye — e.g. separating rows in a long list.
  static const Color borderSubtle = Color(0xFF241639);

  /// Border shown around a control that currently has keyboard/controller
  /// focus (important for TV-mode or gamepad play). Uses the "active"
  /// brand cyan so focus is unmistakable against the dark UI.
  static const Color borderFocused = Color(0xFF22E8D8);

  /// Border shown around a selected card or option — chosen avatar,
  /// chosen room setting, picked answer before submission.
  static const Color borderSelected = Color(0xFFA78BFA);

  /// Border used on inputs or cards in an error state — an invalid
  /// invite code field, a room name that failed validation.
  static const Color borderError = Color(0xFFFF4D6A);

  // ═════════════════════════════════════════════════════════════════════
  // ICONS
  // ═════════════════════════════════════════════════════════════════════

  /// Default icon color for standard, non-active iconography — nav bar
  /// icons, list item glyphs, informational icons.
  static const Color iconDefault = Color(0xFFCFC4E8);

  /// Icon color for the active/selected state — the currently selected
  /// tab's icon, a toggled-on setting.
  static const Color iconActive = Color(0xFFFFFFFF);

  /// Icon color for muted, low-emphasis iconography — disabled actions,
  /// decorative icons that shouldn't compete with content.
  static const Color iconMuted = Color(0xFF6B5E8F);

  /// Icon color for icons placed on a brand-colored surface (inside a
  /// filled primary button, on a gold reward banner).
  static const Color iconOnBrand = Color(0xFFFFFFFF);

  // ═════════════════════════════════════════════════════════════════════
  // BUTTONS
  // Every button role gets a default and pressed state so touch feedback
  // is consistent everywhere in the app, plus one shared disabled color
  // per family.
  // ═════════════════════════════════════════════════════════════════════

  /// Fill for the primary CTA button — "Play", "Create Room", "Join
  /// Tournament". There should generally be one primary button per screen.
  static const Color buttonPrimaryDefault = Color(0xFF7C3AED);

  /// Fill shown while the primary button is being pressed, giving
  /// immediate tactile confirmation of the tap.
  static const Color buttonPrimaryPressed = Color(0xFF6524D9);

  /// Fill for a primary button that's temporarily unavailable — e.g.
  /// "Start Tournament" before the minimum player count is met.
  static const Color buttonPrimaryDisabled = Color(0xFF3A2E5C);

  /// Fill for secondary actions that shouldn't compete with the primary
  /// CTA — "Cancel", "Back", "Invite Friends" alongside "Play".
  static const Color buttonSecondaryDefault = Color(0xFF2C1B4D);

  /// Pressed fill for secondary buttons.
  static const Color buttonSecondaryPressed = Color(0xFF3A2564);

  /// Fill for destructive/high-stakes actions — "Leave Room", "Forfeit
  /// Match", "Delete Account".
  static const Color buttonDangerDefault = Color(0xFFFF4D6A);

  /// Pressed fill for destructive buttons.
  static const Color buttonDangerPressed = Color(0xFFE0324E);

  /// Fill for confirming/positive actions distinct from the brand CTA —
  /// "Confirm Ready", "Accept Invite".
  static const Color buttonSuccessDefault = Color(0xFF3DDC84);

  /// Pressed fill for success/confirm buttons.
  static const Color buttonSuccessPressed = Color(0xFF2BB86B);

  // ═════════════════════════════════════════════════════════════════════
  // INTERACTIVE STATES
  // Overlay tints applied on top of any element (not just buttons) to
  // communicate touch feedback, focus, and disabled-ness uniformly.
  // ═════════════════════════════════════════════════════════════════════

  /// Light overlay applied on hover (web/desktop builds) over any
  /// tappable element that doesn't have a dedicated hover color.
  static const Color overlayHover = Color(0x14FFFFFF);

  /// Dark overlay applied while any tappable element is being pressed,
  /// used as a universal fallback for elements without a dedicated
  /// pressed color.
  static const Color overlayPressed = Color(0x33000000);

  /// Overlay used to dim any control into its disabled state, applied
  /// over the control's normal background rather than replacing it —
  /// keeps disabled controls recognizable instead of looking "removed."
  static const Color overlayDisabled = Color(0x66000000);

  /// Ripple color for tap feedback on brand-colored (filled) buttons.
  static const Color rippleOnBrand = Color(0x33FFFFFF);

  // ═════════════════════════════════════════════════════════════════════
  // STATUS COLORS
  // Generic, app-wide meaning — form validation, toasts, connection
  // state. Gameplay-specific meanings live in their own sections below
  // even when they reuse a similar hue, so gameplay styling can evolve
  // independently of generic UI styling.
  // ═════════════════════════════════════════════════════════════════════

  /// Generic success feedback — "Room created", "Settings saved",
  /// "Friend request accepted".
  static const Color statusSuccess = Color(0xFF3DDC84);

  /// Generic warning feedback — "Weak connection", "Room almost full".
  static const Color statusWarning = Color(0xFFFFC94D);

  /// Generic error feedback — "Invalid invite code", "Failed to join
  /// room", form validation errors.
  static const Color statusError = Color(0xFFFF4D6A);

  /// Generic informational feedback — "New season starts in 3 days",
  /// neutral toasts and tips.
  static const Color statusInfo = Color(0xFF4DA6FF);

  // ═════════════════════════════════════════════════════════════════════
  // TOURNAMENT
  // The bracket/flow screens: Room → Waiting Room → rounds → Final →
  // Winner. Colors here communicate "where are we in the tournament"
  // at a glance.
  // ═════════════════════════════════════════════════════════════════════

  /// Tag color for a tournament that is currently in progress —
  /// the pulsing "LIVE" badge on a spectatable or rejoinable match.
  static const Color tournamentLive = Color(0xFFFF2E8A);

  /// Tag color for a tournament that hasn't started yet — shown on
  /// scheduled/upcoming tournament cards.
  static const Color tournamentUpcoming = Color(0xFF4DA6FF);

  /// Tag/text color for a tournament that has already ended, used in
  /// history lists and past-results screens.
  static const Color tournamentCompleted = Color(0xFF6B5E8F);

  /// Fill for the round indicator (e.g. a bracket-progress dot or pip)
  /// representing the round currently being played.
  static const Color roundIndicatorActive = Color(0xFF22E8D8);

  /// Fill for a round indicator representing a round the player has
  /// already survived.
  static const Color roundIndicatorComplete = Color(0xFF3DDC84);

  /// Fill for a round indicator representing a round that hasn't
  /// happened yet.
  static const Color roundIndicatorUpcoming = Color(0xFF3A2A5C);

  /// Default color for bracket connector lines linking rounds together
  /// on the tournament overview screen.
  static const Color bracketLineDefault = Color(0xFF3A2A5C);

  /// Color for the bracket connector line tracing the current player's
  /// (or a spectated player's) path through the tournament.
  static const Color bracketLineActive = Color(0xFF22E8D8);

  // ═════════════════════════════════════════════════════════════════════
  // REWARDS & RARITY
  // Currency and item-rarity colors. Rarity tiers are the backbone every
  // future cosmetic, chest, and battle-pass reward will hang off of —
  // adding "Mythic" later is a one-line addition to this section.
  // ═════════════════════════════════════════════════════════════════════

  /// Rarity color for the most common item tier — starter cosmetics,
  /// base avatar frames.
  static const Color rarityCommon = Color(0xFF9CA3AF);

  /// Rarity color for uncommon-but-not-special items.
  static const Color rarityRare = Color(0xFF4DA6FF);

  /// Rarity color for high-value items — standout emotes, distinctive
  /// avatar frames.
  static const Color rarityEpic = Color(0xFFB24DFF);

  /// Rarity color for the rarest, most prestigious items — season-
  /// exclusive cosmetics, top battle-pass rewards. Shares gold with
  /// [brandAccentGold] intentionally: legendary items should feel as
  /// valuable as the game's core reward currency.
  static const Color rarityLegendary = Color(0xFFFFB627);

  /// Color used for the soft coin (primary currency) icon and any coin
  /// amount displayed in the UI.
  static const Color currencyCoin = Color(0xFFFFB627);

  /// Color used for the gem (premium currency) icon and gem amounts.
  /// Kept visually distinct from coins so players never confuse the
  /// two currencies at a glance.
  static const Color currencyGem = Color(0xFF4DE8FF);

  /// Color used for XP amounts and XP-related iconography, distinct
  /// from both currencies since XP can't be spent — only earned.
  static const Color currencyXP = Color(0xFF9BE15D);

  // ═════════════════════════════════════════════════════════════════════
  // GAME STATES
  // The lifecycle of a single mini-game round: Waiting → Countdown →
  // In Progress → Paused → Results → Ended. Used to color state chips,
  // banners, and any UI that needs to reflect "what's happening right
  // now" in the current mini-game.
  // ═════════════════════════════════════════════════════════════════════

  /// Waiting for the round to be ready to start (e.g. loading assets,
  /// waiting for all clients to ack).
  static const Color gameStateWaiting = Color(0xFF6B5E8F);

  /// The pre-round countdown is running ("3... 2... 1...").
  static const Color gameStateCountdown = Color(0xFFFFC94D);

  /// The round is actively being played.
  static const Color gameStateInProgress = Color(0xFF22E8D8);

  /// The round is paused (e.g. a host pause, or a reconnect grace
  /// period for a dropped player).
  static const Color gameStatePaused = Color(0xFF4DA6FF);

  /// The round has ended and results/scores are being revealed.
  static const Color gameStateResults = Color(0xFFB24DFF);

  /// The round is fully closed out and the tournament is moving on.
  static const Color gameStateEnded = Color(0xFF6B5E8F);

  // ═════════════════════════════════════════════════════════════════════
  // MATCHMAKING
  // Room creation, joining, and the search-for-match flow.
  // ═════════════════════════════════════════════════════════════════════

  /// Color for the pulsing "searching for players..." indicator while
  /// matchmaking is in progress.
  static const Color matchmakingSearching = Color(0xFF22E8D8);

  /// Color shown briefly when a match/room has been found, just before
  /// transitioning into the waiting room.
  static const Color matchmakingFound = Color(0xFF3DDC84);

  /// Color for a matchmaking failure state — no rooms available,
  /// connection timeout — shown with a retry action.
  static const Color matchmakingFailed = Color(0xFFFF4D6A);

  /// Badge color marking a room as Public (open to anyone) in room
  /// lists and room settings.
  static const Color roomPublicBadge = Color(0xFF4DA6FF);

  /// Badge color marking a room as Private (invite-code only) in room
  /// lists and room settings.
  static const Color roomPrivateBadge = Color(0xFFB24DFF);

  // ═════════════════════════════════════════════════════════════════════
  // TIMER & COUNTDOWN
  // Every mini-game runs on a strict clock (30–90s rounds). These colors
  // let a player feel time pressure without reading a number.
  // ═════════════════════════════════════════════════════════════════════

  /// Timer color while plenty of time remains — the calm, default state.
  static const Color timerSafe = Color(0xFF3DDC84);

  /// Timer color once time is getting short, prompting the player to
  /// hurry without yet being alarming.
  static const Color timerWarning = Color(0xFFFFC94D);

  /// Timer color in the final seconds — paired with a pulse/scale
  /// animation in the UI layer to maximize urgency.
  static const Color timerCritical = Color(0xFFFF4D6A);

  /// Color of the large numeral in the pre-round "3... 2... 1..." countdown.
  static const Color countdownNumberColor = Color(0xFFFFFFFF);

  /// Glow/accent color rendered behind or around the countdown numeral
  /// to give it energy on the arena background.
  static const Color countdownGlow = Color(0xFF22E8D8);

  // ═════════════════════════════════════════════════════════════════════
  // PLAYER STATUS
  // Per-player state shown on avatars, lobby lists, and in-game HUDs —
  // must be readable at a glance across up to dozens of players at once.
  // ═════════════════════════════════════════════════════════════════════

  /// Indicator color for a player who is still active/alive in the
  /// current tournament.
  static const Color playerAlive = Color(0xFF3DDC84);

  /// Indicator color for a player who has been eliminated. Deliberately
  /// desaturated so eliminated players visually recede from the pack.
  static const Color playerEliminated = Color(0xFF4A4066);

  /// Indicator color for a player who is now spectating after
  /// elimination, distinct from simply "eliminated" since they're
  /// still present and watching.
  static const Color playerSpectating = Color(0xFF6B5E8F);

  /// Color for the host's crown icon/badge in the waiting room and
  /// in-match player lists.
  static const Color playerHost = Color(0xFFFFB627);

  /// Indicator color for a player who has marked themselves ready in
  /// the waiting room.
  static const Color playerReady = Color(0xFF3DDC84);

  /// Indicator color for a player who has not yet marked themselves
  /// ready.
  static const Color playerNotReady = Color(0xFFFFC94D);

  /// Indicator color for a player who has lost connection mid-match,
  /// shown while their reconnect grace period is active.
  static const Color playerDisconnected = Color(0xFFFF4D6A);

  /// Highlight color used to mark the local player's own avatar/row in
  /// any list containing multiple players, so they can always find
  /// themselves instantly.
  static const Color playerYouHighlight = Color(0xFF22E8D8);

  // ═════════════════════════════════════════════════════════════════════
  // ELIMINATION
  // The moment a player is cut from the tournament — a high-emotion
  // beat that deserves its own dedicated, punchy colors.
  // ═════════════════════════════════════════════════════════════════════

  /// Full-screen flash color shown for a single frame the instant the
  /// local player is eliminated. Intended to be animated from full
  /// opacity down to zero, not used as a static fill.
  static const Color eliminationFlash = Color(0xFFFF2E4D);

  /// Scrim placed over the arena behind the "You've been eliminated"
  /// card so the message stays readable over frozen gameplay content.
  static const Color eliminationOverlayScrim = Color(0xCC0D0619);

  /// Background for the elimination result badge/card shown after a
  /// round (e.g. "Eliminated — Rank 14").
  static const Color eliminationBadgeBackground = Color(0xFF1A1130);

  /// Text color for the rank number shown on the elimination card.
  static const Color eliminationRankText = Color(0xFFFF4D6A);

  // ═════════════════════════════════════════════════════════════════════
  // LEADERBOARD & RANK
  // Weekly/season leaderboard and any end-of-match ranking list.
  // ═════════════════════════════════════════════════════════════════════

  /// Color for 1st place — rank number, medal icon, and row accent.
  static const Color rankFirst = Color(0xFFFFD447);

  /// Color for 2nd place.
  static const Color rankSecond = Color(0xFFC0C6D9);

  /// Color for 3rd place.
  static const Color rankThird = Color(0xFFCD8A5C);

  /// Default rank number color for every position outside the top 3.
  static const Color rankDefault = Color(0xFF7C6FA0);

  /// Row background used to highlight the local player's own entry in
  /// a leaderboard or results list, so they can find their standing
  /// without scanning names.
  static const Color leaderboardRowSelf = Color(0xFF3A2564);

  /// Alternate row background for zebra-striping long leaderboard lists,
  /// improving scannability.
  static const Color leaderboardRowAlt = Color(0xFF1C1033);

  /// Default row background for leaderboard/results list entries.
  static const Color leaderboardRowDefault = Color(0xFF1F1238);

  // ═════════════════════════════════════════════════════════════════════
  // AVATAR PLACEHOLDERS
  // Deterministic background colors for players without a custom
  // avatar image, so every player in a room stays visually distinct
  // from teammates and opponents at a glance.
  // ═════════════════════════════════════════════════════════════════════

  /// A fixed palette of visually distinct colors for default avatar
  /// backgrounds. Assign deterministically (e.g. by hashing the
  /// player's uid) so a given player's placeholder color stays stable
  /// across sessions.
  static const List<Color> avatarPalette = <Color>[
    Color(0xFFFF6B6B),
    Color(0xFFFFB627),
    Color(0xFF9BE15D),
    Color(0xFF22E8D8),
    Color(0xFF4DA6FF),
    Color(0xFFB24DFF),
    Color(0xFFFF2E8A),
    Color(0xFFFFD447),
  ];

  // ═════════════════════════════════════════════════════════════════════
  // CHAT
  // Lobby/waiting-room text chat and system messages.
  // ═════════════════════════════════════════════════════════════════════

  /// Bubble background for messages sent by the local player.
  static const Color chatBubbleSelf = Color(0xFF7C3AED);

  /// Bubble background for messages sent by other players.
  static const Color chatBubbleOther = Color(0xFF2C1B4D);

  /// Bubble background for system messages ("Player_42 joined the room").
  static const Color chatBubbleSystem = Color(0xFF1A1130);

  /// Text color for the local player's own chat bubbles.
  static const Color chatTextSelf = Color(0xFFFFFFFF);

  /// Text color for other players' chat bubbles.
  static const Color chatTextOther = Color(0xFFF5F3FF);

  /// Color for chat message timestamps, kept low-emphasis so they don't
  /// compete with message content.
  static const Color chatTimestamp = Color(0xFF6B5E8F);

  // ═════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS & BADGES
  // ═════════════════════════════════════════════════════════════════════

  /// Small dot indicating unread/unseen content — new chat messages,
  /// unclaimed rewards, unread announcements.
  static const Color notificationDot = Color(0xFFFF4D6A);

  /// Background for a notification/toast panel.
  static const Color notificationBackground = Color(0xFF2C1B4D);

  /// Background for a "NEW" badge marking recently-added content — a
  /// new mini-game, a new cosmetic, a new season.
  static const Color badgeNew = Color(0xFF22E8D8);

  /// Background for a numeric count badge (e.g. unread chat count,
  /// pending friend requests).
  static const Color badgeCountBackground = Color(0xFFFF2E8A);

  /// Text color for the number inside a count badge.
  static const Color badgeCountText = Color(0xFFFFFFFF);

  // ═════════════════════════════════════════════════════════════════════
  // PROGRESS
  // Generic progress bars plus the specific XP and battle-pass tracks
  // referenced in the game's long-tail retention systems.
  // ═════════════════════════════════════════════════════════════════════

  /// Background track for any generic progress bar (loading, download,
  /// step-completion indicators).
  static const Color progressTrackBackground = Color(0xFF241639);

  /// Fill color for a generic in-progress progress bar.
  static const Color progressFillDefault = Color(0xFF7C3AED);

  /// Fill color for a progress bar that has reached 100%.
  static const Color progressFillComplete = Color(0xFF3DDC84);

  /// Fill color specifically for the player XP bar (profile, level-up
  /// screens), kept distinct from generic progress so XP always reads
  /// as its own currency-like thing.
  static const Color xpBarFill = Color(0xFF9BE15D);

  /// Background track behind the XP bar fill.
  static const Color xpBarBackground = Color(0xFF241639);

  /// Fill color for the free track of a seasonal battle pass.
  static const Color battlePassFillFree = Color(0xFF4DA6FF);

  /// Fill color for the premium track of a seasonal battle pass, using
  /// the reward-gold color so premium rewards read as more valuable.
  static const Color battlePassFillPremium = Color(0xFFFFB627);

  // ═════════════════════════════════════════════════════════════════════
  // LOADING
  // ═════════════════════════════════════════════════════════════════════

  /// Color of spinner/progress-ring loading indicators throughout the app.
  static const Color loadingIndicator = Color(0xFF22E8D8);

  /// Semi-transparent scrim shown behind a full-screen loading state
  /// (e.g. while a match is being prepared).
  static const Color loadingScrim = Color(0xB3130A24);

  /// Base fill color for skeleton-loading placeholder blocks.
  static const Color skeletonBase = Color(0xFF1F1238);

  /// Highlight color swept across skeleton placeholders to create the
  /// shimmer animation.
  static const Color skeletonHighlight = Color(0xFF2C1B4D);

  // ═════════════════════════════════════════════════════════════════════
  // MAP / ARENA
  // Shared visual treatment applied on top of individual mini-game
  // scenes so every mini-game — present and future — feels part of the
  // same game world even though each has its own gameplay art.
  // ═════════════════════════════════════════════════════════════════════

  /// Soft vignette tint applied over the edges of the arena/play surface
  /// to focus attention toward the center of the action.
  static const Color mapOverlayVignette = Color(0xB30D0619);

  /// Color used to render the play-area boundary line in mini-games
  /// with an explicit in/out-of-bounds zone.
  static const Color mapBoundaryLine = Color(0xFFFF2E8A);

  /// Color used to mark hazardous zones within a mini-game (e.g. a trap
  /// tile, a fall-out zone).
  static const Color mapHazardZone = Color(0xFFFF4D6A);

  /// Color used to mark safe zones within a mini-game (e.g. a checkpoint
  /// or protected area).
  static const Color mapSafeZone = Color(0xFF3DDC84);

  /// Faint grid-line color for mini-games built on a tile/grid layout
  /// (e.g. Memory Cards, Sequence Order).
  static const Color mapGridLine = Color(0x1AFFFFFF);

  // ═════════════════════════════════════════════════════════════════════
  // MINI-GAMES
  // A rotating accent palette — not one color per game — so the mini-
  // game catalog can grow indefinitely (Drawing Guess, Bluff Game, Spy
  // Game, ...) without ever needing a new constant added here. Assign
  // accents by index (e.g. `miniGameAccentPalette[gameIndex % length]`)
  // when rendering mini-game tiles, icons, and result screens.
  // ═════════════════════════════════════════════════════════════════════

  /// Fixed rotation of accent colors handed out to mini-game tiles,
  /// icons, and per-game result screens in catalog order.
  static const List<Color> miniGameAccentPalette = <Color>[
    Color(0xFF22E8D8),
    Color(0xFFFF2E8A),
    Color(0xFFFFB627),
    Color(0xFFB24DFF),
    Color(0xFF4DA6FF),
    Color(0xFF9BE15D),
  ];

  // ═════════════════════════════════════════════════════════════════════
  // TICKET UI
  // Tournament "entry ticket" visual metaphor used on the home screen
  // and room-join flow (a literal ticket-shaped card representing a
  // tournament entry, in keeping with the live-event framing). Modeled
  // on warm, physical ticket-stub paper rather than the app's usual
  // dark surfaces — like a golden ticket, it's meant to read as a
  // special, tangible object sitting on the night-arena backdrop, not
  // as another dark panel. Because the fill is light, its text/icon
  // tokens are tuned for a light surface (dark ink, warm accents)
  // instead of being reused from the dark-surface system, but the
  // gold accent and cyan "live" glow still tie back to the same brand
  // hues used everywhere else so the ticket still feels like Gawla.
  // ═════════════════════════════════════════════════════════════════════

  /// Background fill for the tournament entry ticket card. Warm cream
  /// stands in for physical ticket paper — a deliberate break from the
  /// dark [backgroundPrimary]/[surfaceDefault] family so the ticket
  /// pops off the arena backdrop as a special object worth noticing.
  static const Color ticketBackground = Color(0xFFFFE3C0);

  /// A step deeper than [ticketBackground], used for shapes printed on
  /// the ticket — the player/round count pills, the mini-game stop
  /// circles — so they read as their own chip without leaving the
  /// ticket's paper hue.
  static const Color ticketSurface = Color(0xFFF7D19D);

  /// The ticket's one recurring gold accent — the kicker label, pill
  /// icons, and the mini-game stop rings. A deeper amber than the old
  /// dark-surface value so it still has real contrast against the new
  /// light fill, while staying in the same reward-gold hue family as
  /// [brandAccentGold]: entering a tournament is still the gateway to
  /// earning rewards, gold still says so.
  static const Color ticketBorder = Color(0xFFA65D1A);

  /// Color of the dashed perforation line separating the ticket's main
  /// body from its tear-off stub, and of the connector lines linking
  /// the mini-game rotation stops. A muted tan pulled from the same
  /// paper hue as [ticketBackground], so both read as creases/print on
  /// the ticket itself rather than a generic dark-UI divider bleeding
  /// in from the rest of the app.
  static const Color ticketPerforationLine = Color(0xFFCB9C66);

  /// Primary text/icon color for content printed directly on the
  /// ticket (the tournament slogan, pill labels). Reuses [textInverse]
  /// — the app's existing "dark ink on a light/gold surface" token —
  /// so the ticket's typography still follows the one rule the rest of
  /// the system already has for light fills, instead of inventing a
  /// second one.
  static const Color ticketTextPrimary = textInverse;

  /// Secondary/muted text color for lower-emphasis copy on the ticket
  /// — the stop-order numbers, the "tap to find match" caption. Plays
  /// the same "recede" role [textSecondary] plays on dark surfaces,
  /// but as a warm brown so it stays legible on the light ticket fill.
  static const Color ticketTextSecondary = Color(0xFF7A5B3A);

  /// Overlay/stamp color applied across a ticket that has already been
  /// used (entered) to mark it as spent. A dark, neutral stamped-ink
  /// brown so the "used" mark reads the same regardless of what the
  /// ticket fill happens to be.
  static const Color ticketStampUsed = Color(0xFF4A3018);

  /// Glow color applied to a ticket for a tournament that's live right
  /// now and ready to jump into. Kept as the app's "alive / active"
  /// cyan ([brandAccentCyan]) rather than a warm tone — the live
  /// signal needs to stay the one color players learn to recognize
  /// everywhere else, and cyan reads even more clearly against the
  /// warm ticket fill than it did against the old dark one.
  static const Color ticketGlowActive = Color(0xFF22E8D8);

  /// Gradient used for the "golden ticket" effect on the tournament
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD166), Color(0xFFFFB627), Color(0xFFE8960B)],
  );

  // ═════════════════════════════════════════════════════════════════════
  // OVERLAY
  // Full-screen scrims and dedicated victory/defeat treatments — the
  // two highest-emotion moments in the entire match flow.
  // ═════════════════════════════════════════════════════════════════════

  /// Standard modal backdrop scrim placed behind dialogs, bottom sheets,
  /// and popovers.
  static const Color overlayScrim = Color(0xB3000000);

  /// Top gradient stop for the Victory screen background.
  static const Color overlayVictoryTop = Color(0xFFFFB627);

  /// Bottom gradient stop for the Victory screen background. Pair with
  /// [overlayVictoryTop].
  static const Color overlayVictoryBottom = Color(0xFF130A24);

  /// Top gradient stop for the Defeat/eliminated-from-tournament screen
  /// background.
  static const Color overlayDefeatTop = Color(0xFF4A4066);

  /// Bottom gradient stop for the Defeat screen background. Pair with
  /// [overlayDefeatTop].
  static const Color overlayDefeatBottom = Color(0xFF0D0619);

  /// Background for the banner shown to players who are spectating
  /// (already eliminated but still watching the match play out).
  static const Color overlaySpectatorBanner = Color(0xCC130A24);

  // ═════════════════════════════════════════════════════════════════════
  // SHADOW HELPERS
  // ═════════════════════════════════════════════════════════════════════

  /// Soft, low-elevation shadow for resting cards and list items.
  static const Color shadowSoft = Color(0x1A000000);

  /// Medium shadow for elevated elements — dialogs, floating action
  /// buttons, dropdown menus.
  static const Color shadowMedium = Color(0x33000000);

  /// Strong shadow for the highest-elevation elements — full-screen
  /// modals, the winner reveal card.
  static const Color shadowStrong = Color(0x52000000);

  /// Colored glow shadow used behind the primary CTA and selected cards
  /// to make them feel lit-up rather than merely elevated.
  static const Color shadowBrandGlow = Color(0x4D7C3AED);

  // ═════════════════════════════════════════════════════════════════════
  // TRANSPARENT COLORS
  // Reusable black/white alpha steps for one-off overlays, dividers, and
  // gradient fades that don't warrant their own named semantic color.
  // ═════════════════════════════════════════════════════════════════════

  /// 10% opacity black.
  static const Color black10 = Color(0x1A000000);

  /// 20% opacity black.
  static const Color black20 = Color(0x33000000);

  /// 40% opacity black.
  static const Color black40 = Color(0x66000000);

  /// 60% opacity black.
  static const Color black60 = Color(0x99000000);

  /// 80% opacity black.
  static const Color black80 = Color(0xCC000000);

  /// 10% opacity white.
  static const Color white10 = Color(0x1AFFFFFF);

  /// 20% opacity white.
  static const Color white20 = Color(0x33FFFFFF);

  /// 40% opacity white.
  static const Color white40 = Color(0x66FFFFFF);

  /// 60% opacity white.
  static const Color white60 = Color(0x99FFFFFF);

  static const Map<String, List<Color>> avatarPresetGradients = {
    'preset:blaze': [Color(0xFFFF3D7F), Color(0xFFFF9F43)],
    'preset:gold': [Color(0xFFFFC64B), Color(0xFFC98A1E)],
    'preset:teal': [Color(0xFF37E6C4), Color(0xFF1B9C86)],
    'preset:violet': [Color(0xFF8B7CF6), Color(0xFF4C3FBF)],
    'preset:rose': [Color(0xFFFF7CA3), Color(0xFFB4437C)],
    'preset:sky': [Color(0xFF5ED2FF), Color(0xFF2D6FE0)],
  };
}
