import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewGalleryPage{

  final BuildContext _context;
  final TabController _tabController;
  final List<Tab> _myTabs =[
    Tab(text: 'Timeline',),
    Tab(text: 'Albums',)
  ];

  final Map<String,String> images = {
    'https://i.ytimg.com/vi/mwux1_CNdxU/maxresdefault.jpg':'img',
    'https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fstatic.onecms.io%2Fwp-content%2Fuploads%2Fsites%2F38%2F2016%2F05%2F12214218%2Fsimple_bites_family_backyard.jpg&q=85':'img',
    'https://www.lakedistrict.gov.uk/__data/assets/image/0018/123390/families-and-children.jpg':'img',
    'https://rmstitanichotel.co.uk/wp-content/uploads/2016/07/Family-1024x683.jpg':'img',
    'https://specials-images.forbesimg.com/imageserve/5e90c5cd5f21d30007e5ab66/960x0.jpg?fit=scale':'img',
    'https://firebasestorage.googleapis.com/v0/b/ctrim---demo.appspot.com/o/videoExample3.mp4?alt=media&token=a42812a2-9e01-4f29-903b-e9b814cfae02' : 'vid',
  };

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
             _examplePictures2(),
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

   Column _examplePictures2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(' 23 May 2020', style: TextStyle(fontSize: 28),),
        SizedBox(height: 16,),
        Wrap(
            children: images.keys.map((src){
              if(images[src].compareTo('vid')==0){
                return _createVideoContainer(src);
              }
              return _createImageContainer(src);
            }).toList(),
          ),
      ],
    );
  }

  Padding _createImageContainer(String src){
    return Padding(
      padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: pictureSize,
        height: pictureSize,
        child: GestureDetector(
          onTap: (){
            int pos = images.keys.toList().indexOf(src);
            BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPage(images, pos));
          },
          child: Hero(
            tag: src,
            child: Image.network(src, fit: BoxFit.cover,),
          ),
        ),
      ),
    );
  }

  Padding _createVideoContainer(String src){
     return Padding(
      padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
      child:  GestureDetector(
        onTap: (){
          int pos = images.keys.toList().indexOf(src);
          BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPage(images, pos));
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: pictureSize,
          height: pictureSize,
          child:Icon(Icons.play_circle_filled, color: Colors.black,size: 60,),
          ),
      )
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