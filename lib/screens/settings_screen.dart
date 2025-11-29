import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:palm_analysis/screens/profile_screen.dart';
import 'package:palm_analysis/screens/notification_settings_screen.dart';
import 'package:palm_analysis/services/auth_service.dart';
import 'package:palm_analysis/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.loadStoredUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white.withValues(alpha: 0.90),
                  ],
                ),
              ),
            ),

            // Decorative elements
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withValues(alpha: 0.1),
                      AppTheme.primaryIndigo.withValues(alpha: 0.06),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          lang.settingsTitle,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Account Section
                          _buildSectionTitle(lang.account),
                          const SizedBox(height: 12),
                          _buildSettingsCard(
                            children: [
                              _buildSettingsTile(
                                icon: Icons.person_outline_rounded,
                                title: lang.profile,
                                subtitle: _currentUser?.name ?? lang.loginRequired,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                              if (_currentUser != null) ...[
                                const Divider(height: 1, indent: 16, endIndent: 16),
                                _buildSettingsTile(
                                  icon: Icons.delete_forever_rounded,
                                  title: lang.deleteAccount,
                                  subtitle: Localizations.localeOf(context).languageCode == 'tr'
                                      ? 'Hesabınızı ve tüm verilerinizi silin'
                                      : 'Delete your account and all data',
                                  onTap: _showDeleteAccountDialog,
                                  isDanger: true,
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 24),

                          // App Settings Section
                          _buildSectionTitle(lang.settings),
                          const SizedBox(height: 12),
                          _buildSettingsCard(
                            children: [
                              _buildSettingsTile(
                                icon: Icons.notifications_rounded,
                                title: Localizations.localeOf(context).languageCode == 'tr'
                                    ? 'Bildirim Ayarlari'
                                    : 'Notification Settings',
                                subtitle: Localizations.localeOf(context).languageCode == 'tr'
                                    ? 'Gunluk bildirimler ve hatirlatmalar'
                                    : 'Daily notifications and reminders',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NotificationSettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // About Section
                          _buildSectionTitle(lang.aboutApp),
                          const SizedBox(height: 12),
                          _buildSettingsCard(
                            children: [
                              _buildSettingsTile(
                                icon: Icons.privacy_tip_outlined,
                                title: lang.privacyPolicy,
                                onTap: () {
                                  _openUrl('https://elcizgisi.com/gizlilik');
                                },
                              ),
                              _buildSettingsTile(
                                icon: Icons.description_outlined,
                                title: lang.termsOfService,
                                onTap: () {
                                  _openUrl('https://elcizgisi.com/kullanim');
                                },
                              ),
                              _buildSettingsTile(
                                icon: Icons.info_outline_rounded,
                                title: lang.aboutApp,
                                subtitle: 'v1.0.0',
                                onTap: () {
                                  _showAboutDialog();
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // App info
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryIndigo
                                            .withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.back_hand_rounded,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) =>
                                      AppTheme.primaryGradient.createShader(
                                    Rect.fromLTWH(
                                        0, 0, bounds.width, bounds.height),
                                  ),
                                  child: Text(
                                    lang.appName,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'elcizgisi.com',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
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
          color: Colors.white.withValues(alpha: 0.8),
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
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
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

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isPremium = false,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isDanger
                    ? LinearGradient(
                        colors: [
                          AppTheme.dangerRed.withValues(alpha: 0.9),
                          AppTheme.dangerRed,
                        ],
                      )
                    : isPremium
                        ? AppTheme.premiumGradient
                        : AppTheme.primaryGradient,
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
                      color: isDanger ? AppTheme.dangerRed : AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDanger ? AppTheme.dangerRed.withValues(alpha: 0.5) : AppTheme.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final lang = AppLocalizations.of(context).currentLanguage;
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.dangerRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: AppTheme.dangerRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              lang.deleteAccount,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.dangerRed,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.deleteAccountConfirmation,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.dangerRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.dangerRed.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.dangerRed,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isTurkish
                          ? 'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.'
                          : 'This action cannot be undone. All your data will be permanently deleted.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.dangerRed,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              lang.cancel,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteAccount();
            },
            child: Text(
              lang.deleteAccount,
              style: GoogleFonts.inter(
                color: AppTheme.dangerRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final lang = AppLocalizations.of(context).currentLanguage;
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.dangerRed),
            ),
            const SizedBox(width: 20),
            Text(
              isTurkish ? 'Hesap siliniyor...' : 'Deleting account...',
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ],
        ),
      ),
    );

    try {
      await _authService.deleteAccount();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show success and navigate to home
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.accountDeleted),
            backgroundColor: AppTheme.successGreen,
          ),
        );

        // Navigate to home and clear navigation stack
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isTurkish
                ? 'Hesap silinemedi: $e'
                : 'Failed to delete account: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    final lang = AppLocalizations.of(context).currentLanguage;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.back_hand_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: Text(
                lang.appName,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              lang.appDescription,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'elcizgisi.com',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.primaryIndigo,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Tamam',
              style: GoogleFonts.inter(
                color: AppTheme.primaryIndigo,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
