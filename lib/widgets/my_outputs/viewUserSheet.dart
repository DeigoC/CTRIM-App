import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/socialLinks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/network.dart';
import 'package:zefyr/zefyr.dart';

class ViewUserSheet extends StatefulWidget {
  final User user;
  ViewUserSheet(this.user);
  @override
  _ViewUserSheetState createState() => _ViewUserSheetState();
}

class _ViewUserSheetState extends State<ViewUserSheet> {
 
  double _avatarLength;
  
  
  @override
  Widget build(BuildContext context) {
    _avatarLength = MediaQuery.of(context).size.width * 0.4;
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: EdgeInsets.only(top: _avatarLength/2),
            padding: EdgeInsets.only(top: (_avatarLength/2) + 8),
            height: MediaQuery.of(context).size.height*0.8,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: ListView(
              children: [
                Text(
                  widget.user.forename + ' ' + widget.user.surname,
                  style: TextStyle(fontSize: 32, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.user.role,
                  style: TextStyle(fontStyle: FontStyle.italic,fontSize: 18,color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16,),
                SocialLinksDisplay(widget.user.socialLinks),
                Divider(),
                ZefyrView(document: widget.user.getBodyDoc(),),
              ],
            ),
          ),
          _buildUserAvatar(),
          Padding(
            padding: EdgeInsets.only(top: (_avatarLength/2) + 5, right: 16),
            child: Align(
            alignment: Alignment.topRight,
            child: MyRaisedButton(
              label: 'Close',
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(){
    bool hasImage = widget.user.imgSrc != '';

    return Hero(
      tag: hasImage ?'0/'+ widget.user.imgSrc:'n/a',
      child: Container(
        height: _avatarLength,
        width: _avatarLength,
        child: GestureDetector(
          child: hasImage ? Container(
            height: _avatarLength,
            width: _avatarLength,
            decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.transparent,),
          ) :
          widget.user.buildAvatar(context),
          onTap: (){
            if(hasImage){
              BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPageEvent(
              {widget.user.imgSrc : ImageTag(src: widget.user.imgSrc, type: 'img')},0
              ));
            }
      }),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          image: hasImage? DecorationImage(
            image: NetworkImageWithRetry(widget.user.imgSrc),fit: BoxFit.cover ):null),
      ),
    );
  }
}