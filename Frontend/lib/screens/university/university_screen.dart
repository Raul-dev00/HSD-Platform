import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';
import '../../models/university.dart';
import '../../models/user.dart';

class UniversityScreen extends StatefulWidget {
  const UniversityScreen({super.key});

  @override
  State<UniversityScreen> createState() => _UniversityScreenState();
}

class _UniversityScreenState extends State<UniversityScreen> {
  List<University> _universities = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.get(AppConstants.universities);
      setState(() {
        _universities = (data as List).map((e) => University.fromJson(e)).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üniversiteler')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _universities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _UniversityCard(university: _universities[i]),
                  ),
                ),
    );
  }
}

class _UniversityCard extends StatefulWidget {
  final University university;
  const _UniversityCard({required this.university});

  @override
  State<_UniversityCard> createState() => _UniversityCardState();
}

class _UniversityCardState extends State<_UniversityCard> {
  bool _expanded = false;
  List<User> _members = [];
  bool _loadingMembers = false;

  Future<void> _toggleExpand() async {
    if (_expanded) {
      setState(() => _expanded = false);
      return;
    }
    setState(() {
      _expanded = true;
      _loadingMembers = true;
    });
    try {
      final data = await ApiService.get(
        '${AppConstants.universities}/${widget.university.id}/members',
      );
      setState(() {
        _members = (data as List).map((e) => User.fromJson(e)).toList();
      });
    } catch (_) {} finally {
      setState(() => _loadingMembers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                widget.university.name[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(widget.university.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: widget.university.city != null
                ? Text(widget.university.city!)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text('${widget.university.memberCount} üye',
                      style: const TextStyle(fontSize: 12)),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 4),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: _toggleExpand,
          ),
          if (_expanded)
            _loadingMembers
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                : _members.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Henüz üye yok',
                            style: TextStyle(color: Colors.grey)),
                      )
                    : Column(
                        children: [
                          const Divider(height: 1),
                          ..._members.map((user) => ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 16,
                                  child: Text(user.name[0].toUpperCase(),
                                      style: const TextStyle(fontSize: 12)),
                                ),
                                title: Text(user.name,
                                    style: const TextStyle(fontSize: 14)),
                                subtitle: user.departmentName != null
                                    ? Text(user.departmentName!,
                                        style: const TextStyle(fontSize: 12))
                                    : null,
                                trailing: user.yearLevel != null
                                    ? Text('${user.yearLevel}. Sınıf',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey))
                                    : null,
                              )),
                        ],
                      ),
        ],
      ),
    );
  }
}
