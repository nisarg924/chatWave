// lib/feature/chat/widgets/typing_indicator.dart

import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/const.dart';
import 'package:flutter/material.dart';
import 'package:chatwave/core/constants/dimensions.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dotOneOpacity;
  late Animation<double> _dotTwoOpacity;
  late Animation<double> _dotThreeOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _dotOneOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)),
    );

    _dotTwoOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8)),
    );

    _dotThreeOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        width: Dimensions.w8,
        height: Dimensions.w8,
        margin: EdgeInsets.symmetric(horizontal: Dimensions.w2),
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.h8,
        horizontal: Dimensions.w12,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: Dimensions.r12,
            backgroundImage:
            const AssetImage(AppImage.icProfileImage), // other’s avatar
          ),
          horizontalWidth(Dimensions.w8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.w8,
              vertical: Dimensions.h4,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildDot(_dotOneOpacity),
                _buildDot(_dotTwoOpacity),
                _buildDot(_dotThreeOpacity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
