import '../../../../core/tools/result.dart';

/// Home repository interface (domain layer)
/// Implementations go in data layer
abstract class HomeRepository {
  /// Example method - replace with actual business logic
  Future<Result<void>> loadHomeData();
}
