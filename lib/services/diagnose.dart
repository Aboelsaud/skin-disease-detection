import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
class Diagnose extends StatelessWidget {

  var regonisions;
  File image;
  Diagnose(this.regonisions);
  @override
  Widget build(BuildContext context) {
    int size=regonisions['_recognitions'].length;
    image=File.fromUri(Uri.file(regonisions['image']));
    return Card(
      color: Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.file(
                    image,
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(regonisions['_recognitions'][0]['confidence'].toString()),
                      Text(
                        " ===> ",
                      ),
                      Text(regonisions['_recognitions'][0]['label'],style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  size>1? Row(
                    children: <Widget>[
                      Text(regonisions['_recognitions'][1]['confidence'].toString()),
                      Text(
                        " ===> ",
                      ),
                      Text(regonisions['_recognitions'][1]['label'],style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ):Text(""),
                  size>2?Row(
                    children: <Widget>[
                      Text(regonisions['_recognitions'][2]['confidence'].toString()),
                      Text(
                        " ===> ",
                      ),
                      Text(regonisions['_recognitions'][2]['label'],style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ):Text(""),
                ],
              ),
            )
          ],
        ),
      );
  }
}