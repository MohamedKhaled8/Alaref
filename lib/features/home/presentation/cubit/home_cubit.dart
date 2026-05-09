import 'package:alaref/core/utils/services/user_stage_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:flutter/material.dart';

class HomeState extends Equatable {
  final int visibleSections;
  final bool isLoading;
  final String? errorMessage;
  final int selectedMenuIndex;
  final String userName;
  final String studentCode;

  const HomeState({
    this.visibleSections = 0,
    this.isLoading = true,
    this.errorMessage,
    this.selectedMenuIndex = -1,
    this.userName = '',
    this.studentCode = '',
  });

  HomeState copyWith({
    int? visibleSections,
    bool? isLoading,
    String? errorMessage,
    int? selectedMenuIndex,
    String? userName,
    String? studentCode,
  }) {
    return HomeState(
      visibleSections: visibleSections ?? this.visibleSections,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMenuIndex: selectedMenuIndex ?? this.selectedMenuIndex,
      userName: userName ?? this.userName,
      studentCode: studentCode ?? this.studentCode,
    );
  }

  @override
  List<Object?> get props => [
    visibleSections,
    isLoading,
    errorMessage,
    selectedMenuIndex,
    userName,
    studentCode,
  ];
}

class HomeCubit extends Cubit<HomeState> {
  final UserStageProvider userStageProvider;
  final GlobalKey<SideMenuState> sideMenuKey = GlobalKey<SideMenuState>();

  HomeCubit({required this.userStageProvider}) : super(const HomeState());

  void toggleMenu() {
    final currentState = sideMenuKey.currentState;
    if (currentState != null) {
      if (currentState.isOpened) {
        currentState.closeSideMenu();
      } else {
        currentState.openSideMenu();
      }
    }
  }

  Future<void> loadUserData() async {
    final name = await userStageProvider.getName();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final code = uid.length >= 8 ? uid.substring(0, 8).toUpperCase() : uid;

    emit(state.copyWith(
      userName: name,
      studentCode: code,
    ));
  }

  String get greeting {
    final h = DateTime.now().hour;
    final name = state.userName.isNotEmpty ? state.userName.split(' ').first : 'بطلنا';
    if (h < 12) return 'صباح النور يا $name';
    if (h < 17) return 'مساء النور يا $name';
    return 'مساء الخير يا $name';
  }

  void updateSelectedMenuIndex(int index) {
    emit(state.copyWith(selectedMenuIndex: index));
  }

  void startEntranceAnimation() {
    loadUserData();
    emit(state.copyWith(visibleSections: 10, isLoading: false));
  }
}
