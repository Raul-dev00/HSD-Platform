import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';
import '../../models/university.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  List<University> _universities = [];
  List<Department> _departments = [];
  University? _selectedUniversity;
  Department? _selectedDepartment;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      final data = await ApiService.get(AppConstants.universities, auth: false);
      setState(() {
        _universities = (data as List).map((e) => University.fromJson(e)).toList();
      });
    } catch (_) {}
  }

  Future<void> _loadDepartments(int universityId) async {
    try {
      final data = await ApiService.get(
        '${AppConstants.universities}/$universityId/departments',
        auth: false,
      );
      setState(() {
        _departments = (data as List).map((e) => Department.fromJson(e)).toList();
        _selectedDepartment = null;
      });
    } catch (_) {}
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            universityId: _selectedUniversity?.id,
            departmentId: _selectedDepartment?.id,
            yearLevel: _selectedYear,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ad Soyad
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Ad boş olamaz' : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email boş olamaz';
                    if (!v.contains('@')) return 'Geçerli email giriniz';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Şifre
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Şifre boş olamaz';
                    if (v.length < 6) return 'En az 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Üniversite seçimi
                DropdownButtonFormField<University>(
                  value: _selectedUniversity,
                  decoration: const InputDecoration(
                    labelText: 'Üniversite',
                    prefixIcon: Icon(Icons.school_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _universities
                      .map((u) => DropdownMenuItem(value: u, child: Text(u.name)))
                      .toList(),
                  onChanged: (u) {
                    setState(() {
                      _selectedUniversity = u;
                      _departments = [];
                    });
                    if (u != null) _loadDepartments(u.id);
                  },
                ),
                const SizedBox(height: 16),

                // Bölüm seçimi
                DropdownButtonFormField<Department>(
                  value: _selectedDepartment,
                  decoration: const InputDecoration(
                    labelText: 'Bölüm',
                    prefixIcon: Icon(Icons.class_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _departments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                      .toList(),
                  onChanged: (d) => setState(() => _selectedDepartment = d),
                ),
                const SizedBox(height: 16),

                // Sınıf
                DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Sınıf',
                    prefixIcon: Icon(Icons.grade_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: [1, 2, 3, 4, 5]
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y. Sınıf')))
                      .toList(),
                  onChanged: (y) => setState(() => _selectedYear = y),
                ),
                const SizedBox(height: 28),

                FilledButton(
                  onPressed: _loading ? null : _register,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Kayıt Ol', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Zaten hesabın var mı? Giriş yap'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
