// core/routes.dart
import 'package:flutter/material.dart';
import 'package:taskeen_app/features/auth/login_screen.dart';
import 'package:taskeen_app/features/auth/signup_screen.dart';
import 'package:taskeen_app/features/dashboard/dashboard_screen.dart';
import 'package:taskeen_app/features/projects/projects_screen.dart';
import 'package:taskeen_app/features/projects/add_project_screen.dart';
import 'package:taskeen_app/features/projects/edit_project_screen.dart';
import 'package:taskeen_app/features/projects/project_details_screen.dart';
import 'package:taskeen_app/features/projects/assign_employees_screen.dart';
import 'package:taskeen_app/features/employees/employees_screen.dart';
import 'package:taskeen_app/features/employees/add_employee_screen.dart';
import 'package:taskeen_app/features/employees/edit_employee_screen.dart';
import 'package:taskeen_app/features/employees/employee_details_screen.dart';
import 'package:taskeen_app/features/invoices/invoices_screen.dart';
import 'package:taskeen_app/features/invoices/add_invoice_screen.dart';
import 'package:taskeen_app/features/invoices/edit_invoice_screen.dart';
import 'package:taskeen_app/features/notifications/notifications_screen.dart';
import 'package:taskeen_app/models/project_model.dart';
import 'package:taskeen_app/models/employee_model.dart';
import 'package:taskeen_app/models/invoice_model.dart';
import 'routes_names.dart';

class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case RoutesNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RoutesNames.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case RoutesNames.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case RoutesNames.projects:
        return MaterialPageRoute(builder: (_) => const ProjectsScreen());
      case RoutesNames.addProject:
        return MaterialPageRoute(builder: (_) => const AddProjectScreen());
      case RoutesNames.editProject:
        if (args is Project) {
          return MaterialPageRoute(
            builder: (_) => EditProjectScreen(project: args),
          );
        }
        return _errorRoute();
      case RoutesNames.projectDetails:
        if (args is Project) {
          return MaterialPageRoute(
            builder: (_) => ProjectDetailsScreen(project: args),
          );
        }
        return _errorRoute();
      case RoutesNames.assignEmployees:
        if (args is Project) {
          return MaterialPageRoute(
            builder: (_) => AssignEmployeesScreen(project: args),
          );
        }
        return _errorRoute();
      case RoutesNames.employees:
        return MaterialPageRoute(builder: (_) => const EmployeesScreen());
      case RoutesNames.addEmployee:
        return MaterialPageRoute(builder: (_) => const AddEmployeeScreen());
      case RoutesNames.editEmployee:
        if (args is Employee) {
          return MaterialPageRoute(
            builder: (_) => EditEmployeeScreen(employee: args),
          );
        }
        return _errorRoute();
      case RoutesNames.employeeDetails:
        if (args is Employee) {
          return MaterialPageRoute(
            builder: (_) => EmployeeDetailsScreen(employee: args),
          );
        }
        return _errorRoute();
      case RoutesNames.invoices:
        return MaterialPageRoute(builder: (_) => const InvoicesScreen());
      case RoutesNames.addInvoice:
        return MaterialPageRoute(builder: (_) => const AddInvoiceScreen());
      case RoutesNames.editInvoice:
        if (args is Invoice) {
          return MaterialPageRoute(
            builder: (_) => EditInvoiceScreen(invoice: args),
          );
        }
        return _errorRoute();
      case RoutesNames.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            'خطأ: المسار غير موجود',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
