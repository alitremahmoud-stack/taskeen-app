import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/db_helper.dart';
import '../../widgets/navbar.dart';
import '../../models/project_model.dart';
import '../../models/employee_model.dart';
import '../../widgets/custom_stat_card.dart';
import '../../widgets/custom_empty_state.dart';
import '../../widgets/custom_error_state.dart';
import '../../widgets/custom_project_card.dart';
import '../../core/routes_names.dart';
import '../../core/user_session.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SqlDb _sqlDb = SqlDb();
  int userId = UserSession.userId;

  Future<List<dynamic>> _fetchData() async {
    return await Future.wait([
      _sqlDb.getAllProjects(userId),
      _sqlDb.getAllEmployees(userId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      drawer: const Navbar(),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder(
          future: _fetchData(),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return CustomErrorState(
                message: 'حدث خطأ: ${snapshot.error}',
                onRetry: () => setState(() {}),
              );
            }

            final projects = snapshot.data![0] as List<Project>;
            final employees = snapshot.data![1] as List<Employee>;

            // إحصائيات للرسم البياني
            int active = projects
                .where((p) => p.status == 'قيد التنفيذ')
                .length;
            int completed = projects.where((p) => p.status == 'منتهي').length;
            int stopped = projects.where((p) => p.status == 'متوقف').length;
            int study = projects.where((p) => p.status == 'قيد الدراسة').length;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ترحيب
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.05),
                          colorScheme.surface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.handshake_outlined,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'مرحباً بك في نظام إدارة شركة البناء',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // قسم الإحصائيات
                  Text(
                    'نظرة عامة',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomStatCard(
                          label: 'المشاريع',
                          count: projects.length,
                          icon: Icons.business_center,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomStatCard(
                          label: 'الموظفين',
                          count: employees.length,
                          icon: Icons.people,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // الرسم البياني (يظهر فقط إذا وجدت مشاريع)
                  if (projects.isNotEmpty) ...[
                    Text(
                      'توزيع حالة المشاريع',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: AspectRatio(
                          aspectRatio: 1.3,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  color: colorScheme.primary,
                                  value: active.toDouble(),
                                  title: active > 0
                                      ? 'قيد التنفيذ ($active)'
                                      : '',
                                  radius: 50,
                                  titleStyle: theme.textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                PieChartSectionData(
                                  color: Colors.green.shade600,
                                  value: completed.toDouble(),
                                  title: completed > 0
                                      ? 'منتهي ($completed)'
                                      : '',
                                  radius: 50,
                                  titleStyle: theme.textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                PieChartSectionData(
                                  color: Colors.grey.shade600,
                                  value: stopped.toDouble(),
                                  title: stopped > 0 ? 'متوقف ($stopped)' : '',
                                  radius: 50,
                                  titleStyle: theme.textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                PieChartSectionData(
                                  color: colorScheme.secondary,
                                  value: study.toDouble(),
                                  title: study > 0
                                      ? 'قيد الدراسة ($study)'
                                      : '',
                                  radius: 50,
                                  titleStyle: theme.textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // آخر المشاريع
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'آخر المشاريع المضافة',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RoutesNames.projects,
                          ).then((_) => setState(() {}));
                        },
                        child: Text(
                          'عرض الكل',
                          style: TextStyle(color: colorScheme.secondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (projects.isEmpty)
                    CustomEmptyState(
                      title: 'لا توجد مشاريع مضافة بعد',
                      subtitle: 'قم بإضافة مشروع جديد من القائمة الجانبية',
                      icon: Icons.business_center_outlined,
                      buttonText: 'إضافة مشروع',
                      onButtonPressed: () {
                        Navigator.pushNamed(
                          context,
                          RoutesNames.addProject,
                        ).then((_) => setState(() {}));
                      },
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: projects.length > 5 ? 5 : projects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return CustomProjectCard(
                          project: project,
                          onTap: () => Navigator.pushNamed(
                            context,
                            RoutesNames.projectDetails,
                            arguments: project,
                          ).then((_) => setState(() {})),
                          showActions:
                              false, // لا نعرض أزرار التعديل والحذف في لوحة التحكم
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
