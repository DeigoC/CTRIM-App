import 'package:ctrim_app_v1/blocs/EventBloc/event_bloc.dart';
import 'package:ctrim_app_v1/screens/HomePage.dart';
import 'package:ctrim_app_v1/screens/events/ViewEventPage.dart';
import 'package:ctrim_app_v1/screens/events/AddEventPage.dart';
import 'package:ctrim_app_v1/screens/gallery/AddFiles.dart';
import 'package:ctrim_app_v1/screens/gallery/EditAlbum.dart';
import 'package:ctrim_app_v1/screens/gallery/ViewImageVideo.dart';
import 'package:ctrim_app_v1/screens/location/AddLocation.dart';
import 'package:ctrim_app_v1/screens/location/EditLocation.dart';
import 'package:ctrim_app_v1/screens/location/SelectLocationForEvent.dart';
import 'package:ctrim_app_v1/screens/location/ViewAllEventsForLocation.dart';
import 'package:ctrim_app_v1/screens/location/ViewLocationOnMap.dart';
import 'package:ctrim_app_v1/screens/user/EditUser.dart';
import 'package:ctrim_app_v1/screens/user/RegisterUser.dart';
import 'package:ctrim_app_v1/screens/user/ViewAllUsers.dart';
import 'package:ctrim_app_v1/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/AppBloc/app_bloc.dart';
import 'blocs/GalleryBloc/gallery_bloc.dart';

const HomeRoute ='/';
const ViewEventRoute ='/ViewEventPage';
const AddEventRoute = '/AddEventPage';

const ViewImageVideoRoute = '/ViewImageVideo';
const EditAlbumRoute = '/EditAlbum';
const AddGalleryFilesRoute = '/AddFiles';

const ViewLocationOnMapRoute = '/ViewLocationOnMap';
const ViewAllEventsForLocationRoute = '/ViewAllEventsForLocation';
const AddLocationRoute = '/AddLocation';
const EditLocationRoute = '/EditLocation';
const SelectLocationForEventRoute = '/SelectLcoationForEvent';

const RegisterUserRoute = '/RegisterUser';
const ViewAllUsersRoute = '/ViewAllUsers';
const EditUserRoute = '/EditUser';
class App extends StatefulWidget {

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  AppBloc _appBloc;

  @override
  void initState() { 
    super.initState();
    _appBloc = AppBloc(_navigatorKey);
  }

  @override
  void dispose() { 
    _appBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>(
        create: (_) => _appBloc,
      ),
      BlocProvider<EventBloc>(
        create: (_) => EventBloc(),
      ),
      BlocProvider<GalleryBloc>(
        create: (_) => GalleryBloc(),
      ),
      ],
      child: BlocBuilder(
        bloc: _appBloc,
        condition: (previousState, currentState){
          if(currentState is SettingsState) return true;
          return false;
        },
        builder:(_,state){
          bool onDark = false;
          if(state is AppThemeToDark) onDark = true;
          return MaterialApp(
          navigatorKey: _navigatorKey,
          theme: onDark ? appDarkTheme : appLightTheme,
          onGenerateRoute: _routes(),
        );
        }
      ),
    );
  }

  RouteFactory _routes(){
    return (settings){
      final Map<String, dynamic> arguments = settings.arguments;

      Widget screen;

      switch (settings.name){
        case HomeRoute: screen = HomePage();
        break;

        case ViewEventRoute: screen = ViewEventPage();
        break;

        case AddEventRoute: screen = AddEventPage();
        break;

        case ViewImageVideoRoute: screen = ViewImageVideo();
        break;
        
        case ViewLocationOnMapRoute: screen = ViewLocationOnMap();
        break;

        case ViewAllEventsForLocationRoute: screen = ViewAllEventsForLocation();
        break;
        
        case RegisterUserRoute: screen = RegisterUser();
        break;

        case ViewAllUsersRoute: screen = ViewAllUsers();
        break;

        case EditUserRoute: screen = EditUser();
        break;

        case AddLocationRoute: screen = AddLocation();
        break;

        case EditLocationRoute: screen = EditLocation();
        break;

        case SelectLocationForEventRoute: screen = SelectLocationForEvent();
        break;

        case EditAlbumRoute: screen = EditAlbum();
        break;

        case AddGalleryFilesRoute: screen = AddGalleryFiles();
        break;
      }
      return MaterialPageRoute(builder: (context) => screen);
    };
  }
}