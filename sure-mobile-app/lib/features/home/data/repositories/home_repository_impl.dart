import 'package:injectable/injectable.dart';

import '../../../../core/tools/result.dart';
import '../../domain/repositories/home_repository.dart';

/// Home repository implementation (data layer)
@Injectable(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<Result<void>> loadHomeData() async {
    // TODO(home): Implement with data sources
    return const Success(null);
  }
}
