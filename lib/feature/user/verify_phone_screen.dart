import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/utils/style.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const VerifyPhoneScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isVerifying = false;

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      Fluttertoast.showToast(msg: AppString.enter6DigitOtp);
      return;
    }

    setState(() => isVerifying = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        Fluttertoast.showToast(msg: AppString.otpVerified);
        // Navigate to home or main screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: "OTP verification failed: ${e.message}");
    } finally {
      setState(() => isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Phone")),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.COMMON_PADDING_FOR_SCREEN,
          vertical: Dimensions.h30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "OTP sent to ${widget.phoneNumber}",
              style: fontStyleMedium16.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),

            Pinput(
              controller: otpController,
              length: 6,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 56,
                textStyle: const TextStyle(fontSize: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.primary),
                ),
              ),
              onCompleted: (value) => _verifyOtp(),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: isVerifying ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                isVerifying ? "Verifying..." : "Verify OTP",
                style: fontStyleSemiBold18.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
