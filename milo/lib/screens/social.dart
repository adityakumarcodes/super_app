import 'package:flutter/material.dart';
import 'package:milo/atoms/my_app_bar.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Social'),
      body: Center(child: Text('Social')),
    );
  }
}
