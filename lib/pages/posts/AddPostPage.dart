import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/widgets/events/galleryTabBody.dart';
import 'package:ctrim_app_v1/widgets/events/mainTabBody.dart';
import 'package:ctrim_app_v1/widgets/events/scheduleTabBody.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEventPage extends StatefulWidget {
  
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> with SingleTickerProviderStateMixin {
  
  TabController _tabController;
  Orientation _orientation;

  PostBloc _eventBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    _eventBloc = PostBloc();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventBloc.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: NestedScrollView(
        headerSliverBuilder: (_,__){
          return [
            SliverAppBar(
              expandedHeight: 200,
              actions: [
                _buildAppBarActions(),
              ],
            ),
            SliverPadding(
              padding:  EdgeInsets.all(8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  TabBar(
                    labelColor: Colors.black,
                    controller: _tabController,
                    tabs: [
                      Tab(icon: Icon(Icons.info_outline), text: 'About',),
                      Tab(icon: Icon(Icons.calendar_today), text: 'Details',),
                      Tab(icon: Icon(Icons.photo_library), text: 'Gallery',),
                      Tab(icon: Icon(Icons.track_changes), text: 'Updates',),
                    ],
                    onTap: (newIndex){
                      _eventBloc.add(PostTabClickEvent(newIndex));
                    },
                  ),
                ]),
              ),
            )
          ];
        },
        body: _buildBody(),
      ),
    );
  }

  BlocConsumer _buildAppBarActions(){
    bool enableSaveButton = false;
    return BlocConsumer(
      bloc: _eventBloc,
      listener: (_,state){
        enableSaveButton = false;
        if(state is PostEnableSaveButtonState) enableSaveButton = true;
      },
      buildWhen: (previousState, currentState){
        if(currentState is PostButtonChangeState) return true;
        return false;
      },
      builder: (_,state){
        Widget result = FlatButton(
          onPressed: (){

          },
          child: Text('Save', style: TextStyle(color: enableSaveButton ? Colors.black : Colors.grey),),
        );

        return result;
      },
    );
  }
 
  OrientationBuilder _buildBody(){
    return OrientationBuilder(
      builder: (_,orientation){
        _orientation = orientation;
        return BlocConsumer(
        bloc: _eventBloc,
        listener: (_, state){
          //TODO add the dialogues here
          if(state is PostSelectDateState){
            _selectEventDate();
          }else if(state is PostSelectTimeState){
            _selectEventTime();
          }
        },
        buildWhen: (previousState, currentState){
        if(currentState is PostTabClickState) return true;
          return false;
        },
        builder: (_,state){
          Widget result = _buildTabBody(0);

          if(state is PostTabClickState){
            int selectedIndex = _getIndexFromState(state);
            result = _buildTabBody(selectedIndex);
          }

          return result;
        },
      );
    });
  }

  int _getIndexFromState(PostTabClickState state){
    if(state is PostAboutTabClickState) return 0;
    else if(state is PostDetailsTabClickState) return 1;
    else if(state is PostGalleryTabClickState) return 2;
    return 3;
  }

  Widget _buildTabBody(int selectedIndex){
    switch(selectedIndex){
      case 0: return _buildMainTabBody();
      break;
      case 1: return _buildScheduleTabBody();
      break;
      case 2: return _buildGalleryTabBody();
    }
    return Center(child: Text('Index is ' + selectedIndex.toString()),);
  }

  MainTabBody _buildMainTabBody(){
    return  MainTabBody(_eventBloc);
  }
  
  ScheduleTabBody _buildScheduleTabBody(){
    return ScheduleTabBody(_eventBloc);
  }

  GalleryTabBody _buildGalleryTabBody(){
    return GalleryTabBody(_orientation);
  }

  Future<void> _selectEventDate() async{
    DateTime pickedDate;
    pickedDate = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime.now().subtract(Duration(days: 1000)), 
      lastDate:  DateTime.now().add(Duration(days: 1000)),
    );
    _eventBloc.add(PostSetPostDateEvent(pickedDate));
  }

  Future<void> _selectEventTime() async{
    TimeOfDay pickedTime;
    pickedTime = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.now()
    );
    _eventBloc.add(PostSetPostTimeEvent(pickedTime));
  }
}