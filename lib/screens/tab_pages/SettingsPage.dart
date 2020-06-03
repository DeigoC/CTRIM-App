import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage{
  
  final BuildContext _context;
  SettingsPage(this._context);

  AppBar buildAppbar(){
    return AppBar(
      title: Text('Settings'),
      centerTitle: true,
    );
  }

  Widget buildBody(){
    return BlocConsumer(
      bloc: BlocProvider.of<AppBloc>(_context),
      listener: (_,state){

      },
      buildWhen: (previousState, currentState){
        if(currentState is SettingsState) return true;
        return false;
      },
        builder:(_,state){
          return ListView(
            children: [
              SwitchListTile(
                value: BlocProvider.of<AppBloc>(_context).onDarkTheme, 
                title: Text('Dark Mode'),
                onChanged: (newValue){
                  SettingsEvent event = newValue ? ChangeThemeToDark() : ChangeThemeToLight();
                  BlocProvider.of<AppBloc>(_context).add(event);
                }
              ),
            ],
          );
        } 
    );
  }
}