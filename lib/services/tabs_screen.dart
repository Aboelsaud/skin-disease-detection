import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TabsScreen extends StatefulWidget {
  final Function imagePicker;
  TabsScreen(this.imagePicker);
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Widget> _pages ;
  int selectedPageIndex = 0;
  @override
  void initState() {
    _pages=[

  ];
    super.initState();
  }
  void _selectPage(int index){
    setState(() {
      selectedPageIndex = index;
      if(index==0){
        widget.imagePicker(ImageSource.gallery);
      }
      else if(index==1){
        widget.imagePicker(ImageSource.camera);
      }
      
    });
  }
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Color(0xff21254A),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
        currentIndex: selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            title: Text('Pick Image'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            title: Text('Camera'),
          ),
        ],
      );
  }
}
