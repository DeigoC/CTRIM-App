import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/other/adminCheck.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage{
  
  BuildContext _context;
  void setContext(BuildContext context) => _context = context;
  SettingsPage(this._context);

  AppBar buildAppbar(){
    return AppBar(
      leading: (BlocProvider.of<AppBloc>(_context).currentUser.adminLevel==0) ? Container():null,
      automaticallyImplyLeading: true,
      title: Text('Settings'),
      centerTitle: true,
    );
  }

  Widget buildDrawer(){
    if(BlocProvider.of<AppBloc>(_context).currentUser.adminLevel==0)return null;
    return Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
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
                  title: Text('My Details'),
                  leading: Icon(Icons.person),
                  onTap: (){
                    BlocProvider.of<AppBloc>(_context).add(AppToMyDetailsEvent());
                  },
                ),
                ListTile(
                  title: Text('Register User'),
                  leading: Icon(Icons.person_add),
                  onTap: AdminCheck.isCurrentUserAboveLvl1(_context) ? 
                    ()=> BlocProvider.of<AppBloc>(_context).add(AppToRegisterUserEvent()): null,
                ),
                ListTile(
                  title: Text('Edit User'),
                  leading: Icon(Icons.people),
                  onTap: AdminCheck.isCurrentUserAboveLvl1(_context) ? 
                  ()=> BlocProvider.of<AppBloc>(_context).add(AppToViewAllUsersEvent()) : null,
                ),
                ListTile(
                  title: Text('Log out'),
                  leading: Icon(Icons.person_outline),
                  onTap: (){
                    ConfirmationDialogue.userLogout(context: _context).then((confirmation){
                      if(confirmation){
                        Navigator.of(_context).pop();
                        BlocProvider.of<AppBloc>(_context).add(AppCurrentUserLogsOutEvent());
                      }
                    });
                  },
                ),
              ],
            ),
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
                title: Text('My Liked Posts'),
                subtitle: Text('View Posts that you have saved'),
                leading: Icon(Icons.favorite),
                onTap: (){
                  BlocProvider.of<AppBloc>(_context).add(AppToLikedPostsPageEvent());
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