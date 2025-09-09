

import 'package:flutter/material.dart';

class HeaderWidgets extends StatelessWidget {
  const HeaderWidgets ({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of (context).size.width,
      height: MediaQuery.of (context).size.height *8.20,
      child: Stack(children: [
        Image.asset('assets/icons/searchBanner.jpeg',
      width: MediaQuery.of (context).size.width,
      fit: BoxFit.cover,
      ),

      Positioned(
        child: SizedBox(
          width: 250,
          height: 50,
          child: TextField()), 
      ),
      ],
      ),
    );
  }
}