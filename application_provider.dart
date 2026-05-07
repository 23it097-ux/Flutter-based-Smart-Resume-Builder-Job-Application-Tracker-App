import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job_application_model.dart';
import '../services/hive_service.dart';
import 'resume_provider.dart';

final applicationListProvider = NotifierProvider<ApplicationListNotifier, List<JobApplication>>(ApplicationListNotifier.new);

class ApplicationListNotifier extends Notifier<List<JobApplication>> {
  late HiveService _hiveService;

  @override
  List<JobApplication> build() {
    _hiveService = ref.watch(hiveServiceProvider);
    return _hiveService.getAllApplications();
  }

  Future<void> addApplication(JobApplication application) async {
    await _hiveService.saveApplication(application);
    state = _hiveService.getAllApplications();
  }

  Future<void> updateStatus(String id, ApplicationStatus status) async {
    final application = state.firstWhere((a) => a.id == id);
    application.status = status;
    await _hiveService.saveApplication(application);
    state = _hiveService.getAllApplications();
  }

  Future<void> deleteApplication(String id) async {
    await _hiveService.deleteApplication(id);
    state = _hiveService.getAllApplications();
  }

  List<JobApplication> search(String query) {
    if (query.isEmpty) return state;
    return state.where((a) => 
      a.companyName.toLowerCase().contains(query.toLowerCase()) ||
      a.jobRole.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}

// Stats providers for Dashboard
final totalApplicationsProvider = Provider((ref) {
  return ref.watch(applicationListProvider).length;
});

final statusCountProvider = Provider.family<int, ApplicationStatus>((ref, status) {
  return ref.watch(applicationListProvider).where((a) => a.status == status).length;
});

final statusDistributionProvider = Provider((ref) {
  final applications = ref.watch(applicationListProvider);
  final distribution = <ApplicationStatus, int>{};
  for (var status in ApplicationStatus.values) {
    distribution[status] = applications.where((a) => a.status == status).length;
  }
  return distribution;
});

final monthlyStatsProvider = Provider((ref) {
  final applications = ref.watch(applicationListProvider);
  final stats = <int, int>{}; // Month index -> count
  for (var app in applications) {
    final month = app.dateApplied.month;
    stats[month] = (stats[month] ?? 0) + 1;
  }
  return stats;
});

final resumeUsageStatsProvider = Provider((ref) {
  final applications = ref.watch(applicationListProvider);
  final resumes = ref.watch(resumeListProvider);
  final usage = <String, int>{}; // Resume Name -> count
  for (var app in applications) {
    final resume = resumes.where((r) => r.id == app.resumeId).firstOrNull;
    if (resume != null) {
      usage[resume.name] = (usage[resume.name] ?? 0) + 1;
    }
  }
  return usage;
});
