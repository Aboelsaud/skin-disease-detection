import 'package:flutter/material.dart';
import 'package:image_gp/screens/Diagnoses.dart';
import 'package:image_gp/services/auth.dart';
import './screens/wrapper.dart';
import 'package:provider/provider.dart';
import './models/user.dart';
import './screens/home/home.dart';
import './screens/getStarted.dart';
import './shared/loading.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'Flutter App',
        home: (GetStarted()),
        routes: {
          '/Diagnoses':(ctx)=>Diagnoses(),
          '/wraper':(ctx)=>Wrapper(),
          'getStarted':(ctx)=>GetStarted()
        },
        onUnknownRoute: (settings){
        return MaterialPageRoute(builder: (ctx) => (Home()));
      },
      ),
    );
  }
}
