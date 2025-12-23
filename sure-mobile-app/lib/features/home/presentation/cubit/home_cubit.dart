import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'home_state.dart';

/// Home page Cubit for state management
@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState.initial());

  /// Load home data
  Future<void> load() async {
    emit(const HomeState.loading());

    // TODO(home): Implement data loading with use cases
    // Example with Result<T> pattern:
    // final result = await _loadHomeDataUseCase();
    // result.when(
    //   success: (data) => emit(HomeState.loaded(data: data)),
    //   failure: (message) => emit(HomeState.error(message)),
    // );

    // For now, just emit loaded state
    emit(const HomeState.loaded());
  }
}
