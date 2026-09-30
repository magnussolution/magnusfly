import 'package:flutter/material.dart';

void main() {
  runApp(const MagnusFlyApp());
}

class MagnusFlyApp extends StatelessWidget {
  const MagnusFlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MagnusFly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('MagnusFly'),
        ),
      ),
    );
  }
}
