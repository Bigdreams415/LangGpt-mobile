import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/home_dashboard_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl._();
  static final HomeRepositoryImpl instance = HomeRepositoryImpl._();

  final _remoteDataSource = HomeRemoteDataSource.instance;

  @override
  Future<HomeDashboardModel> getHomeDashboard() async {
    return await _remoteDataSource.getHomeDashboard();
  }
}