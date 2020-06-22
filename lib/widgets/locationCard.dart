import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/models/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationCard extends StatelessWidget {
  
  final Location location;
  final Function onTap;
  LocationCard({@required this.location, this.onTap});

  @override
  Widget build(BuildContext context) {
     return Card(
            child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: (){
              if(onTap == null){
                 BlocProvider.of<AppBloc>(context).add(AppToViewAllPostsForLocationEvent());
              }else{
                onTap();
              }
            },
              child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: (){
                      if(location.imgSrc!=null){
                        BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPage({location.imgSrc:'img'}, 0));
                      }
                    },
                    child: Hero(
                      tag: location.imgSrc??location.addressLine,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        height: MediaQuery.of(context).size.width * 0.30,
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(8),
                          image: location.imgSrc!=null ? DecorationImage(image: NetworkImage(location.imgSrc), fit: BoxFit.cover) : null
                        ),
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
                        title: Text(location.addressLine),
                        subtitle: Text(location.description),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.end,
                        children: (onTap != null) ?[
                          IconButton(
                            onPressed: () => BlocProvider.of<AppBloc>(context).add(AppToViewLocationOnMapEvent()),
                            icon: Icon(Icons.location_on),
                          ),
                        ] : [
                           IconButton(
                            onPressed: () =>BlocProvider.of<AppBloc>(context).add(AppToEditLocationEvent(location)),
                            icon: Icon(Icons.edit)
                          ),
                          IconButton(
                            onPressed: () => BlocProvider.of<AppBloc>(context).add(AppToViewLocationOnMapEvent()),
                            icon: Icon(Icons.location_on),
                          ),
                           IconButton(
                            icon: Icon(Icons.content_copy),
                            tooltip: 'Copy address line',
                            onPressed: (){
                              Clipboard.setData(ClipboardData(text: location.addressLine));
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Address line copied')
                              ));
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