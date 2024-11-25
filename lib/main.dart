import 'package:flutter/material.dart';
import 'package:image_labeling_mobilenet_model/home_veiw.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeVeiw(),
    );
  }
}
