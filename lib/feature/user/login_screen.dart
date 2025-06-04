// lib/feature/user/login_screen.dart
import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/constants/const.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/utils/style.dart';
import 'package:chatwave/core/widgets/coutry_text_field.dart';
import 'package:chatwave/core/widgets/custom_button.dart';
import 'package:chatwave/core/widgets/custom_text_field.dart';
import 'package:chatwave/feature/user/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  String countryCode = "+91";

  final SendOtpCubit _sendOtpCubit = SendOtpCubit();

  @override
  void dispose() {
    _sendOtpCubit.close();
    phoneController.dispose();
    nameController.dispose();
    phoneFocus.dispose();
    nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SendOtpCubit>.value(
      value: _sendOtpCubit,
      child: Scaffold(
        body: BlocConsumer<SendOtpCubit, SendOtpState>(
          listener: (context, state) {
            if (state is SendOtpFailure) {
              Fluttertoast.showToast(msg: state.error);
            }
          },
          builder: (context, state) {
            final isLoading = state is SendOtpLoading;

            return Stack(
              children: [
                _buildMainContent(context),
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
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (ctx, constraints) {
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
                  // Logo
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

                  verticalHeight(Dimensions.h20),

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

                  // Name Input
                  CustomTextField(
                    hintText: AppString.enterYourName,
                    controller: nameController,
                    focusNode: nameFocus,
                    inputType: TextInputType.name,
                  ),

                  verticalHeight(Dimensions.h20),

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
                    onPressed: () => _sendOtp(),
                    textStyle: fontStyleSemiBold18.copyWith(
                      color: theme.colorScheme.surface,
                    ),
                    miniWidth: double.infinity,
                  ),

                  verticalHeight(Dimensions.h10),

                  // Privacy / Terms
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
    );
  }

  void _sendOtp() {
    final rawPhone = phoneController.text.trim();
    final phoneNumber = "$countryCode$rawPhone";
    final name = nameController.text.trim();

    if (name.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your name",
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    if (rawPhone.isEmpty || rawPhone.length < 8) {
      Fluttertoast.showToast(
        msg: AppString.pleaseEnterNumber,
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    _sendOtpCubit.sendOtp(context, phoneNumber, name);
  }
}
