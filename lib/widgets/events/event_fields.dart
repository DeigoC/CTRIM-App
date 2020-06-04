import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/EventBloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventDateTimeField extends StatelessWidget {
  final EventBloc _eventBloc;

  EventDateTimeField(this._eventBloc);
  
  @override
  Widget build(BuildContext context) {
     return BlocBuilder(
         bloc: _eventBloc,
         condition: (previousState, currentState){
           if(currentState is EventScheduleState) return true;
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
                        onPressed: () => _eventBloc.add(SelectEventDateEvent()),
                      ),
                        Text(' AT '),
                        FlatButton(
                          child: Text(_eventBloc.getSelectedTimeString),
                          onPressed: () => _eventBloc.add(SelectEventTimeEvent()),
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
              onPressed: () => BlocProvider.of<AppBloc>(context).add(ToSelectLocationForEvent()),
            ),
        ],
      ),
    );
  }
}