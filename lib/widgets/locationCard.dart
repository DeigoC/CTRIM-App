import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/classes/other/adminCheck.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationCard extends StatelessWidget {
  final Location location;
  final bool isSelecting;
  final Function onTap;
  LocationCard({@required this.location}):isSelecting = false, onTap = null;

  LocationCard.addressSelect({@required this.location, @required this.onTap}):isSelecting = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: (){
          if(isSelecting){
            onTap();
          }else{
            BlocProvider.of<AppBloc>(context).add(AppToViewAllPostsForLocationEvent());
          }
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  if (location.imgSrc.isNotEmpty) {
                    BlocProvider.of<AppBloc>(context).add(
                        AppToViewImageVideoPageEvent({location.imgSrc:ImageTag(src: location.imgSrc, type: 'img')
                    }, 0));
                  }
                },
                child: Hero(
                  tag: location.imgSrc == null
                      ? location.addressLine
                      : '0/' + location.imgSrc,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.30,
                    height: MediaQuery.of(context).size.width * 0.30,
                    decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(8),
                        image: location.imgSrc.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(location.imgSrc),
                                fit: BoxFit.cover)
                            : null),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ListTile(
                    title: RichText(text: TextSpan(
                      text: location.addressLine,
                      style: TextStyle(color: Colors.black),
                      recognizer: TapGestureRecognizer()..onTap =()=> BlocProvider.of<AppBloc>(context)
                      .add(AppToViewLocationOnMapEvent(location)),
                    ),),
                    subtitle: Text(location.description),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: (AdminCheck.isCurrentUserAboveLvl1(context) && onTap==null) ? [
                      IconButton(
                        onPressed:() => BlocProvider.of<AppBloc>(context).add(AppToEditLocationEvent(location)),
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                      icon: Icon(Icons.content_copy),
                      tooltip: 'Copy address line',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: location.addressLine));
                        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Address line copied')));
                      },
                    ),
                  ]: [  
                    IconButton(
                      icon: Icon(Icons.content_copy),
                      tooltip: 'Copy address line',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: location.addressLine));
                        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Address line copied')));
                      },
                    ),
                  ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
