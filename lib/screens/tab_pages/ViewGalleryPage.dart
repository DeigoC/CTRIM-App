import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewGalleryPage{

  final BuildContext _context;
  final TabController _tabController;
  final List<Tab> _myTabs =[
    Tab(text: 'Timeline',),
    Tab(text: 'Albums',)
  ];

  double pictureSize, paddingSize;

  ViewGalleryPage(this._context, this._tabController);

  Widget buildAppBar(){
    return AppBar(
      title: TabBar(
        controller: _tabController,
        tabs: _myTabs,
      ),
    );
  }

  Widget buildBody(){
    return TabBarView(
      controller: _tabController,
      children: [
        _timelineView(),
        _ablumView(),
      ],
    );
  }

  Widget _timelineView(){
    return OrientationBuilder(
      builder:(_,orientation){
        pictureSize = pictureSize = MediaQuery.of(_context).size.width * 0.32;
        paddingSize = MediaQuery.of(_context).size.width * 0.01;
        if(orientation == Orientation.landscape){
          // * 4 blocks accross so 5 paddings accross
          pictureSize = MediaQuery.of(_context).size.width * 0.2375;
          paddingSize = MediaQuery.of(_context).size.width * 0.01;
        }
        return ListView(
          key: PageStorageKey<String>('TimlineTab'),
          children: [
             SizedBox(height: 16,),
             _examplePictures1(),
             SizedBox(height: 16,),
            _examplePictures1(),
              SizedBox(height: 16,),
            _examplePictures1(),
              SizedBox(height: 16,),
            _examplePictures1(),
          ],
        );
      } 
    );
  }

  Column _examplePictures1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(' 23 May 2020', style: TextStyle(fontSize: 28),),
        SizedBox(height: 16,),
        Wrap(
            children: [
              Padding(
                padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: pictureSize,
                  height: pictureSize,
                  color: Colors.red,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: pictureSize,
                  height: pictureSize,
                  color: Colors.green,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: pictureSize,
                  height: pictureSize,
                  color: Colors.purple,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: pictureSize,
                  height: pictureSize,
                  color: Colors.yellow,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: pictureSize,
                  height: pictureSize,
                  color: Colors.black,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _ablumView(){
    double portSize = MediaQuery.of(_context).size.width * 0.40;
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: GridView.count(
        key: PageStorageKey<String>('AlbumTab'),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: portSize,
                height: portSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8,),
              Container( width: portSize,child: Text("Youth Day out at London Bridge this is going too far!", overflow: TextOverflow.ellipsis,)),
              Text('8'),
            ],
          ),

          Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: portSize,
                height: portSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 8,),
              Container( width: portSize,child: Text("Youth Day out at London Bridge this is going too far!", overflow: TextOverflow.ellipsis,)),
              Text('8'),
            ],
          ),

          Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: portSize,
                height: portSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8,),
              Container( width: portSize,child: Text("Youth Day out at London Bridge this is going too far!", overflow: TextOverflow.ellipsis,)),
              Text('8'),
            ],
          ),

        ],
      ),
    );
  }

}