import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool(AppConstants.notificationsPrefKey) ?? true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.notificationsPrefKey, value);
      setState(() {
        _notificationsEnabled = value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value 
                  ? 'Notifications enabled' 
                  : 'Notifications disabled',
            ),
            backgroundColor: AppTheme.accentGold,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update notification settings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppTheme.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textGray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userProfile = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentGold,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User Profile Card
                Card(
                  color: AppTheme.secondaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppTheme.accentGold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Display Name
                        Text(
                          userProfile?.displayName ?? 'User',
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Email
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: AppTheme.textGray,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Account Created Date
                        if (userProfile?.createdAt != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Member since ${_formatDate(userProfile!.createdAt)}',
                              style: const TextStyle(
                                color: AppTheme.textGray,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Settings Section Header
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Preferences',
                    style: TextStyle(
                      color: AppTheme.textGray,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Notifications Toggle
                Card(
                  color: AppTheme.secondaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Notifications',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Receive updates about new listings',
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 13,
                      ),
                    ),
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    activeColor: AppTheme.accentGold,
                    secondary: const Icon(
                      Icons.notifications,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Account Section Header
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Account',
                    style: TextStyle(
                      color: AppTheme.textGray,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Email Verification Status
                if (user != null)
                  Card(
                    color: AppTheme.secondaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        user.emailVerified
                            ? Icons.verified_user
                            : Icons.warning,
                        color: user.emailVerified
                            ? Colors.green
                            : Colors.orange,
                      ),
                      title: const Text(
                        'Email Verification',
                        style: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        user.emailVerified
                            ? 'Email verified'
                            : 'Email not verified (Testing mode)',
                        style: const TextStyle(
                          color: AppTheme.textGray,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // Logout Button
                Card(
                  color: AppTheme.secondaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: _showLogoutConfirmation,
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Sign out of your account',
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 13,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // App Info
                Center(
                  child: Column(
                    children: [
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          color: AppTheme.textGray,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: AppTheme.textGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
