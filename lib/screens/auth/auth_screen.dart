import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../main_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'maksim@coolpadel.app');
  final _password = TextEditingController(text: '123456');
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    final error = await widget.appState.auth.login(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => MainShellScreen(appState: widget.appState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Icon(Icons.sports_tennis,
                  size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'CoolPadel',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Войдите, чтобы вести игры и турниры',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Войти'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                RegisterScreen(appState: widget.appState),
                          ),
                        );
                      },
                child: const Text('Создать аккаунт'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    final error = await widget.appState.auth.register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => MainShellScreen(appState: widget.appState),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Имя'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Пароль'),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _register,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Зарегистрироваться'),
          ),
        ],
      ),
    );
  }
}
