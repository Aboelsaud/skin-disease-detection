import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './home/home.dart';
import './authenticate/authenticate.dart';
import '../models/user.dart';
import '../screens/getStarted.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    //return either home or Authenticate widget
    print("userrrrrrrrrrrrrrrrrrrrrrrrrrr");
    print(user);
    if(user == null){
      return Authenticate();
    }else{
      return Home();
    }
    
  }
}