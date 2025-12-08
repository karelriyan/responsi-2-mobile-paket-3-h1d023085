import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_isRegistering) {
        await auth.signUp(email: _emailCtrl.text, password: _passwordCtrl.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
          );
        }
        setState(() => _isRegistering = false);
      } else {
        await auth.signInWithPassword(email: _emailCtrl.text, password: _passwordCtrl.text);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book, size: 64, color: Colors.brown),
                  const SizedBox(height: 16),
                  Text(
                    _isRegistering ? 'Daftar Akun' : 'Login Inventaris',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _authenticate,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isRegistering ? 'DAFTAR' : 'MASUK'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isRegistering = !_isRegistering),
                    child: Text(_isRegistering ? 'Sudah punya akun? Login' : 'Belum punya akun? Daftar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
