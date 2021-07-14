import 'package:flutter/material.dart';

class GetStarted extends StatelessWidget {
  void homepage(BuildContext context) {
    Navigator.of(context).pushNamed('/wraper');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/5.png"),
            ),
          ),
        ),
        Positioned(
          bottom: 250,
          left: 115,
          child: Container(
            width: 200,
            height: 50,
            child: FlatButton(
              onPressed: (){homepage(context);},
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Color.fromRGBO(164, 123, 205, 50), style: BorderStyle.solid,width: 3),
                  borderRadius: BorderRadius.circular(25)),
              child: Text(
                "Get Started",
                style: TextStyle(color: Colors.white,fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
