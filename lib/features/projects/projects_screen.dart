import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../models/project_model.dart';
import '../../widgets/navbar.dart';
import '../../widgets/custom_empty_state.dart';
import '../../widgets/custom_error_state.dart';
import '../../widgets/custom_project_card.dart';
import '../../core/routes_names.dart';
import '../../core/user_session.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final SqlDb _sqlDb = SqlDb();
  int currentUserId = UserSession.userId;
  Future<List<Project>> _fetchProjects() async {
    return await _sqlDb.getAllProjects(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المشاريع'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ميزة البحث قريباً')),
            ),
          ),
        ],
      ),
      drawer: const Navbar(),
      body: RefreshIndicator(
        onRefresh: _fetchProjects,
        child: FutureBuilder<List<Project>>(
          future: _fetchProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return CustomErrorState(
                message: 'حدث خطأ: ${snapshot.error}',
                onRetry: () => setState(() {}),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return CustomEmptyState(
                title: 'لا توجد مشاريع مضافة بعد',
                subtitle: 'اضغط على زر + لإضافة أول مشروع',
                icon: Icons.business_center_outlined,
                buttonText: 'إضافة مشروع',
                onButtonPressed: () => Navigator.pushNamed(context, RoutesNames.addProject)
                    .then((_) => setState(() {})),
              );
            }

            final projects = snapshot.data!;
            return Column(
              children: [
                // بطاقة إحصائية
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('إجمالي المشاريع', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.primary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: colorScheme.secondary, borderRadius: BorderRadius.circular(20)),
                        child: Text('${projects.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return CustomProjectCard(
                        project: project,
                        onTap: () => Navigator.pushNamed(context, RoutesNames.projectDetails, arguments: project)
                            .then((_) => setState(() {})),
                        onEdit: () => Navigator.pushNamed(context, RoutesNames.editProject, arguments: project)
                            .then((_) => setState(() {})),
                        onDelete: () async {
                          await _sqlDb.deleteProject(project.id!);
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, RoutesNames.addProject).then((_) => setState(() {})),
        backgroundColor: colorScheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
