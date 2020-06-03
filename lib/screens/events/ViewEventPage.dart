import 'package:ctrim_app_v1/blocs/EventBloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewEventPage extends StatefulWidget{
  
  @override
  _ViewEventPageState createState() => _ViewEventPageState();
}

class _ViewEventPageState extends State<ViewEventPage> with SingleTickerProviderStateMixin{
  
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(vsync: this, length: 4);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_,__){
          return[
            SliverAppBar(
              expandedHeight: 200,
            ),
            SliverPadding(
              padding: EdgeInsets.all(8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('Title'),
                  TabBar(
                    labelColor: Colors.black,
                    controller: _tabController,
                    tabs: [
                      Tab(icon: Icon(Icons.info_outline), text: 'Main',),
                      Tab(icon: Icon(Icons.calendar_today), text: 'Schedule',),
                      Tab(icon: Icon(Icons.photo_library), text: 'Gallery',),
                      Tab(icon: Icon(Icons.track_changes), text: 'Updates',),
                    ],
                    onTap: (newIndex){
                      BlocProvider.of<EventBloc>(context).add(TabClickEvent(newIndex));
                    },
                  ),
                ]),),
            )
          ];
        },
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody(){
    return BlocConsumer(
      bloc: BlocProvider.of<EventBloc>(context),
      listener: (_,state){

      },
      builder: (_,state){
        Widget result = _buildTabBody(0);

        if(state is EventTabClick){
          int tabIndex = _getIndexFromState(state);
          result = _buildTabBody(tabIndex);
        }

        return result;
      },
    );
  }

  int _getIndexFromState(EventTabClick state){
    if(state is EventMainTabClick) return 0;
    else if(state is EventScheduleTabClick) return 1;
    else if(state is EventGalleryTabClick) return 2;
    return 3;
  }

  Widget _buildTabBody(int selectedIndex){
    return Center(child: Text('Index is ' + selectedIndex.toString()),);
  }

}