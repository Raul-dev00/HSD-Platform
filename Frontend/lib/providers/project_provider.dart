import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/constants.dart';
import '../models/project.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  List<Project> _myProjects = [];
  bool _loading = false;
  String? _error;

  List<Project> get projects => _projects;
  List<Project> get myProjects => _myProjects;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadProjects({String? status}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.get(
        AppConstants.projects,
        params: status != null ? {'status': status} : null,
      );
      _projects = (data as List).map((e) => Project.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyProjects() async {
    try {
      final data = await ApiService.get(AppConstants.myProjects);
      _myProjects = (data as List).map((e) => Project.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<Project> createProject(String name, String description) async {
    final data = await ApiService.post(AppConstants.projects, {
      'name': name,
      'description': description,
    });
    final project = Project.fromJson(data);
    _projects.insert(0, project);
    notifyListeners();
    return project;
  }

  Future<Project> getProjectById(int id) async {
    final data = await ApiService.get('${AppConstants.projects}/$id');
    return Project.fromJson(data);
  }

  Future<void> applyToProject(int projectId, String? role) async {
    await ApiService.post(
      '${AppConstants.projects}/$projectId/apply',
      {'role': role ?? ''},
    );
  }

  Future<List<ProjectMember>> getApplications(int projectId) async {
    final data = await ApiService.get('${AppConstants.projects}/$projectId/applications');
    return (data as List).map((e) => ProjectMember.fromJson(e)).toList();
  }

  Future<void> updateApplicationStatus(int applicationId, String status) async {
    await ApiService.put(
      '${AppConstants.projects}/applications/$applicationId/status',
      {'status': status},
    );
  }

  Future<void> deleteProject(int id) async {
    await ApiService.delete('${AppConstants.projects}/$id');
    _projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
