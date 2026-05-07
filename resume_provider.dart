import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resume_model.dart';
import '../services/hive_service.dart';

final hiveServiceProvider = Provider((ref) => HiveService());

final resumeListProvider = NotifierProvider<ResumeListNotifier, List<Resume>>(ResumeListNotifier.new);

class ResumeListNotifier extends Notifier<List<Resume>> {
  late HiveService _hiveService;

  @override
  List<Resume> build() {
    _hiveService = ref.watch(hiveServiceProvider);
    return _hiveService.getAllResumes();
  }

  Future<void> addResume(Resume resume) async {
    await _hiveService.saveResume(resume);
    state = _hiveService.getAllResumes();
  }

  Future<void> updateResume(Resume resume) async {
    await _hiveService.saveResume(resume);
    state = _hiveService.getAllResumes();
  }

  Future<void> deleteResume(String id) async {
    await _hiveService.deleteResume(id);
    state = _hiveService.getAllResumes();
  }
  
  Resume? getResumeById(String id) {
    try {
      return state.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
