import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Project? _project;
  List<ProjectMember> _applications = [];
  bool _loading = true;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final provider = context.read<ProjectProvider>();
      final authProvider = context.read<AuthProvider>();
      _project = await provider.getProjectById(widget.projectId);
      _isOwner = _project!.ownerId == authProvider.currentUser?.id;
      if (_isOwner) {
        _applications = await provider.getApplications(widget.projectId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply() async {
    final roleCtrl = TextEditingController();
    final role = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Başvur'),
        content: TextField(
          controller: roleCtrl,
          decoration: const InputDecoration(
            labelText: 'Rol (isteğe bağlı)',
            hintText: 'Örn: Computer Vision Developer',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, roleCtrl.text),
            child: const Text('Başvur'),
          ),
        ],
      ),
    );
    if (role == null) return;
    try {
      await context.read<ProjectProvider>().applyToProject(widget.projectId, role);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Başvurunuz alındı!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _updateApplicationStatus(int applicationId, String status) async {
    try {
      await context.read<ProjectProvider>().updateApplicationStatus(applicationId, status);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Proje bulunamadı')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_project!.name),
        actions: [
          // Proje chat'ine git
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => context.push('/chat/project/${_project!.id}'),
          ),
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Projeyi Sil'),
                    content: const Text('Bu projeyi silmek istediğinizden emin misiniz?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await context.read<ProjectProvider>().deleteProject(_project!.id);
                  if (mounted) context.pop();
                }
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Durum badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _project!.statusLabel,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Açıklama
              if (_project!.description != null && _project!.description!.isNotEmpty) ...[
                Text('Açıklama',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_project!.description!, style: const TextStyle(fontSize: 15, height: 1.5)),
                const SizedBox(height: 20),
              ],

              // Proje sahibi
              _InfoRow(icon: Icons.person_outline, label: 'Proje Sahibi', value: _project!.ownerName),
              _InfoRow(icon: Icons.group_outlined, label: 'Üye Sayısı', value: '${_project!.memberCount}'),
              const SizedBox(height: 24),

              // Başvurular (sadece proje sahibi için)
              if (_isOwner && _applications.isNotEmpty) ...[
                Text('Başvurular (${_applications.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._applications.map((app) => _ApplicationCard(
                      application: app,
                      onAccept: () => _updateApplicationStatus(app.id, 'ACCEPTED'),
                      onReject: () => _updateApplicationStatus(app.id, 'REJECTED'),
                    )),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      // Başvur butonu (proje sahibi değilse)
      bottomNavigationBar: !_isOwner
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _apply,
                icon: const Icon(Icons.send),
                label: const Text('Bu Projeye Başvur'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ProjectMember application;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  const _ApplicationCard({required this.application, required this.onAccept, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final isPending = application.memberStatus == 'PENDING';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(application.userName),
        subtitle: Text(application.role ?? 'Rol belirtilmedi'),
        trailing: isPending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    onPressed: onAccept,
                    tooltip: 'Kabul Et',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    onPressed: onReject,
                    tooltip: 'Reddet',
                  ),
                ],
              )
            : Chip(
                label: Text(application.memberStatus == 'ACCEPTED' ? 'Kabul' : 'Red'),
                backgroundColor: application.memberStatus == 'ACCEPTED'
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
              ),
      ),
    );
  }
}
