import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
import 'package:ctrim_app_v1/widgets/posts/galleryTabBody.dart';
import 'package:ctrim_app_v1/widgets/posts/mainTabBody.dart';
import 'package:ctrim_app_v1/widgets/posts/detailsTabBody.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> with SingleTickerProviderStateMixin {
  
  TabController _tabController;
  Orientation _orientation;
  TextEditingController _tecTitle;
  PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
     _tecTitle = TextEditingController();
    _postBloc = PostBloc();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tecTitle.dispose();
    _postBloc.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _postBloc,
        child: Scaffold(
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
                    MyTextField(
                      label: 'Title',
                      hint: 'e.g. Youth Day Out!',
                      controller: _tecTitle,
                      onTextChange: (newTitle) =>  _postBloc.add(PostTextChangeEvent(title: newTitle)),
                    ),
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
                        _postBloc.add(PostTabClickEvent(newIndex));
                      },
                    ),
                  ]),
                ),
              )
            ];
          },
          body: _buildBody(),
        ),
      ),
    );
  }

  BlocBuilder _buildAppBarActions(){
    return BlocBuilder<PostBloc, PostState>(
      condition: (previousState, currentState){
        if(currentState is PostButtonChangeState) return true;
        return false;
      },
      builder: (_,state){
        Widget result = RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0)
          ),
          onPressed: (state is PostEnableSaveButtonState) ? () => null:null,
          child: Text('Save',),
        );
        return result;
      },
    );
  }
 
  OrientationBuilder _buildBody(){
    return OrientationBuilder(
      builder: (_,orientation){
        _orientation = orientation;
        return BlocConsumer<PostBloc, PostState>(
        listener: (_, state){
          if(state is PostSelectDateState) _selectEventDate();
          else if(state is PostSelectTimeState) _selectEventTime();
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
      case 0: return MainTabBody();
      case 1: return PostDetailsTabBody();
      case 2: return GalleryTabBody(_orientation);
    }
    return Center(child: Text('Index is ' + selectedIndex.toString()),);
  }

  Future<void> _selectEventDate() async{
    DateTime pickedDate;
    pickedDate = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime.now().subtract(Duration(days: 1000)), 
      lastDate:  DateTime.now().add(Duration(days: 1000)),
    );
    _postBloc.add(PostSetPostDateEvent(pickedDate));
  }

  Future<void> _selectEventTime() async{
    TimeOfDay pickedTime;
    pickedTime = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.now()
    );
    _postBloc.add(PostSetPostTimeEvent(pickedTime));
  }
}