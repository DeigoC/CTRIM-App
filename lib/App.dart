import 'package:ctrim_app_v1/screens/HomePage.dart';
import 'package:ctrim_app_v1/screens/events/ViewEventPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/AppBloc/app_bloc.dart';
import 'blocs/AppNavBloc/appnav_bloc.dart';
import 'blocs/GalleryBloc/gallery_bloc.dart';

const HomeRoute ='/';
const ViewEventRoute ='/ViewEventPage';
class App extends StatelessWidget {

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>(
        create: (_) => AppBloc(),
      ),
      BlocProvider<AppNavBloc>(
        create: (_) => AppNavBloc(_navigatorKey),
      ),
      BlocProvider<GalleryBloc>(
        create: (_) => GalleryBloc(),
      ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        onGenerateRoute: _routes(),
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
        
      }
      return MaterialPageRoute(builder: (context) => screen);
    };
  }
}