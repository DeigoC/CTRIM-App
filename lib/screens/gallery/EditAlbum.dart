import 'package:flutter/material.dart';

class EditAlbum extends StatefulWidget {
  @override
  _EditAlbumState createState() => _EditAlbumState();
}

class _EditAlbumState extends State<EditAlbum> {
  
  List<Color> _selectedColors = [];
  List<Color> _colorTestData =[
    Colors.red, Colors.blue, Colors.green, Colors.orange
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_,__){
          return[
            SliverAppBar(
              title: Text('Edit Album'),
              actions: [
                FlatButton(
                  child: Text('UPLOAD'),
                  onPressed: () => null,
                ),
              ],
            ),
          ];
        },
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody(){
    List<Widget> children = _colorTestData.map((color) => _buildPictureContainer(color)).toList();
    return ListView(
      children: [
        Wrap(children:children),
      ],
    );
   
  }

  Padding _buildPictureContainer(Color color,){
     double pictureSize = MediaQuery.of(context).size.width * 0.32;
    double paddingSize = MediaQuery.of(context).size.width * 0.01;
    bool selected = _selectedColors.contains(color);
    return Padding(
       padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
       child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: pictureSize,
          height: pictureSize,
          color: color,
          child: InkWell(
            onTap: (){
              setState(() {
                if(selected)_selectedColors.remove(color);
                else _selectedColors.add(color);
              }); 
            },
            child: Opacity(
              opacity: selected ? 1:0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  Icon(Icons.done, color: Colors.white,)
                ],
              ),
            ),
          ),
       ),
    );
  }
}