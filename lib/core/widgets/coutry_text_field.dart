import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/services/startup_service.dart';
import 'package:chatwave/core/utils/logger_util.dart';
import 'package:chatwave/core/utils/style.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class CountryCodeTextField extends StatefulWidget {
  final inputFormatters;
  String? countryCode;
  String? isdCode;
  final String? title;
  final TextEditingController? textController;
  final Color? hintTextColor;
  final FocusNode? focusNode;
  ValueChanged? onChanged;
  ValueChanged? onFieldSubmit;
  FormFieldValidator? validator;
  final String? hintText;
  Function getCountryCode;

  CountryCodeTextField({
    this.inputFormatters,
    this.focusNode,
    this.isdCode,
    this.countryCode,
    this.title,
    this.validator,
    this.textController,
    this.onFieldSubmit,
    this.hintTextColor,
    this.onChanged,
    this.hintText,
    required this.getCountryCode,
  });

  @override
  State<CountryCodeTextField> createState() => _CountryCodeTextFieldState();
}

class _CountryCodeTextFieldState extends State<CountryCodeTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.h50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(Dimensions.r10),
        ),
        color: AppColors.backgroundLight,
        border: Border.all(
          color: AppColors.borderColor,
        ),
      ),
      child: Row(
        children: [
          CountryCodePicker(
            onChanged: (e) {
              logger.e(e.name);
              logger.e(e.code);
              logger.e(e.dialCode);
              logger.e(e.flagUri);
              StartupService.setCountryCode(e.code!);
              StartupService.setIsdCode(e.dialCode!);
              widget.getCountryCode(e.code, e.dialCode);
            },
            initialSelection: widget.countryCode ?? "+968",
            textStyle: fontStyleMedium15,
            // favorite: const [],
            showCountryOnly: false,
            dialogSize: Size(MediaQuery.of(context).size.width - 50,
                MediaQuery.of(context).size.height - 250),
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
          ),
          SizedBox(
            width: Dimensions.w1,
          ),
          Container(
            width: 1,
            height: 20,
            color: AppColors.borderColor,
          ),
          SizedBox(
            width: Dimensions.w10,
          ),
          Expanded(
            child: TextFormField(
              focusNode: widget.focusNode,
              style: fontStyleMedium15,
              textAlignVertical: TextAlignVertical.center,
              onFieldSubmitted: widget.onFieldSubmit,
              controller: widget.textController,
              inputFormatters: widget.inputFormatters,
              cursorColor: Theme.of(context).colorScheme.onSurface,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
                fillColor: Colors.transparent,
                filled: true,
                hintText: widget.hintText ?? "Enter Phone Number",
                hintStyle:
                fontStyleLight15.apply(color: Theme.of(context).hintColor),
              ),
              onChanged: (val) {
                if (widget.onChanged != null) {
                  widget.onChanged!(val);
                }
              },
              onSaved: (value) {
                value = widget.textController!.text;
              },
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      ),
    );
  }
}
