import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/screens/tab_pages/SettingsPage.dart';
import 'package:ctrim_app_v1/screens/tab_pages/ViewAllEventsPage.dart';
import 'package:ctrim_app_v1/screens/tab_pages/ViewAllLocationsPage.dart';
import 'package:ctrim_app_v1/screens/tab_pages/ViewGalleryPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  
  BuildContext _context;
   ViewAllEventsPage _eventPage;
   ViewGalleryPage _galleryPage;
   ViewAllLocationsPage _locationsPage;
   SettingsPage _settingsPage;
  
  
@override
void initState() { 
  super.initState();
   _eventPage = ViewAllEventsPage(context);
  _galleryPage = ViewGalleryPage(context, TabController(length: 2, vsync: this));
  _locationsPage = ViewAllLocationsPage(context);
  _settingsPage = SettingsPage(context);
}

  @override
  Widget build(BuildContext context) {
    _context = context;
    return BlocConsumer(
    bloc: BlocProvider.of<AppBloc>(context),
    listener: (_, state){
      
    },
    buildWhen: (previousState, currentState){
      if(currentState is AppTabClicked){
        return true;
      }
      return false;
    },
    builder:(_,state){
      Widget result = _buildMainScaffold(0);
      if(state is AppTabClicked){
        int selectedTab = _getTabIndexFromAppState(state);
        result = _buildMainScaffold(selectedTab);
      }
      return result;
    } ,
  ); 
  }

  int _getTabIndexFromAppState(AppTabClicked state){
    if(state is AppEventsTabClicked)return 0;
    else if(state is AppGalleryTabClicked) return 1;
    else if(state is AppLocationsTabClicked) return 2;
    else if(state is AppAboutTabClicked) return 3;
    return 4;
  }

  Scaffold _buildMainScaffold(int selectedIndex) {
    return Scaffold(
    appBar: _getAppBar(selectedIndex),
    body: _getBody(selectedIndex),
    floatingActionButton: _getFAB(selectedIndex),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.black,
      onTap: (newIndex){
        BlocProvider.of<AppBloc>(_context).add(TabButtonClicked(newIndex));
      },
      items: [
         BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Events'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library),
          title: Text('Gallery'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          title: Text('Locations'),
        ),
         BottomNavigationBarItem(
          icon: Icon(Icons.info),
          title: Text('About'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text('Settings'),
        ),
      ],
    ),
  );
  }

  Widget _getFAB(int selectedIndex){
    switch(selectedIndex){
      case 0: return _eventPage.buildFAB();
      break; 
    }
    return null;
  }

  AppBar _getAppBar(int selectedIndex){
    switch(selectedIndex){
      case 0: return _eventPage.buildAppBar();
      break;
       case 1: return _galleryPage.buildAppBar();
      break;
       case 2: return _locationsPage.buildAppBar();
      break;
       case 3: return AppBar(title: Text('About'),);
      break;
       case 4: return _settingsPage.buildAppbar();
      break;
    }
    return AppBar();
  }

  Widget _getBody(int selectedIndex){
    switch(selectedIndex){
      case 0: return _eventPage.buildBody();
      break;
      case 1: return _galleryPage.buildBody();
      break;
      case 2: return _locationsPage.buildBody();
      break;
      case 3: return Center(child: Text('About'),);
      break;
      case 4: return _settingsPage.buildBody();
      break;
    }
    return Container();
  }
}