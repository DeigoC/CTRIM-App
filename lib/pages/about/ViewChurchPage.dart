import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/gallerySlideShow.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/socialLinks.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/viewUserSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/network.dart';

class ViewChurchPage extends StatefulWidget {
  final AboutArticle _aboutArticle;
  ViewChurchPage(this._aboutArticle);
  @override
  _ViewChurchPageState createState() => _ViewChurchPageState();
}

class _ViewChurchPageState extends State<ViewChurchPage> {

  BuildContext _context;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._aboutArticle.title + ' Church'),centerTitle: true,),
      body: Builder(
        builder: (_){
          _context = _;
          return _buildFBBody();
        },
      ),
    );
  }

  FutureBuilder _buildFBBody(){
    return FutureBuilder<Map<String, dynamic>>(
      future: BlocProvider.of<TimelineBloc>(context).fetchChurchData(widget._aboutArticle),
      builder: (_,snap){
        Widget result;
        if(snap.hasData) result = _buildBodyWithData(snap.data);
        else if(snap.hasError) result = Center(child: Text('Something went wrong!'),);
        else result = Center(child: CircularProgressIndicator(),);
        return result;
      },
    );
  }

  ListView _buildBodyWithData(Map<String, dynamic> data){
    TextStyle headerStyle = TextStyle(fontSize: 36);
    TextStyle bodyStyle = TextStyle(fontSize: 18);

    User pastorUser = data['User'];
    Location location = data['Location'];

    return ListView(
      children: [
        GallerySlideShow(galleryItems: widget._aboutArticle.slideShowItems,),
        SizedBox(height: 16,),

        Text('Location',style: headerStyle, textAlign: TextAlign.center,),
        MyFlatButton(
          label: location.addressLine,
          fontSize: 18,
          onPressed: (){
            BlocProvider.of<AppBloc>(context).add(AppToViewLocationOnMapEvent(location));
          },
        ),
        SizedBox(height: 32,),

        Text('Service Times',style: headerStyle,textAlign: TextAlign.center,),
        Text(widget._aboutArticle.serviceTime, textAlign: TextAlign.center,style: bodyStyle,),
        SizedBox(height: 32,),

       Text('Location Pastor',style: headerStyle,textAlign: TextAlign.center,),
       MyFlatButton(
        label: pastorUser.forename + ' ' + pastorUser.surname,
        fontSize: 18,
        onPressed: (){
          showBottomSheet(
            context: _context, 
            backgroundColor: Colors.transparent,
            builder: (_){
              return ViewUserSheet(pastorUser);
          });
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
              child: Image(image:NetworkImageWithRetry(widget._aboutArticle.secondImage),)
            ),
          ),
        ),
        SizedBox(height: 16,),
        MyRaisedButton(
          externalPadding: EdgeInsets.symmetric(horizontal: 32),
          label: 'Get To Know Them',
          fontsize: 20,
          onPressed: ()=>BlocProvider.of<AppBloc>(context).add(AppToViewPastorEvent(widget._aboutArticle)),
        ),
        SizedBox(height: 16,),

        Text("We're on social. Follow us",style: headerStyle,textAlign: TextAlign.center,),
        SocialLinksDisplay(widget._aboutArticle.socialLinks),
        SizedBox(height: 32,),
      ],
    );
  }

}