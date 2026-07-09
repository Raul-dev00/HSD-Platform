import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadMyProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mesajlar')),
      body: Consumer<ProjectProvider>(
        builder: (_, provider, __) {
          final myProjects = provider.myProjects;
          if (myProjects.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Henüz bir proje sohbetiniz yok.',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Bir projeye katılın veya oluşturun.',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ProjectProvider>().loadMyProjects(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: myProjects.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final project = myProjects[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      project.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(project.name),
                  subtitle: Text(
                    'Proje Odası',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/chat/project/${project.id}',
                      extra: project.name),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
