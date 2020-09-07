import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
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
  final LineTheme _defaultLineTheme = LineTheme(
    textStyle: TextStyle(color: Colors.white),
    padding: EdgeInsets.only(left: 8)
  );
  
  @override
  Widget build(BuildContext context) {
    _avatarLength = MediaQuery.of(context).size.width * 0.4;
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.95,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: EdgeInsets.only(top: _avatarLength/2),
              padding: EdgeInsets.only(top: (_avatarLength/2) + 8),
              height: MediaQuery.of(context).size.height*0.8,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Color(0xff184a99),
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
                  _buildSocialLinks(),
                  SizedBox(height: 8,),
                  Divider(indent: 8,endIndent: 8,color: Colors.white,),
                  ZefyrTheme(
                    data: ZefyrThemeData(
                      attributeTheme: AttributeTheme(
                        heading1:_defaultLineTheme,
                        heading2: _defaultLineTheme,
                        heading3: _defaultLineTheme,
                        link: TextStyle(
                          color: Color(0xffc51f5f),//Colors.grey.shade600,
                          decoration: TextDecoration.underline,
                        ),
                        quote:BlockTheme(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          textStyle: TextStyle(color: Colors.white.withOpacity(0.6),),
                          inheritLineTextStyle: true,
                        )
                      ),
                      defaultLineTheme: LineTheme(
                        textStyle: TextStyle(color: Colors.white),
                        padding: EdgeInsets.all(8)
                      )
                    ),
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: ZefyrView(
                        document: widget.user.getBodyDoc(),
                      ),
                    )
                  ),
                ],
              ),
            ),
          ),
          _buildUserAvatar(),
          Container(
            margin: EdgeInsets.only(top: _avatarLength/2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.only(right:16),
                  tooltip: 'Close',
                  icon: Icon(Icons.close,color: Colors.white,),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(){
    if(widget.user.socialLinks.length != 0) return SocialLinksDisplay(widget.user.socialLinks);
    return Center(child: Text('No Social Links/Contacts added.', style: TextStyle(color: Colors.white),));
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