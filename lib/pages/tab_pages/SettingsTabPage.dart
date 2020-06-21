import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage{
  
  BuildContext _context;
  void setContext(BuildContext context) => _context = context;
  SettingsPage(this._context);

  AppBar buildAppbar(){
    return AppBar(
      title: Text('Settings'),
      centerTitle: true,
    );
  }

  BlocBuilder buildDrawer(){
    return BlocBuilder(
      bloc: BlocProvider.of<AppBloc>(_context),
      condition: (_,state){
        return false;
      },
      builder: (_,state){
        return Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue
                ),
                child: Text('Admin Facility'),
              ),
              ListTile(
                title: Text('My Posts'),
                leading: Icon(Icons.description),
                onTap: (){
                  BlocProvider.of<AppBloc>(_context).add(AppToViewMyPostsPageEvent());
                },
              ),
              ListTile(
                title: Text('Register User'),
                leading: Icon(Icons.person_add),
                onTap: (){
                  BlocProvider.of<AppBloc>(_context).add(AppToRegisterUserEvent());
                },
              ),
              ListTile(
                title: Text('Edit User'),
                leading: Icon(Icons.people),
                onTap: (){
                  BlocProvider.of<AppBloc>(_context).add(AppToViewAllUsersEvent());
                },
              ),
            ],
          ),
        );
      },
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
                secondary: Icon(Icons.brightness_medium),
                subtitle: Text('Changes the brightness and colours of the app to be easy on the eyes'),
                onChanged: (newValue){
                  AppSettingsEvent event = newValue ? AppChangeThemeToDarkEvent() : AppChangeThemeToLightEvent();
                  BlocProvider.of<AppBloc>(_context).add(event);
                }
              ),
              ListTile(
                title: Text('Admin Login'),
                subtitle: Text('Admins are registered by developer'),
                leading: Icon(Icons.person),
                onTap: (){
                   BlocProvider.of<AppBloc>(_context).add(AppToUserLoginEvent());
                },
              ),
              ListTile(
                title: Text('App Details'),
                subtitle: Text('Extra details about the app'),
                leading: Icon(Icons.info_outline),
                onTap: (){
                  showAboutDialog(context: _context);
                },
              ),
            ],
          );
        } 
    );
  }
}