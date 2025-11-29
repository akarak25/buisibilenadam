import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:palm_analysis/services/notification_preferences_service.dart';
import 'package:palm_analysis/services/push_notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationPreferencesService _preferencesService =
      NotificationPreferencesService();

  NotificationPreferences? _preferences;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _systemNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    try {
      // Check system notification permission
      _systemNotificationsEnabled =
          await PushNotificationService.instance.areNotificationsEnabled();

      // Load preferences from server
      final preferences = await _preferencesService.getPreferences();

      if (mounted) {
        setState(() {
          _preferences = preferences;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _preferences = NotificationPreferences.defaults;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updatePreference(String key, dynamic value) async {
    if (_preferences == null) return;

    setState(() => _isSaving = true);

    NotificationPreferences newPrefs;
    switch (key) {
      case 'enabled':
        newPrefs = _preferences!.copyWith(enabled: value);
        break;
      case 'dailyReading':
        newPrefs = _preferences!.copyWith(dailyReading: value);
        break;
      case 'dailyReadingTime':
        newPrefs = _preferences!.copyWith(dailyReadingTime: value);
        break;
      case 'streakReminder':
        newPrefs = _preferences!.copyWith(streakReminder: value);
        break;
      case 'specialEvents':
        newPrefs = _preferences!.copyWith(specialEvents: value);
        break;
      default:
        setState(() => _isSaving = false);
        return;
    }

    final success = await _preferencesService.updateSinglePreference(key, value);

    if (mounted) {
      setState(() {
        if (success) {
          _preferences = newPrefs;
        }
        _isSaving = false;
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isTurkish
                ? 'Ayar kaydedilemedi'
                : 'Failed to save setting'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  void _showTimePicker() {
    if (_preferences == null) return;

    final parts = _preferences!.dailyReadingTime.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 9;
    final initialMinute = int.tryParse(parts[1]) ?? 0;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      _isTurkish ? 'Iptal' : 'Cancel',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    _isTurkish ? 'Bildirim Saati' : 'Notification Time',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      _isTurkish ? 'Tamam' : 'Done',
                      style: GoogleFonts.inter(
                        color: AppTheme.primaryIndigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(2000, 1, 1, initialHour, initialMinute),
                onDateTimeChanged: (dateTime) {
                  final newTime =
                      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
                  _updatePreference('dailyReadingTime', newTime);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isTurkish =>
      Localizations.localeOf(context).languageCode == 'tr';

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context).currentLanguage;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Soft overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.90),
                  ],
                ),
              ),
            ),

            // Decorative elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryIndigo.withOpacity(0.1),
                      AppTheme.primaryPurple.withOpacity(0.06),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isTurkish ? 'Bildirim Ayarlari' : 'Notification Settings',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (_isSaving)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryIndigo,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryIndigo,
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // System permission warning
                                if (!_systemNotificationsEnabled) ...[
                                  _buildWarningCard(),
                                  const SizedBox(height: 20),
                                ],

                                // Master toggle
                                _buildSectionTitle(
                                  _isTurkish
                                      ? 'Genel Ayarlar'
                                      : 'General Settings',
                                ),
                                const SizedBox(height: 12),
                                _buildSettingsCard(
                                  children: [
                                    _buildSwitchTile(
                                      icon: Icons.notifications_rounded,
                                      title: _isTurkish
                                          ? 'Bildirimleri Etkinlestir'
                                          : 'Enable Notifications',
                                      subtitle: _isTurkish
                                          ? 'Tum bildirimleri ac/kapat'
                                          : 'Turn all notifications on/off',
                                      value: _preferences?.enabled ?? true,
                                      onChanged: (value) =>
                                          _updatePreference('enabled', value),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Notification types
                                _buildSectionTitle(
                                  _isTurkish
                                      ? 'Bildirim Turleri'
                                      : 'Notification Types',
                                ),
                                const SizedBox(height: 12),
                                _buildSettingsCard(
                                  children: [
                                    _buildSwitchTile(
                                      icon: Icons.wb_sunny_rounded,
                                      title: _isTurkish
                                          ? 'Gunluk Yorum'
                                          : 'Daily Reading',
                                      subtitle: _isTurkish
                                          ? 'Her sabah kisisellestirilmis yorumunuz'
                                          : 'Your personalized reading every morning',
                                      value: _preferences?.dailyReading ?? true,
                                      onChanged:
                                          (_preferences?.enabled ?? true)
                                              ? (value) => _updatePreference(
                                                  'dailyReading', value)
                                              : null,
                                      trailing: GestureDetector(
                                        onTap: (_preferences?.enabled ?? true) &&
                                                (_preferences?.dailyReading ?? true)
                                            ? _showTimePicker
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryIndigo
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _preferences?.dailyReadingTime ??
                                                '09:00',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: (_preferences?.enabled ??
                                                          true) &&
                                                      (_preferences
                                                              ?.dailyReading ??
                                                          true)
                                                  ? AppTheme.primaryIndigo
                                                  : AppTheme.textMuted,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    _buildSwitchTile(
                                      icon: Icons.local_fire_department_rounded,
                                      title: _isTurkish
                                          ? 'Seri Hatirlatma'
                                          : 'Streak Reminder',
                                      subtitle: _isTurkish
                                          ? 'Serinizi kaybetmemek icin aksam hatirlatmasi'
                                          : 'Evening reminder to keep your streak',
                                      value:
                                          _preferences?.streakReminder ?? true,
                                      onChanged:
                                          (_preferences?.enabled ?? true)
                                              ? (value) => _updatePreference(
                                                  'streakReminder', value)
                                              : null,
                                    ),
                                    const Divider(height: 1),
                                    _buildSwitchTile(
                                      icon: Icons.auto_awesome_rounded,
                                      title: _isTurkish
                                          ? 'Ozel Gunler'
                                          : 'Special Events',
                                      subtitle: _isTurkish
                                          ? 'Dolunay, yeni ay ve diger ozel gunler'
                                          : 'Full moon, new moon and other special days',
                                      value:
                                          _preferences?.specialEvents ?? true,
                                      onChanged:
                                          (_preferences?.enabled ?? true)
                                              ? (value) => _updatePreference(
                                                  'specialEvents', value)
                                              : null,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Info text
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      _isTurkish
                                          ? 'Bildirimler el cizginize ve gunun enerjisine gore kisisellestirilir.'
                                          : 'Notifications are personalized based on your palm lines and daily energy.',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Icon(
          icon,
          color: AppTheme.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
    Widget? trailing,
  }) {
    final isEnabled = onChanged != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? AppTheme.primaryGradient
                  : LinearGradient(
                      colors: [
                        AppTheme.textMuted.withOpacity(0.3),
                        AppTheme.textMuted.withOpacity(0.2),
                      ],
                    ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color:
                        isEnabled ? AppTheme.textPrimary : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            trailing,
            const SizedBox(width: 8),
          ],
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryIndigo,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningAmber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningAmber.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.warningAmber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.warningAmber,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isTurkish
                      ? 'Bildirimler Kapali'
                      : 'Notifications Disabled',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isTurkish
                      ? 'Sistem ayarlarindan bildirimleri acin'
                      : 'Enable notifications in system settings',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await PushNotificationService.instance.openNotificationSettings();
              await Future.delayed(const Duration(seconds: 1));
              _loadPreferences();
            },
            child: Text(
              _isTurkish ? 'Ayarlar' : 'Settings',
              style: GoogleFonts.inter(
                color: AppTheme.warningAmber,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
