import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/pages/HomePage.dart';
import 'package:ctrim_app_v1/pages/gallery/CreateAlbumPage.dart';
import 'package:ctrim_app_v1/pages/gallery/EditAlbumPage.dart';
import 'package:ctrim_app_v1/pages/gallery/ViewPostAlbumPage.dart';
import 'package:ctrim_app_v1/pages/posts/EditPostPage.dart';
import 'package:ctrim_app_v1/pages/posts/PostBodyEditorPage.dart';
import 'package:ctrim_app_v1/pages/posts/ViewMyPostsPage.dart';
import 'package:ctrim_app_v1/pages/posts/ViewPostPage.dart';
import 'package:ctrim_app_v1/pages/posts/AddPostPage.dart';
import 'package:ctrim_app_v1/pages/posts/SearchPostsPage.dart';
import 'package:ctrim_app_v1/pages/gallery/AddFilesPage.dart';
import 'package:ctrim_app_v1/pages/gallery/ViewImageVideoPage.dart';
import 'package:ctrim_app_v1/pages/location/AddLocationPage.dart';
import 'package:ctrim_app_v1/pages/location/EditLocationPage.dart';
import 'package:ctrim_app_v1/pages/location/SelectLocationForPostPage.dart';
import 'package:ctrim_app_v1/pages/location/ViewAllPostsForLocationPage.dart';
import 'package:ctrim_app_v1/pages/location/ViewLocationOnMapPage.dart';
import 'package:ctrim_app_v1/pages/user/EditUserPage.dart';
import 'package:ctrim_app_v1/pages/user/RegisterUserPage.dart';
import 'package:ctrim_app_v1/pages/user/UserLoginPage.dart';
import 'package:ctrim_app_v1/pages/user/ViewAllUsersPage.dart';
import 'package:ctrim_app_v1/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/AppBloc/app_bloc.dart';

const HomeRoute ='/';
const ViewEventRoute ='/ViewEventPage';
const AddEventRoute = '/AddEventPage';
const EventBodyEditorRoute = '/EventBodyEditorRoute';
const ViewMyPostsRoute = '/ViewMyPosts';
const EditPostRoute = '/EditPostPage';
const SearchPostsRoute = '/SearchPosts';

const ViewImageVideoRoute = '/ViewImageVideo';
const CreateAlbumRoute = '/CreateAlbum';
const AddGalleryFilesRoute = '/AddFiles';
const EditAlbumRoute = '/EditAlbum';
const ViewPostAlbumRoute = '/ViewPostAlbumPage';

const ViewLocationOnMapRoute = '/ViewLocationOnMap';
const ViewAllEventsForLocationRoute = '/ViewAllEventsForLocation';
const AddLocationRoute = '/AddLocation';
const EditLocationRoute = '/EditLocation';
const SelectLocationForEventRoute = '/SelectLcoationForEvent';

const RegisterUserRoute = '/RegisterUser';
const ViewAllUsersRoute = '/ViewAllUsers';
const EditUserRoute = '/EditUser';
const UserLoginRoute = '/UserLogin';
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
      BlocProvider<AdminBloc>(
        create: (_) => AdminBloc(),
      ),
      BlocProvider<TimelineBloc>(
        create: (_) => TimelineBloc(),
      )
      ],
      child: BlocBuilder(
        bloc: _appBloc,
        condition: (previousState, currentState){
          if(currentState is SettingsState) return true;
          return false;
        },
        builder:(_,state){
          bool onDark = false;
          if(state is AppThemeToDarkState) onDark = true;
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

        case ViewEventRoute: screen = ViewPostPage(arguments['post']);
        break;

        case AddEventRoute: screen = AddEventPage();
        break;

        case ViewImageVideoRoute: screen = ViewImageVideo(initialPage: arguments['initialPage'], imageSources: arguments['imgSources'],);
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

        case EditLocationRoute: screen = EditLocation(arguments['location']);
        break;

        case SelectLocationForEventRoute: screen = SelectLocationForEvent(arguments['postBloc']);
        break;

        case CreateAlbumRoute: screen = EditAlbum(arguments['postBloc']);
        break;

        case AddGalleryFilesRoute: screen = AddGalleryFiles(arguments['postBloc']);
        break;

        case EventBodyEditorRoute: screen = EventBodyEditor(arguments['postBloc']);
        break;
        case UserLoginRoute: screen = UserLoginPage();
        break;

        case ViewMyPostsRoute: screen = ViewMyPostsPage();
        break;

        case EditPostRoute: screen = EditPostPage(arguments['post']);
        break;

        case EditAlbumRoute: screen = EditAlbumPage(arguments['postBloc']);
        break;

        case ViewPostAlbumRoute: screen = ViewPostAlbumPage(arguments['post']);
        break;

        case SearchPostsRoute: screen = SearchPostsPage();
        break;
      }
      return MaterialPageRoute(builder: (context) => screen);
    };
  }
}