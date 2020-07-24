import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/pages/tab_pages/AboutTabPage.dart';
import 'package:ctrim_app_v1/pages/tab_pages/SettingsTabPage.dart';
import 'package:ctrim_app_v1/pages/tab_pages/ViewAllPostsTabPage.dart';
import 'package:ctrim_app_v1/pages/tab_pages/ViewAllLocationsTabPage.dart';
import 'package:ctrim_app_v1/pages/tab_pages/ViewGalleryTabPage.dart';
import 'package:ctrim_app_v1/style.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{

  // ! Tab pages
  ViewAllEventsPage _eventPage;
  ViewGalleryPage _galleryPage;
  ViewAllLocationsPage _locationsPage;
  SettingsPage _settingsPage;
  AboutTabPage _aboutTabPage;
  int _selectedIndex =0;

  // ! Tab page scroll controllers
  ScrollController _postsScrollController;

  // ! Firebase messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  
  @override
  void initState() { 
    super.initState();
    // ! Controllers
    _postsScrollController = ScrollController();

    // ! Tab Pages
    _eventPage = ViewAllEventsPage(context,_postsScrollController);
    _galleryPage = ViewGalleryPage(context, TabController(length: 2, vsync: this));
    _locationsPage = ViewAllLocationsPage(context);
    _settingsPage = SettingsPage(context);
    _aboutTabPage = AboutTabPage(context, TabController(length: 3, vsync: this));
      
    // ! Firebase messaging
    _firebaseMessaging.configure(
      onMessage: (message)async{
        // * When app's open
        print('-------------------ON MESSAGE: ' + message.toString());
      },
      onResume: (message)async{

      },
      onLaunch: (message)async{

      },
    );
  }

  @override
  void dispose() { 
    _postsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async=> false,
      child: BlocConsumer<AppBloc, AppState>(
      listener: (_, state){
        if(state is AppRebuildSettingsDrawerState) BlocProvider.of<AppBloc>(context).add(TabButtonClicked(4));
      },
      buildWhen: (previousState, currentState){
        if(currentState is AppTabClickedState)return true;
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
  ),
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
    bottomNavigationBar: BlocBuilder<AppBloc, AppState>(
      condition: (_,state){
        if(state is SettingsState) return true;
        return false;
      },
        builder:(_,state) => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: BlocProvider.of<AppBloc>(context).onDarkTheme ? Colors.white: Colors.black87,
        backgroundColor: BlocProvider.of<AppBloc>(context).onDarkTheme ? DarkPrimaryColor : LightSurfaceColor,
        onTap: (newIndex){
          if(newIndex != _selectedIndex){
            setState(() {
              _selectedIndex = newIndex;
            });
          }else{
            if(_selectedIndex == 0){
             _postsScrollController.animateTo(_postsScrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 500,), curve: Curves.easeIn);
            }
          }
          BlocProvider.of<AppBloc>(context).add(TabButtonClicked(newIndex));
        },
        items: [
           BottomNavigationBarItem(
            title: Container(),
            icon: Tooltip(child: Icon(Icons.home),message: 'Home',)
          ),
          BottomNavigationBarItem(
            title: Container(),
            icon: Tooltip(child: Icon(Icons.photo_library),message: 'Gallery'),
          ),
          BottomNavigationBarItem(
            title: Container(),
            icon: Tooltip(child: Icon(Icons.map),message: 'Locations'),
          ),
           BottomNavigationBarItem(
             title: Container(),
            icon: Tooltip(child: Icon(Icons.info),message: 'About Us'),
          ),
          BottomNavigationBarItem(
            title: Container(),
            icon: Tooltip(child: Icon(Icons.settings),message: 'Settings'),
          ),
        ],
      ),
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
    if(selectedIndex ==0) return _eventPage.buildFAB();
    return null;
  }

  AppBar _getAppBar(int selectedIndex){
    switch(selectedIndex){
      case 1: return _galleryPage.buildAppBar();
      case 4: return _settingsPage.buildAppbar();
      break;
    }
    return null;
  }

  Widget _getBody(int selectedIndex){
    switch(selectedIndex){
      case 0:return _eventPage.buildBody();
      break;
      case 1: return _galleryPage.buildBody();
      break;
      case 2: return _locationsPage.buildBody();
      break;
      case 3: return _aboutTabPage.buildBody();
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