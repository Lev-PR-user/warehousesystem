import 'package:flutter/material.dart';
import '../models/userdata.dart';
import '../service/userservice.dart';

class EditProfileScreen extends StatefulWidget {
  final UserData userData;
  final Function(UserData)? onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.userData,
    this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;

  final _loginCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loginCtrl.text = widget.userData.login;
    _emailCtrl.text = widget.userData.email;
    _phoneCtrl.text = widget.userData.phone;

    _loginCtrl.addListener(_checkChanges);
    _emailCtrl.addListener(_checkChanges);
    _phoneCtrl.addListener(_checkChanges);
  }

  void _checkChanges() {
    final hasChanges =
        _loginCtrl.text != widget.userData.login ||
        _emailCtrl.text != widget.userData.email ||
        _phoneCtrl.text != widget.userData.phone;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updateData = {
        if (_loginCtrl.text != widget.userData.login)
          'login': _loginCtrl.text.trim(),
        if (_emailCtrl.text != widget.userData.email)
          'email': _emailCtrl.text.trim(),
        if (_phoneCtrl.text != widget.userData.phone)
          'phone': _phoneCtrl.text.trim(),
      };

      if (updateData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет изменений для сохранения')),
        );
        return;
      }

      final response = await _userService.updateProfile(
        widget.userData.userId,
        updateData,
      );

      final updatedUserData = UserData.fromJson(response['user'] ?? {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль успешно обновлен!')),
      );

      if (widget.onProfileUpdated != null) {
        widget.onProfileUpdated!(updatedUserData);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка обновления: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validateLogin(String? value) {
    final login = value?.trim() ?? '';
    if (login.isEmpty) return 'Введите логин';
    if (login.length < 3) return 'Логин должен быть не менее 3 символов';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(login)) {
      return 'Только латинские буквы, цифры и подчеркивание';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Введите email';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Введите телефон';
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanedPhone.length < 10) {
      return 'Введите корректный номер телефона';
    }
    return null;
  }

  void _discardChanges() {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Отменить изменения?'),
          content: const Text('Все несохраненные изменения будут потеряны.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Продолжить редактирование'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Отменить',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование профиля'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _discardChanges,
        ),
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveProfile,
              tooltip: 'Сохранить',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildAvatarSection(),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _loginCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Логин',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      style: const TextStyle(color: Colors.black87),
                      validator: _validateLogin,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      style: const TextStyle(color: Colors.black87),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Телефон',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      style: const TextStyle(color: Colors.black87),
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hasChanges && !_isLoading
                            ? _saveProfile
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black87,
                                ),
                              )
                            : const Text(
                                'Сохранить изменения',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _discardChanges,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.black87),
                        ),
                        child: Text(
                          'Отменить',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black87,
              backgroundImage: widget.userData.avatarUrl != null
                  ? NetworkImage(widget.userData.avatarUrl!)
                  : null,
              child: widget.userData.avatarUrl == null
                  ? Text(
                      widget.userData.login.isNotEmpty
                          ? widget.userData.login[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black87, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black87,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Загрузка аватарки - в разработке')),
            );
          },
          child: const Text(
            'Изменить фото',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
