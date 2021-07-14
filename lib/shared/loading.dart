import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/5.png"),
          fit: BoxFit.cover
        ),
      ),

      child: Center(
        child: SpinKitChasingDots(
          color: Colors.indigo,
          size: 70,
          duration: Duration(milliseconds: 2000),
        ),
      ),
    );
  }
}
