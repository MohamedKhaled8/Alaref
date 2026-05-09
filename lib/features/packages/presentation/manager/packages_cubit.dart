import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:alaref/core/utils/services/user_stage_provider.dart';
import '../../domain/usecases/get_packages_usecase.dart';
import 'packages_state.dart';

class PackagesCubit extends Cubit<PackagesState> {
  final GetPackagesUseCase getPackagesUseCase;
  final UserStageProvider userStageProvider;
  StreamSubscription? _sub;

  PackagesCubit({
    required this.getPackagesUseCase,
    required this.userStageProvider,
  }) : super(const PackagesState());

  Future<void> loadPackages() async {
    emit(state.copyWith(isLoading: true));
    _sub?.cancel();

    final stage = await userStageProvider.getStage();

    _sub = getPackagesUseCase(stage).listen(
      (packages) {
        emit(state.copyWith(packages: packages, isLoading: false));
      },
      onError: (e) => emit(
        state.copyWith(errorMessage: e.toString(), isLoading: false),
      ),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
