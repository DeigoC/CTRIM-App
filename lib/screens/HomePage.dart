import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/screens/tab_pages/EventPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {

  BuildContext _context;
  EventPage _eventPage;

  @override
  Widget build(BuildContext context) {
    _context = context;
    _eventPage = EventPage(context);
    
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

  AppBar _getAppBar(int selectedIndex){
    switch(selectedIndex){
      case 0: return _eventPage.buildAppBar();
      break;
       case 1: return AppBar(title: Text('Gallery'),);
      break;
       case 2: return AppBar(title: Text('Locations'),);
      break;
       case 3: return AppBar(title: Text('About'),);
      break;
       case 4: return AppBar(title: Text('Settings'),);
      break;
    }
    return AppBar();
  }

  Widget _getBody(int selectedIndex){
    switch(selectedIndex){
      case 0: return _eventPage.buildBody();
      break;
      case 1: return Center(child: Text('Gallery'),);
      break;
      case 2: return Center(child: Text('Locations'),);
      break;
      case 3: return Center(child: Text('About'),);
      break;
      case 4: return Center(child: Text('Settings'),);
      break;
    }
    return Container();
  }
}