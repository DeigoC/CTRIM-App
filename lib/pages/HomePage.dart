import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/pages/tab_pages/SettingsTabPage.dart';
import 'package:ctrim_app_v1/pages/tab_pages/ViewAllPostsTabPage.dart';
import 'package:ctrim_app_v1/pages/tab_pages/ViewAllLocationsTabPage.dart';
import 'package:ctrim_app_v1/pages/tab_pages/ViewGalleryTabPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{

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
    return BlocConsumer(
    bloc: BlocProvider.of<AppBloc>(context),
    listener: (_, state){
      
    },
    buildWhen: (previousState, currentState){
      if(currentState is AppTabClickedState){
        return true;
      }
      return false;
    },
    builder:(_,state){
      Widget result = _buildMainScaffold(0);
      if(state is AppTabClickedState){
        int selectedTab = _getTabIndexFromAppState(state);
        result = _buildMainScaffold(selectedTab);
      }
      return result;
    } ,
  ); 
  }

  int _getTabIndexFromAppState(AppTabClickedState state){
    if(state is AppPostsTabClickedState)return 0;
    else if(state is AppGalleryTabClickedState) return 1;
    else if(state is AppLocationsTabClickedState) return 2;
    else if(state is AppAboutTabClickedState) return 3;
    return 4;
  }

  Scaffold _buildMainScaffold(int selectedIndex) {
    return Scaffold(
    appBar: _getAppBar(selectedIndex),
    body: Builder(
      builder: (_){
        _setNewContext(_);
        return _getBody(selectedIndex);
      }),
    floatingActionButton: _getFAB(selectedIndex),
    drawer: _getDrawer(selectedIndex),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.black,
      onTap: (newIndex){
        BlocProvider.of<AppBloc>(context).add(TabButtonClicked(newIndex));
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

  void _setNewContext(BuildContext context){
    _eventPage.setContext(context);
    _galleryPage.setContext(context);
    _locationsPage.setContext(context);
    _settingsPage.setContext(context);
  }

  Widget _getFAB(int selectedIndex){
    return null;
  }

  AppBar _getAppBar(int selectedIndex){
    switch(selectedIndex){
      case 0: return _eventPage.buildAppBar();
      case 1: return _galleryPage.buildAppBar();
      case 3: return AppBar(title: Text('About'),);
      case 4: return _settingsPage.buildAppbar();
      break;
    }
    return null;
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

  Widget _getDrawer(int selectedIndex){
    if(selectedIndex == 4) return _settingsPage.buildDrawer();
    return null;
  }
}