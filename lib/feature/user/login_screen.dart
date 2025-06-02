import 'package:chatwave/core/utils/navigation_manager.dart';
import 'package:chatwave/feature/user/verify_phone_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/constants/const.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/utils/style.dart';
import 'package:chatwave/core/widgets/coutry_text_field.dart';
import 'package:chatwave/core/widgets/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocus = FocusNode();
  String countryCode = "+91";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.COMMON_PADDING_FOR_SCREEN,
              vertical: Dimensions.h20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo in rounded card
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

                    verticalHeight(16),

                    // App Name
                    Text(
                      AppString.appName,
                      style: fontStyleBold22.copyWith(color: AppColors.primary),
                    ),

                    verticalHeight(10),

                    // Subtitle
                    Text(
                      AppString.loginToYourAccount,
                      textAlign: TextAlign.center,
                      style: fontStyleMedium16.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    verticalHeight(40),

                    // Phone Input
                    CountryCodeTextField(
                      focusNode: phoneFocus,
                      countryCode: countryCode,
                      textController: phoneController,
                      getCountryCode: (nameCode, isd) {
                        setState(() => countryCode = isd);
                      },
                    ),

                    verticalHeight(Dimensions.h30),

                    // Continue Button
                    CustomButton(
                      text: AppString.continue_,
                      onPressed:_sendOtp,
                      textStyle: fontStyleSemiBold18.copyWith(
                        color: theme.colorScheme.surface,
                      ),
                      miniWidth: double.infinity,
                    ),

                    verticalHeight(Dimensions.h10),

                    // Optional: privacy
                    Text(
                      AppString.terms,
                      textAlign: TextAlign.center,
                      style: fontStyleRegular12.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  _sendOtp() async {
    String phoneNumber = "$countryCode${phoneController.text.trim()}";

    if (phoneController.text.isEmpty || phoneController.text.length < 8) {
      Fluttertoast.showToast(msg: AppString.pleaseEnterNumber);
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto-completion
      },
      verificationFailed: (FirebaseAuthException e) {
        Fluttertoast.showToast(msg: "Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        navigateToPage(
          context,
          VerifyPhoneScreen(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

}
