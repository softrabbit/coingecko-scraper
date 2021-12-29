import 'package:flutter/material.dart';
import 'ui/theme.dart';
import 'ui/screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoinGecko Scraper',
      theme: appTheme(),
      home: const MyHomePage(title: 'CoinGecko Scraper'),
    );
  }
}
