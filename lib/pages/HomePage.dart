import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/notificationHandler.dart';
import 'package:ctrim_app_v1/pages/tab_pages/AboutTabPage.dart';
import 'package:ctrim_app_v1/pages/tab_pages/SettingsTabPage.dart';
import 'package:ctrim_app_v1/pages/tab_pages/ViewAllPostsTabPage.dart';
import 'package:ctrim_app_v1/pages/tab_pages/ViewAllLocationsTabPage.dart';
import 'package:ctrim_app_v1/style.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:scroll_app_bar/scroll_app_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{

  // ! Tab pages
  ViewAllEventsPage _eventPage;
  ViewAllLocationsPage _locationsPage;
  SettingsPage _settingsPage;
  AboutTabPage _aboutTabPage;
  int _selectedIndex =0;
  double _postPageScrollPosition =0;

  // ! Tab page scroll controllers
  ScrollController _postsScrollController, _locationScrollController;

  // ! Firebase messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  
  @override
  void initState() { 
    super.initState();

    // ! Controllers
    _postsScrollController = ScrollController();
    _locationScrollController = ScrollController();

    // ! Tab Pages
    _eventPage = ViewAllEventsPage(context,_postsScrollController);
    _locationsPage = ViewAllLocationsPage(context, _locationScrollController);
    _settingsPage = SettingsPage(context);
    _aboutTabPage = AboutTabPage(context, TabController(length: 3, vsync: this));
      
    // ! Firebase messaging
    // * Some notes:
    // * message has 2 keys of interest: 'notification' and 'data'
    // * notification just states the 'title' and 'body' of the message (seen from standard notifications)
    // * data is the important one, you can add whatever data you want in it and i think
    // * data must include the "click_action: FLUTTER_NOTIFICATION_CLICK" key value pair
    NotificationHandler _notificationHandler = NotificationHandler(context);
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (message)async{
        // * When app's open
        //print('----------------------------ON MESSAGE!');
        print('----------------MESSAGE LOOKS LIKE: ' + message.toString());
        _notificationHandler.handleOnMessage(message);
      },
      onResume: (message)async{
        print('----------------------------ON RESUME!');
        _notificationHandler.handleOnResume(message);
      },
      onLaunch: (message)async{
        print('----------------------------ON LAUNCH!');
        _notificationHandler.handleOnLaunch(message);
      },
    );
  }

  void _handleOnMessage(Map<String,dynamic> message){
    //final Map<String, dynamic> notificationData = Map<String, dynamic>.from(message['data']);
    final  Map<String, dynamic> notificationLabels = Map<String, dynamic>.from(message['notification']);
     
     String postID = message['postID'];
     BlocProvider.of<AppBloc>(context).add(AppToViewPostPageEvent(postID));
      showDialog(
        context: context,
        builder: (_){
          return AlertDialog(
            title: Text('Highlighted Post Notification!',textScaleFactor: 1.2,textAlign: TextAlign.center,),
            content: RichText(
              text: TextSpan(
                text: notificationLabels['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                  color: BlocProvider.of<AppBloc>(context).onDarkTheme ? Colors.white : Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "\n\n${notificationLabels['body']}",
                    style: TextStyle(
                      fontWeight: FontWeight.normal, 
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                      color: BlocProvider.of<AppBloc>(context).onDarkTheme ? Colors.white : Colors.black,
                    ),
                    
                  ),
                ],
              ),
            ),
            actions: [
              MyFlatButton(
                label: 'Close',
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
              MyFlatButton(
                label: 'View Post',
                onPressed: (){
                  Navigator.of(context).pop();
                  BlocProvider.of<AppBloc>(context).add(AppToViewPostPageEvent(postID));
                },
              ),
            ],
          );
        }
      );
  }

  @override
  void dispose() { 
    _postsScrollController.dispose();
    _locationScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async=> false,
      child: BlocConsumer<AppBloc, AppState>(
      listener: (_, state){
        if(state is AppRebuildSettingsDrawerState) BlocProvider.of<AppBloc>(context).add(TabButtonClicked(3));
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
    else if(state is AppLocationsTabClickedState) return 1;
    else if(state is AppAboutTabClickedState) return 2;
    return 3;
  }

  Widget _buildMainScaffold(int selectedIndex) {
    return BlocBuilder<AppBloc, AppState>(
      condition: (_,state){
        if(state is SettingsState) return true;
        return false;
      },
      builder: (context, state) {
        bool onDark = BlocProvider.of<AppBloc>(context).onDarkTheme;
        return Stack(
          children: [
          SafeArea(
              child: Scaffold(
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
                  unselectedItemColor: BlocProvider.of<AppBloc>(context).onDarkTheme ? Colors.white38 :null,
                  selectedItemColor: BlocProvider.of<AppBloc>(context).onDarkTheme ? Colors.white: LightPrimaryColor,
                  backgroundColor: BlocProvider.of<AppBloc>(context).onDarkTheme ? DarkPrimaryColor : LightSurfaceColor,
                  onTap: (newIndex){
                    _scrollToTop(newIndex);
                    BlocProvider.of<AppBloc>(context).add(TabButtonClicked(newIndex));
                  },
                  items: [
                     BottomNavigationBarItem(
                      title: Container(),
                      icon: Tooltip(child: Icon(Icons.home),message: 'Home',)
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
      ),
            ),
          Container(
              color: onDark ? Color(0xff525252):Color(0xffdb9423),
              height: MediaQuery.of(context).padding.top,
              width: double.infinity,
            ),
          ],
        );
      },
    );
  }

  void _scrollToTop(int newIndex){
    if(newIndex != _selectedIndex){
      setState(() {
        _selectedIndex = newIndex;
      });
    }else{
      if(_selectedIndex == 0){
      _postsScrollController.animateTo(_postsScrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 500,), curve: Curves.easeIn);
      }else if(_selectedIndex==1){
        _locationScrollController.animateTo(_locationScrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 500,), curve: Curves.easeIn);
      }
    }
  }

  void _setNewContext(BuildContext context){
    _eventPage.setContext(context);
    _locationsPage.setContext(context);
    _settingsPage.setContext(context);
  }

  Widget _getFAB(int selectedIndex){
    if(selectedIndex ==0) return _eventPage.buildFAB();
    return null;
  }

  PreferredSizeWidget _getAppBar(int selectedIndex){
    switch(selectedIndex){
      case 0: return _eventPage.buildAppBar();
      case 1: return _locationsPage.buildAppBar();
      case 3: return _settingsPage.buildAppbar();
      break;
    }
    return null;
  }

  Widget _getBody(int selectedIndex){
    switch(selectedIndex){
      case 0: return _buildPostTabBody();
      break;
      case 1: return _locationsPage.buildBody();
      break;
      case 2: return _aboutTabPage.buildBody();
      break;
      case 3: return _settingsPage.buildBody();
      break;
    }
    return Container();
  }

  Widget _buildPostTabBody(){
    return BlocListener<TimelineBloc, TimelineState>(
      condition: (_,state){
        if(state is TimelinePinPostSnackbarState || state is TimelineUnpinPostSnackbarState) return true;
        return false;
      },
      listener: (_,state){
        if(state is TimelinePinPostSnackbarState){
          if(!_postsScrollController.appBar.isPinned){
            setState(() { 
              // ? Remember the location 
              _postPageScrollPosition = _postsScrollController.position.pixels;
              _postsScrollController.appBar.tooglePinState(); 
            });
          }
        }else if (state is TimelineUnpinPostSnackbarState){
          if(_postsScrollController.appBar.isPinned){
            setState(() {
              // ? Animate to the location
              _postsScrollController.appBar.tooglePinState(); 
              //_postsScrollController.jumpTo(_postPageScrollPosition);
              _postsScrollController.animateTo(_postPageScrollPosition, 
              duration: Duration(milliseconds: 800,), curve: Curves.easeIn);
            });
          }
        }
      },
      child: _eventPage.buildBody(),
    );
  }

  Widget _getDrawer(int selectedIndex){
    if(selectedIndex == 3) return _settingsPage.buildDrawer();
    return null;
  }
}