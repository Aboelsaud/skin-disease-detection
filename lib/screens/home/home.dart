import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_gp/services/auth.dart';
import 'package:image_gp/services/mainDrawer.dart';
import 'package:image_gp/services/tabs_screen.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

const String ssd = "lkj";
const String yolo = "lkj";
const String deeplab = "lkj";
const String posenet = "lkj";
const String general = "General";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  FirebaseUser mCurrentUser;
  FirebaseAuth _auth2 = FirebaseAuth.instance;
  final db = Firestore.instance;
  String email;
  int check = 0;
  File _image;
  List _recognitions;
  String _model = "Cancer";
  double _imageHeight;
  double _imageWidth;
  bool _busy = false;
  bool _load = false;
  final ImagePicker _picker=ImagePicker();

  Future _getCurrentUser() async {
    mCurrentUser = await _auth2.currentUser();
    if (check == 0) {
      setState(() {
        email = mCurrentUser.email;
        check += 1;
      });
    }
  }

  Future _saveData() async {
    try {
      await db.collection('user').document(email).collection("Diagnoses").add({
        'image': _image.path,
        'date': DateTime.now(),
        '_recognitions': _recognitions
      });
      await db.collection('user').document(email).setData({'id': email});
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Checking:",style: TextStyle(color: Colors.white),),
            content: Text("Saved",style: TextStyle(color: Colors.white)),
            actions: <Widget>[
              FlatButton(child: Text("Ok",style: TextStyle(color: Colors.white)),onPressed: (){Navigator.of(context).pop();},),
            ],
            elevation: 24.0,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          );
        },
      );
    }catch(e){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Checking:",style: TextStyle(color: Colors.white),),
            content: Text("Not saved please try again",style: TextStyle(color: Colors.white)),
            actions: <Widget>[
              FlatButton(child: Text("Ok",style: TextStyle(color: Colors.white),),onPressed: (){Navigator.of(context).pop();},),
            ],
            elevation: 24.0,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          );
        },
      );
    }
  }

  Future predictImagePicker(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image == null) return;
    setState(() {
      _load = true;
      _busy = true;
    });
    predictImage(image);
  }

  Future predictImage(File image) async {
    if (image == null) return;

    switch (_model) {
      case yolo:
        await yolov2Tiny(image);
        break;
      case ssd:
        await ssdMobileNet(image);
        break;
      case deeplab:
        await segmentMobileNet(image);
        break;
      case posenet:
        await poseNet(image);
        break;
      default:
        await recognizeImage(image);
      // await recognizeImageBinary(image);
    }

    new FileImage(image)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));

    setState(() {
      _image = image;
      _busy = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res;
      switch (_model) {
        case general:
          res = await Tflite.loadModel(
            model: "assets/converted_model2.tflite",
            
            labels: "assets/converted_model2.txt",
          );
          break;
        default:
          res = await Tflite.loadModel(
            model: "assets/converted_model.tflite",
            labels: "assets/converted_model.txt",
          );
      }
      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Uint8List imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = img.getRed(pixel);
        buffer[pixelIndex++] = img.getGreen(pixel);
        buffer[pixelIndex++] = img.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Future recognizeImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions;
    });
  }

  Future recognizeImageBinary(File image) async {
    var imageBytes = (await rootBundle.load(image.path)).buffer;
    img.Image oriImage = img.decodeJpg(imageBytes.asUint8List());
    img.Image resizedImage = img.copyResize(oriImage, height: 224, width: 224);
    var recognitions = await Tflite.runModelOnBinary(
      binary: imageToByteListFloat32(resizedImage, 224, 127.5, 127.5),
      numResults: 6,
      threshold: 0.05,
    );
    setState(() {
      _recognitions = recognitions;
    });
  }

  Future yolov2Tiny(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      model: "YOLO",
      threshold: 0.3,
      imageMean: 0.0,
      imageStd: 255.0,
      numResultsPerClass: 1,
    );
    setState(() {
      _recognitions = recognitions;
    });
  }

  Future ssdMobileNet(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      numResultsPerClass: 1,
    );
    setState(() {
      _recognitions = recognitions;
    });
  }

  Future segmentMobileNet(File image) async {
    var recognitions = await Tflite.runSegmentationOnImage(
      path: image.path,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _recognitions = recognitions;
    });
  }

  Future poseNet(File image) async {
    var recognitions = await Tflite.runPoseNetOnImage(
      path: image.path,
      numResults: 2,
    );

    print(recognitions);

    setState(() {
      _recognitions = recognitions;
    });
  }

  onSelect(model) async {
    setState(() {
      _busy = true;
      _model = model;
      _recognitions = null;
      _image=null;
    });
    await loadModel();

    if (_image != null)
      predictImage(_image);
    else
      setState(() {
        _busy = false;
      });
  }

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;
    Color blue = Color.fromRGBO(37, 213, 253, 1.0);
    return _recognitions.map((re) {
      return Positioned(
        left: re["rect"]["x"] * factorX,
        top: re["rect"]["y"] * factorY,
        width: re["rect"]["w"] * factorX,
        height: re["rect"]["h"] * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            border: Border.all(
              color: blue,
              width: 2,
            ),
          ),
          child: Text(
            "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = blue,
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> renderKeypoints(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    var lists = <Widget>[];
    _recognitions.forEach((re) {
      var color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(1.0);
      var list = re["keypoints"].values.map<Widget>((k) {
        return Positioned(
          left: k["x"] * factorX - 6,
          top: k["y"] * factorY - 6,
          width: 100,
          height: 12,
          child: Text(
            "● ${k["part"]}",
            style: TextStyle(
              color: color,
              fontSize: 12.0,
            ),
          ),
        );
      }).toList();

      lists..addAll(list);
    });

    return lists;
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentUser();
    print(email);
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    if (_model == deeplab && _recognitions != null) {
      stackChildren.add(Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        child: _image == null
            ? Text('No image selected.')
            : Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        alignment: Alignment.topCenter,
                        image: MemoryImage(_recognitions),
                        fit: BoxFit.fill)),
                child: Opacity(opacity: 0.3, child: Image.file(_image))),
      ));
    } else {
      stackChildren.add(_image==null ?Positioned(
        top: size.height/2.5,
        left: 130,
        width: size.width,
        child: _image == null ? Text(
          'Please select an image.',
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Color(0xff21254A)),
          ) : Image.file(_image),
      ):Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        child:Image.file(_image),
      ));
    }

    if (_model == "Cancer" || _model == "General") {
      stackChildren.add(Center(
        child: Column(
          children: _recognitions != null
              ? _recognitions.map((res) {
                  return Text(
                    "${res["label"]}: ${res["confidence"].toStringAsFixed(3)}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      background: Paint()..color = Colors.white,
                    ),
                  );
                }).toList()
              : [],
        ),
      ));
    } else if (_model == ssd || _model == yolo) {
      stackChildren.addAll(renderBoxes(size));
    } else if (_model == posenet) {
      stackChildren.addAll(renderKeypoints(size));
    }

    if (_busy) {
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MainDrawer(email),
      appBar: AppBar(
        title: const Text('Skinny'),
        backgroundColor: Color(0xff21254A),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: onSelect,
            itemBuilder: (context) {
              List<PopupMenuEntry<String>> menuEntries = [
                const PopupMenuItem<String>(
                  child: Text("Cancer"),
                  value: "Cancer",
                ),
                const PopupMenuItem<String>(
                  child: Text("General"),
                  value: "General",
                ),
              ];
              return menuEntries;
            },
          ),
          FlatButton.icon(
            icon: Icon(Icons.person,color: Colors.white70),
            onPressed: () async {
              await _auth.signOut();
            },
            label: Text('logout',style: TextStyle(color: Colors.white70),),
          )
        ],
      ),
      body: Stack(
        children: stackChildren,
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _saveData,
        tooltip: 'Pick Image',
        child: Icon(Icons.save),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xff21254A),
      ),
      bottomNavigationBar: TabsScreen(predictImagePicker),
    );
  }
}
