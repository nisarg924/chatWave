// lib/feature/call/call_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

/// Define call-related states
abstract class CallState {}

class CallIdle extends CallState {}

class CallInviting extends CallState {
  final String callID;
  final bool isVideo;
  CallInviting({required this.callID, required this.isVideo});
}

class CallError extends CallState {
  final String error;
  CallError(this.error);
}

/// Cubit to manage call invitation state
class CallCubit extends Cubit<CallState> {
  CallCubit() : super(CallIdle());

  void startCall({required String callID, required bool isVideo}) {
    emit(CallInviting(callID: callID, isVideo: isVideo));
  }

  void showError(String message) {
    emit(CallError(message));
  }

  void reset() {
    emit(CallIdle());
  }
}
