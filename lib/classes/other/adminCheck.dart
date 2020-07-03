import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminCheck{

  static bool isCurrentUserAboveLvl1(BuildContext context){
    User thisUser = BlocProvider.of<AppBloc>(context).currentUser;
    return isUserAboveLvl1(thisUser);
  }

  static bool isCurrentUserAboveLvl2(BuildContext context){
    User thisUser = BlocProvider.of<AppBloc>(context).currentUser;
    return isUserAboveLvl2(thisUser);
  }

  static bool isUserAboveLvl1(User user){
    if(user.adminLevel > 1) return true;
    return false;
  }

  static bool isUserAboveLvl2(User user){
    if(user.adminLevel > 2) return true;
    return false;
  }

}