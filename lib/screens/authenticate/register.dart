import 'package:flutter/material.dart';
import 'package:image_gp/animation/FadeAnimation.dart';
import 'package:image_gp/services/auth.dart';
import 'package:image_gp/shared/constants.dart';
import 'package:image_gp/shared/loading.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register(this.toggleView);
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  final _email = TextEditingController();
  final _password = TextEditingController();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Color(0xff21254A),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 300,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                              child: FadeAnimation(
                            1,
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage("assets/4-1.png"),
                                ),
                              ),
                            ),
                          ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FadeAnimation(
                            1,
                            Text(
                              "Register, \nwelcome back",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          FadeAnimation(
                            1,
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.transparent,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[100],
                                        ),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _email,
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Email",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[100],
                                        ),
                                      ),
                                    ),
                                    child: TextField(
                                      obscureText: true,
                                      controller: _password,
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Password",
                                          hintStyle:
                                              TextStyle(color: Colors.grey)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          FadeAnimation(
                            1,
                            Container(
                              height: 50,
                              margin: EdgeInsets.symmetric(horizontal: 60),
                              child: SizedBox(
                                width: 500,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  color: Color.fromRGBO(49, 39, 79, 1),
                                  textColor: Colors.white,
                                  child: Text(
                                    'Register',
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      setState(() {
                                        loading = true;
                                      });
                                      email = _email.text;
                                      password = _password.text;
                                      print(email);
                                      print(password);
                                      dynamic result = await _auth
                                          .registerWithEmailAndPassword(
                                              email, password);
                                      if (password.length<6){
                                        setState(() {
                                          error =
                                              'Couldnt Register please enter a password with more than 6 digits';
                                          loading = false;
                                        });
                                      }
                                      else if (result == null) {
                                        setState(() {
                                          error =
                                              'Couldnt Register please enter your email and password correctly';
                                          loading = false;
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          FadeAnimation(
                            1,
                            Center(
                              child: FlatButton(
                                child: Text("sign in"),
                                onPressed: () {
                                  widget.toggleView();
                                },
                                color: Colors.transparent,
                                textColor: Colors.pink[200],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            error,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
