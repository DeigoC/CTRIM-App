part of 'appnav_bloc.dart';

abstract class AppnavEvent extends Equatable {
   @override
  List<Object> get props => [];
  const AppnavEvent();
}

class AppnavPopAction extends AppnavEvent {}

class AppnavToViewEvent extends AppnavEvent {}

