import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/App.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'appnav_event.dart';
part 'appnav_state.dart';

class AppNavBloc extends Bloc<AppnavEvent, AppnavState> {
  
  final GlobalKey<NavigatorState> navigatorKey;
  AppNavBloc(this.navigatorKey);
  
  @override
  AppnavState get initialState => AppnavInitial();

  @override
  Stream<AppnavState> mapEventToState(
    AppnavEvent event,
  ) async* {
    if(event is AppnavPopAction) navigatorKey.currentState.pop();
    else if(event is AppnavToViewEvent) navigatorKey.currentState.pushNamed(ViewEventRoute);
  }
}
