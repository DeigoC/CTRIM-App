import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventDateTimeField extends StatelessWidget {
  final PostBloc _eventBloc;

  EventDateTimeField(this._eventBloc);
  
  @override
  Widget build(BuildContext context) {
     return BlocBuilder(
         bloc: _eventBloc,
         condition: (previousState, currentState){
           if(currentState is PostScheduleTabEvent) return true;
           return false;
         },
          builder:(_,state){
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date'),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                       FlatButton(
                        child: Text(_eventBloc.getSelectedDateString),
                        onPressed: () => _eventBloc.add(PostSelectPostDateEvent()),
                      ),
                        Text(' AT '),
                        FlatButton(
                          child: Text(_eventBloc.getSelectedTimeString),
                          onPressed: () => _eventBloc.add(PostSelectPostTimeEvent()),
                        ),
                    ],
                  ),
              ],),
            );
          } 
       );
  }
}

class EventLocationField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text('Location'),
            FlatButton(
              child: Text('PENDING LOCATION'),
              onPressed: () => BlocProvider.of<AppBloc>(context).add(AppToSelectLocationForPostEvent()),
            ),
        ],
      ),
    );
  }
}