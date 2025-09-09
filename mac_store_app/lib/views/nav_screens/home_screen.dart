

import 'package:flutter/material.dart';
import 'package:mac_store_app/views/nav_screens/widgets/header_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          HeaderWidgets(),
        ],
      ),
      );
  }
}