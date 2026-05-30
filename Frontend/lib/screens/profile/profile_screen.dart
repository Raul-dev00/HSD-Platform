import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        final user = auth.currentUser;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profilim'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/profile/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(user.email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                // Bilgiler
                _ProfileCard(
                  children: [
                    if (user.universityName != null)
                      _ProfileItem(
                          icon: Icons.school_outlined, label: 'Üniversite', value: user.universityName!),
                    if (user.departmentName != null)
                      _ProfileItem(
                          icon: Icons.class_outlined, label: 'Bölüm', value: user.departmentName!),
                    if (user.yearLevel != null)
                      _ProfileItem(
                          icon: Icons.grade_outlined,
                          label: 'Sınıf',
                          value: '${user.yearLevel}. Sınıf'),
                  ],
                ),

                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ProfileCard(
                    title: 'Hakkımda',
                    children: [
                      Text(user.bio!, style: const TextStyle(fontSize: 14, height: 1.5)),
                    ],
                  ),
                ],

                if (user.skills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ProfileCard(
                    title: 'Yetenekler',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: user.skills
                            .map((s) => Chip(
                                  label: Text(s.name, style: const TextStyle(fontSize: 13)),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondaryContainer,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ],

                if (user.githubUrl != null || user.linkedinUrl != null) ...[
                  const SizedBox(height: 16),
                  _ProfileCard(
                    title: 'Bağlantılar',
                    children: [
                      if (user.githubUrl != null)
                        _ProfileItem(icon: Icons.link, label: 'GitHub', value: user.githubUrl!),
                      if (user.linkedinUrl != null)
                        _ProfileItem(
                            icon: Icons.link, label: 'LinkedIn', value: user.linkedinUrl!),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _ProfileCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
