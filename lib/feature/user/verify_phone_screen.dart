// lib/feature/user/verify_phone_screen.dart
import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/constants/const.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/utils/navigation_manager.dart';
import 'package:chatwave/core/utils/style.dart';
import 'package:chatwave/core/widgets/custom_button.dart';
import 'package:chatwave/feature/user/cubit/auth_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatwave/core/utils/router.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String name;

  const VerifyPhoneScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.name,
  });

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final TextEditingController otpController = TextEditingController();
  final VerifyOtpCubit _verifyOtpCubit = VerifyOtpCubit();

  @override
  void dispose() {
    otpController.dispose();
    _verifyOtpCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<VerifyOtpCubit>.value(
      value: _verifyOtpCubit,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.COMMON_PADDING_FOR_SCREEN,
            vertical: Dimensions.h30,
          ),
          child: BlocConsumer<VerifyOtpCubit, VerifyOtpState>(
            listener: (context, state) {
              if (state is VerifyOtpFailure) {
                // Error toast already shown inside Cubit
              }
            },
            builder: (context, state) {
              final isLoading = state is VerifyOtpLoading;

              return Stack(
                children: [
                  _buildMainContent(theme),
                  if (isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      AppImage.icAppLogo,
                      height: Dimensions.h80,
                      width: Dimensions.w80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                verticalHeight(Dimensions.h16),

                Text(
                  AppString.enterOtp,
                  style: fontStyleBold22.copyWith(color: AppColors.primary),
                ),

                verticalHeight(Dimensions.h10),

                Text(
                  '${AppString.otpSent}${widget.phoneNumber}',
                  style: fontStyleMedium16.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                verticalHeight(Dimensions.h30),

                Pinput(
                  controller: otpController,
                  length: 6,
                  defaultPinTheme: PinTheme(
                    width: Dimensions.w45,
                    height: Dimensions.h45,
                    textStyle: fontStyleBold20.copyWith(
                        color: theme.colorScheme.onSurface),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.primary),
                    ),
                  ),
                ),

                verticalHeight(Dimensions.h30),

                CustomButton(
                  text: stateIsLoading(context)
                      ? 'Verifying...'
                      : AppString.verify,
                  onPressed: stateIsLoading(context) ? null : _onTapVerify,
                  textStyle: fontStyleSemiBold18.copyWith(
                    color: theme.colorScheme.surface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool stateIsLoading(BuildContext context) {
    return _verifyOtpCubit.state is VerifyOtpLoading;
  }

  void _onTapVerify() {
    final otp = otpController.text.trim();
    final verificationId = widget.verificationId;
    final phone = widget.phoneNumber;
    final name = widget.name;

    _verifyOtpCubit.verifyOtp(
      context: context,
      verificationId: verificationId,
      otp: otp,
      onSuccess: () {
        // Nothing else to do here; onUserVerified will navigate.
      },
      onUserVerified: (uid, phoneNumber) async {
        // 1) Save to SharedPreferences:
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('uid', uid);
        await prefs.setString('phoneNumber', phoneNumber);
        await prefs.setString('name', name);

        // 2) Write user data (including name) to Firestore:
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'phoneNumber': phoneNumber,
          'name': name,                // 👈 Store name
          'lastLogin': FieldValue.serverTimestamp(),
          'isLoggedIn': true,
        }, SetOptions(merge: true));

        // 3) Navigate to HomeScreen (remove all previous routes):
        navigateToPageAndRemoveAllPage(context, HOME_ROUTE);
      },
    );
  }
}

