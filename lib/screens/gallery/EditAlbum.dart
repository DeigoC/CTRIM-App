import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditAlbum extends StatefulWidget {
  @override
  _EditAlbumState createState() => _EditAlbumState();
}

class _EditAlbumState extends State<EditAlbum> {
  
  List<Color> _selectedColors = [];
  List<Color> _colorTestData =[
    Colors.red, Colors.blue, Colors.green, Colors.orange
  ];

  bool _onDeleteMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _onDeleteMode ? _buildDeleteActions() : _buildNormalActions(),
      ),
     body: _buildBody(),
     floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
     floatingActionButton: _onDeleteMode ? _buildDeleteButton(): null,
    );
  }

  List<Widget> _buildNormalActions(){
    return [
      FlatButton(
            child: Text('Remove'),
            onPressed: () {
              setState(() {_onDeleteMode = true; });
            },
          ),
          FlatButton(
            child: Text('Add'),
            onPressed: () => BlocProvider.of<AppBloc>(context).add(ToAddGalleryFile()),
          ),
    ];
  }

  List<Widget> _buildDeleteActions(){
    return [
      FlatButton(
        child: Text('Cancel'),
        onPressed: () {
          setState(() {
            _onDeleteMode = false;
            _selectedColors = [];
          });
        },
      ),
    ];
  }

  Widget _buildDeleteButton(){
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: RaisedButton(
        child: Text('Delete ${_selectedColors.length} items'),
        onPressed: (){

        },
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
              if(_onDeleteMode){
                setState(() {
                if(selected)_selectedColors.remove(color);
                else _selectedColors.add(color);
              }); 
              }
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