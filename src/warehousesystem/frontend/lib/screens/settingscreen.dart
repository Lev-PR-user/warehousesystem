import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool darkModeEnabled = true;
  String _selectedLanguage = 'Русский';
  String _selectedTheme = 'Темная';

  final List<String> _languages = ['Русский', 'English', 'Español', 'Deutsch'];
  final List<String> _themes = ['Темная', 'Светлая'];

  void showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выберите язык'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                return ListTile(
                  title: Text(language),
                  trailing: _selectedLanguage == language
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    Navigator.pop(context);
                    _showSnackBar('Язык изменен на $language');
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выберите тему'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                final theme = _themes[index];
                return ListTile(
                  title: Text(theme),
                  trailing: _selectedTheme == theme
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedTheme = theme;
                    });
                    Navigator.pop(context);
                    _showSnackBar('Тема изменена на "$theme"');
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('О приложении'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.coffee, color: Colors.blue, size: 40),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Coferitto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Версия 1.0.0',
                style: TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Одна команда. Одна семья. Один кофе.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                '© 2024 Coferitto. Все права защищены.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSettingsSection(
            title: 'УВЕДОМЛЕНИЯ',
            children: [
              _buildSettingsSwitch(
                icon: Icons.notifications,
                title: 'Push-уведомления',
                subtitle: 'Получать уведомления о заказах и акциях',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _showSnackBar(
                    value ? 'Уведомления включены' : 'Уведомления выключены',
                  );
                },
              ),
            ],
          ),

          _buildSettingsSection(
            title: 'ВНЕШНИЙ ВИД',
            children: [
              _buildSettingsOption(
                icon: Icons.language,
                title: 'Язык',
                subtitle: _selectedLanguage,
                onTap: showLanguageDialog,
              ),
              _buildSettingsOption(
                icon: Icons.palette,
                title: 'Тема',
                subtitle: _selectedTheme,
                onTap: _showThemeDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 1,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: Theme.of(context).cardColor,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title, style: const TextStyle(color: Colors.black87)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.black87)),
          trailing: const Icon(Icons.chevron_right, color: Colors.black87),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 56),
      ],
    );
  }

  Widget _buildSettingsSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title, style: const TextStyle(color: Colors.black87)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.black87)),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ),
        const Divider(height: 1, indent: 56),
      ],
    );
  }
}
