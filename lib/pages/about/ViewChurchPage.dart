import 'dart:async';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      appBar: AppBar(title: Text('View Church'),),
      body: _buildBody(),
    );
  }

  Widget _buildBody(){
    
    return ListView(
      children: [
        _buildGallerySlideShow(),
        SizedBox(height: 8,),
        RaisedButton(
          child: Text('Get To Know Them'),
          onPressed: ()=>BlocProvider.of<AppBloc>(context).add(AppToViewPastorEvent(widget._aboutArticle)),
        )
      ],
    );
  }

  Widget _buildGallerySlideShow(){
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.3,
      child: PageView(
        physics: ClampingScrollPhysics(),
        controller: _pageController,
        children: [
          Container(
            color: Colors.red,
          ),
          Container(
            color: Colors.green,
          ),
          Container(
            color: Colors.blue,
          ),
          Container(
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}