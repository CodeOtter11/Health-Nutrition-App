import 'health_service.dart';

class HealthServiceWeb implements HealthService {
  @override
  Future<void> init() async {
    // Web does not support health APIs
    return;
  }
}

HealthService getHealthService() => HealthServiceWeb();
