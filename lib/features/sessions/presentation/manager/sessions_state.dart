import 'package:equatable/equatable.dart';
import 'package:alaref/features/sessions/data/models/session_model.dart';

class SessionsState extends Equatable {
  final List<SessionModel> sessions;
  final bool isLoading;
  final String? errorMessage;

  const SessionsState({
    this.sessions = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  SessionsState copyWith({
    List<SessionModel>? sessions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SessionsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [sessions, isLoading, errorMessage];
}
