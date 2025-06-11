import 'package:chatwave/core/constants/app_image.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: theme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(AppImage.icAppLogo),backgroundColor: theme.colorScheme.surface, // Replace with your logo
            ),
            const SizedBox(height: 20),
            Text(
              'ChatWave',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Connecting you with the world.',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              'ChatWave is a cutting-edge messaging app that provides secure, fast, and reliable communication. '
                  'We aim to connect people around the globe with ease and elegance.\n\n'
                  'Our mission is to create a seamless communication experience across all platforms with a focus on user privacy and performance.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            const Spacer(),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              '© 2025 ChatWave Inc.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
