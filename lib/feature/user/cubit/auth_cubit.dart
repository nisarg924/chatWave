import 'dart:developer';

import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/utils/navigation_manager.dart';
import 'package:chatwave/feature/user/verify_phone_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chatwave/core/constants/const.dart';

abstract class SendOtpState {}

class SendOtpInitial extends SendOtpState {}

class SendOtpLoading extends SendOtpState {}

class SendOtpSuccess extends SendOtpState {}

class SendOtpFailure extends SendOtpState {
  final String error;

  SendOtpFailure(this.error);
}
// lib/feature/user/cubit/send_otp_cubit.dart;

class SendOtpCubit extends Cubit<SendOtpState> {
  SendOtpCubit() : super(SendOtpInitial());

  Future<void> sendOtp(BuildContext context, String phoneNumber) async {
    emit(SendOtpLoading());

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto‐verification callbacks (Android) – we’re not handling that here.
      },
      verificationFailed: (FirebaseAuthException e) {
        emit(SendOtpFailure(e.message ?? 'Verification failed'));
        Fluttertoast.showToast(msg: 'Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) async {
        emit(SendOtpSuccess());
        // Navigate to VerifyPhoneScreen, passing the verificationId:
        await navigateToPage(
          context,
          VerifyPhoneScreen(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto retrieval timed out
      },
    );
  }
}


// verify_otp_state.dart
abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpLoading extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {}

class VerifyOtpFailure extends VerifyOtpState {
  final String message;
  VerifyOtpFailure(this.message);
}

// lib/feature/user/cubit/verify_otp_cubit.dart

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  VerifyOtpCubit() : super(VerifyOtpInitial());

  Future<void> verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String otp,
    required VoidCallback onSuccess,
    required Function(String uid, String phoneNumber) onUserVerified,
  }) async {
    if (otp.length != 6) {
      Fluttertoast.showToast(msg: 'Please enter a valid 6‐digit OTP');
      return;
    }

    emit(VerifyOtpLoading());

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        emit(VerifyOtpSuccess());
        Fluttertoast.showToast(msg: 'OTP Verified');
        // Pass back the UID + phoneNumber so screen can write to Firestore & SharedPrefs:
        onUserVerified(user.uid, user.phoneNumber ?? '');
        onSuccess();
      }
    } on FirebaseAuthException catch (e) {
      emit(VerifyOtpFailure(e.message ?? 'OTP verification failed'));
      Fluttertoast.showToast(msg: 'OTP verification failed: ${e.message}');
    }
  }
}
