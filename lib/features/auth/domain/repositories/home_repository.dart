import '../../data/models/home_dashboard_model.dart';

abstract class HomeRepository {
  /// Fetch all data needed for the home screen
  Future<HomeDashboardModel> getHomeDashboard();
}