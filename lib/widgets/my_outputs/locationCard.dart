import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/classes/other/adminCheck.dart';
import 'package:ctrim_app_v1/style.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/network.dart';

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
          if(isSelecting){onTap();}
          else{BlocProvider.of<AppBloc>(context).add(AppToViewAllPostsForLocationEvent(location.id));}
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
                child: _buildImageContainer(context),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ListTile(
                    title: _buildTitle(context),
                    subtitle: Text(location.description,textAlign: TextAlign.center,),
                    isThreeLine: true,
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: (AdminCheck().isCurrentUserAboveLvl1(context) && onTap==null) ? [
                      IconButton(
                        tooltip: 'Edit Location',
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

  Widget _buildTitle(BuildContext context){
    if(location.id=='0') return Text('Address Not Applicable',textAlign: TextAlign.center,);
    else if(location.id =='-1') return Text('Online',textAlign: TextAlign.center,);
    return MyFlatButton(
      externalPadding: EdgeInsets.zero,
      label: location.addressLine,
      onPressed: ()=> BlocProvider.of<AppBloc>(context).add(AppToViewLocationOnMapEvent(location)),
      internalPadding: EdgeInsets.zero,
    );
  }

  Widget _buildImageContainer(BuildContext context) {
    

    if(location.imgSrc==''){
      return Container(
        width: MediaQuery.of(context).size.width * 0.30,
        height: MediaQuery.of(context).size.width * 0.30,
        decoration: BoxDecoration(
          color: LightPrimaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }
    return Hero(
      tag:'0/' + location.imgSrc,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.30,
        height: MediaQuery.of(context).size.width * 0.30,
        decoration: BoxDecoration(
            color: LightPrimaryColor,
            borderRadius: BorderRadius.circular(8),
            image:DecorationImage(
            image: NetworkImageWithRetry(location.imgSrc),
            fit: BoxFit.cover
          )
        ),
      ),
    );
  }
}
