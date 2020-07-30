import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/adminCheck.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:package_info/package_info.dart';

class SettingsPage{
  
  BuildContext _context;
  void setContext(BuildContext context) => _context = context;
  String appName='AppName', packageName='PackageName',version='Version',buildNo='BuildNo';

  SettingsPage(this._context){
    PackageInfo.fromPlatform().then((packageInfo){
      appName=packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNo = packageInfo.buildNumber;
    });
  }

  AppBar buildAppbar(){
    bool isGuestUser = (BlocProvider.of<AppBloc>(_context).currentUser.adminLevel==0);
    return AppBar(
      automaticallyImplyLeading: !isGuestUser,
      titleSpacing: isGuestUser?16:0,
      title: isGuestUser ? Row(
        children: [
          Icon(FontAwesome5Solid.church,color: Colors.white,),
          SizedBox(width: 24,),
          Text('Settings',),
        ],
      ):Text('Settings'),
    );
  }

  Widget buildDrawer(){
    if(BlocProvider.of<AppBloc>(_context).currentUser.adminLevel==0)return null;
    User u = BlocProvider.of<AppBloc>(_context).currentUser;

    return Drawer(
      child: ListView(
        children: [
          SizedBox(height: 36,),
          Text('Admin Facility',textAlign: TextAlign.center,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
          SizedBox(height: 16,),
          ListTile(
            title: Text(u.forename + ' ' + u.surname),
            leading: Icon(Icons.person),
            onTap: (){
              BlocProvider.of<AppBloc>(_context).add(AppToMyDetailsEvent());
            },
          ),
          ListTile(
            title: Text('My Posts'),
            leading: Icon(Icons.description),
            onTap: (){
              BlocProvider.of<AppBloc>(_context).add(AppToViewMyPostsPageEvent());
            },
          ),
          ListTile(
            enabled: u.adminLevel > 1,
            title: Text('Register User'),
            leading: Icon(Icons.person_add),
            onTap: AdminCheck.isCurrentUserAboveLvl1(_context) ? 
              ()=> BlocProvider.of<AppBloc>(_context).add(AppToRegisterUserEvent()): null,
          ),
          ListTile(
            enabled: u.adminLevel > 1,
            title: Text('Edit User'),
            leading: Icon(Icons.people),
            onTap: u.adminLevel > 1 ? 
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
              ListTile(
                title: Text('Liked Posts'),
                subtitle: Text('Keep track of posts of interest'),
                leading: Icon(Icons.favorite),
                onTap: (){
                  BlocProvider.of<AppBloc>(_context).add(AppToLikedPostsPageEvent());
                },
              ),
              SwitchListTile(
                activeColor: LightSecondaryColor,
                value: BlocProvider.of<AppBloc>(_context).onDarkTheme, 
                title: Text('Dark Mode',),
                secondary: Icon(Icons.brightness_medium),
                subtitle: Text('Switch to a darker colour scheme',),
                onChanged: (newValue){
                  AppSettingsEvent event = newValue ? AppChangeThemeToDarkEvent() : AppChangeThemeToLightEvent();
                  BlocProvider.of<AppBloc>(_context).add(event);
                }
              ),
              
              ListTile(
                title: Text('Admin Login'),
                subtitle: Text('Admins are registered by other admins'),
                leading: Icon(Icons.person),
                onTap: (){
                   BlocProvider.of<AppBloc>(_context).add(AppToUserLoginEvent());
                },
              ),
              ListTile(
                title: Text('Other Info'),
                subtitle: Text('Extra details about the app'),
                leading: Icon(Icons.info_outline),
                onTap: (){
                  showAboutDialog(
                    context: _context,
                    applicationVersion: version,
                    applicationLegalese: 'This will contain the application legalese',
                    applicationName: appName + ' App',
                    applicationIcon: Icon(FontAwesome5Solid.church),
                  );
                },
              ),
            ],
          );
        } 
    );
  }
}