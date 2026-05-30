import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';
import '../../models/skill.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _githubCtrl;
  late TextEditingController _linkedinCtrl;
  int? _selectedYear;
  List<Skill> _allSkills = [];
  final Set<int> _selectedSkillIds = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
    _githubCtrl = TextEditingController(text: user?.githubUrl ?? '');
    _linkedinCtrl = TextEditingController(text: user?.linkedinUrl ?? '');
    _selectedYear = user?.yearLevel;
    if (user != null) {
      _selectedSkillIds.addAll(user.skills.map((s) => s.id));
    }
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      final data = await ApiService.get(AppConstants.skills);
      setState(() {
        _allSkills = (data as List).map((e) => Skill.fromJson(e)).toList();
      });
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.currentUser!.id;
      final body = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'githubUrl': _githubCtrl.text.trim(),
        'linkedinUrl': _linkedinCtrl.text.trim(),
        if (_selectedYear != null) 'yearLevel': _selectedYear,
        'skillIds': _selectedSkillIds.toList(),
      };
      final data = await ApiService.put('${AppConstants.users}/$userId', body);
      auth.updateUser(User.fromJson(data));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi'), backgroundColor: Colors.green),
        );
        context.pop();
      }
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
    _bioCtrl.dispose();
    _githubCtrl.dispose();
    _linkedinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Kaydet'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              TextFormField(
                controller: _bioCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Hakkımda',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              TextFormField(
                controller: _githubCtrl,
                decoration: const InputDecoration(
                  labelText: 'GitHub URL',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _linkedinCtrl,
                decoration: const InputDecoration(
                  labelText: 'LinkedIn URL',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Yetenekler',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_allSkills.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _allSkills.map((skill) {
                    final selected = _selectedSkillIds.contains(skill.id);
                    return FilterChip(
                      label: Text(skill.name),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedSkillIds.add(skill.id);
                          } else {
                            _selectedSkillIds.remove(skill.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
