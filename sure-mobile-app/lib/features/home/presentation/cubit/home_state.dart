import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

/// Home page state using freezed for immutability
@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded() = _Loaded;
  const factory HomeState.error(String message) = _Error;
}
