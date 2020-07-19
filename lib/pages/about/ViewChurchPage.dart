import 'dart:async';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/locationDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/userDBManager.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ViewChurchPage extends StatefulWidget {
  final AboutArticle _aboutArticle;
  ViewChurchPage(this._aboutArticle);
  @override
  _ViewChurchPageState createState() => _ViewChurchPageState();
}

class _ViewChurchPageState extends State<ViewChurchPage> {
  
  final PageController _pageController = PageController();

  @override
  void initState() {
    _animateSlideShow();
    super.initState();
  }

  Future<Null> _animateSlideShow() async{
    await Future.delayed(Duration(seconds: 6,),(){
      try{
        if(mounted){
          if(_pageController.page < 4){
            _pageController.animateToPage(_pageController.page.round() + 1, duration: Duration(seconds: 1), curve: Curves.easeInOut);
            _animateSlideShow();
          }
        }
      }catch(e){print('-------------SLIDE SHOW ERROR: ' + e.toString());}
    });
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._aboutArticle.title + ' Church'),centerTitle: true,),
      body: _buildBody(),
    );
  }

  Widget _buildBody(){
    TextStyle headerStyle = TextStyle(fontSize: 36);
    TextStyle bodyStyle = TextStyle(fontSize: 18);
    User pastorUser = UserDBManager.allUsers
    .firstWhere((e) => e.id.compareTo(widget._aboutArticle.locationPastorUID)==0);
    Location location = LocationDBManager.allLocations
    .firstWhere((e) => e.id.compareTo(widget._aboutArticle.locationID)==0);

    return ListView(
      children: [
        _buildGallerySlideShow(),
        SizedBox(height: 16,),

        Text('Location',style: headerStyle, textAlign: TextAlign.center,),
        FlatButton(
          child: Text(location.addressLine,textAlign: TextAlign.center,style: bodyStyle,),
          onPressed: (){
            BlocProvider.of<AppBloc>(context).add(AppToViewLocationOnMapEvent(location));
          },
        ),
        SizedBox(height: 32,),

        Text('Service Times',style: headerStyle,textAlign: TextAlign.center,),
        Text(widget._aboutArticle.serviceTime, textAlign: TextAlign.center,style: bodyStyle,),
        SizedBox(height: 32,),

       Text('Location Pastor',style: headerStyle,textAlign: TextAlign.center,),
        FlatButton(
          child: Text(pastorUser.forename + ' ' + pastorUser.surname,style: bodyStyle,),
          onPressed: (){
            BlocProvider.of<AppBloc>(context).add(AppToViewUserPageEvent(pastorUser));
          },
        ),

        AspectRatio(
          aspectRatio: 16/9,
          child: GestureDetector(
            onTap: (){
              BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPageEvent({
                widget._aboutArticle.secondImage:ImageTag(
                  src: widget._aboutArticle.secondImage,
                  type: 'img'
                )
              }, 0));
            },
            child: Hero(
              tag: '0/'+widget._aboutArticle.secondImage,
              child: Image.network(widget._aboutArticle.secondImage,)
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Get To Know Them',style: TextStyle(fontSize: 20),),
              onPressed: ()=>BlocProvider.of<AppBloc>(context).add(AppToViewPastorEvent(widget._aboutArticle)),
            ),
          ],
        ),
        SizedBox(height: 16,),


        Text("We're on social. Follow us",style: headerStyle,textAlign: TextAlign.center,),
        _buildSocialLinksWidget(),
        SizedBox(height: 32,),
      ],
    );
  }

  Widget _buildGallerySlideShow(){
    Map<String,ImageTag> gallery = {};
    widget._aboutArticle.imageSrcList.forEach((src) {
      gallery[src] = ImageTag(
        src: src,
        type: 'img'
      );
    });

    return AspectRatio(
      aspectRatio: 16/9,
      child:PageView.builder(
        controller: _pageController,
        itemCount: widget._aboutArticle.imageSrcList.length,
        itemBuilder: (_,index){
          return GestureDetector(
            onTap: (){
              BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPageEvent(gallery, index));
            },
            child: Hero(
              tag: gallery[widget._aboutArticle.imageSrcList[index]].heroTag,
              child: Image.network(widget._aboutArticle.imageSrcList[index], fit: BoxFit.cover,)
            )
          );
        }
      ),
    );
  }

  Widget _buildSocialLinksWidget(){
    return Align(
      alignment: Alignment.center,
      child: Wrap(
        spacing: 4,
        children: widget._aboutArticle.socialLinks.keys.map((link){
          return Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child:  IconButton(
              icon: _getIconFromString(widget._aboutArticle.socialLinks[link]),
              onPressed: (){
                AppBloc.openURL(link);
              },
            ),
          );
        }).toList()
      ),
    );
  }

  Icon _getIconFromString(String socialName){
    switch(socialName){
      case 'youtube':return Icon(AntDesign.youtube,color: Colors.white,);
      case 'facebook': return Icon(AntDesign.facebook_square,color: Colors.white,);
      case 'instagram':return Icon(AntDesign.instagram,color: Colors.white,);
      case 'twitter': return Icon(AntDesign.twitter,color: Colors.white,);
    }
    return null;
  }
}