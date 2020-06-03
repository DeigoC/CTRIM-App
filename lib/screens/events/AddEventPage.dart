import 'package:ctrim_app_v1/blocs/EventBloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEventPage extends StatefulWidget {
  
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> with SingleTickerProviderStateMixin {
  
  TabController _tabController;
  TextEditingController _tecBody, _tecTitle;
  Orientation _orientation;
  
  EventBloc _eventBloc = EventBloc();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    _tecBody = TextEditingController();
    _tecTitle = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tecBody.dispose();
    _tecTitle.dispose();
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
                  Text('Title'),
                  TextField(
                    controller: _tecTitle,
                    onChanged: (newTitle){
                       _eventBloc.add(TextChangeEvent(
                        title: newTitle,
                        body: _tecBody.text,
                      ));
                    },
                  ),
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
                      _eventBloc.add(TabClickEvent(newIndex));
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
        if(state is EventEnableSaveButton) enableSaveButton = true;
      },
      buildWhen: (previousState, currentState){
        if(currentState is EventButtonChangeState) return true;
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

        },
        buildWhen: (previousState, currentState){
          if(currentState is EventDepartmentClickState) return true;
          else if(currentState is EventTabClick) return true;
          return false;
        },
        builder: (_,state){
          Widget result = _buildTabBody(0);

          if(state is EventTabClick){
            int selectedIndex = _getIndexFromState(state);
            result = _buildTabBody(selectedIndex);
          }

          return result;
        },
      );
    });
  }

  int _getIndexFromState(EventTabClick state){
    if(state is EventMainTabClick) return 0;
    else if(state is EventScheduleTabClick) return 1;
    else if(state is EventGalleryTabClick) return 2;
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

  ListView _buildMainTabBody(){
    return ListView(
      shrinkWrap: true,
      children: [
        SizedBox(height: 20,),
        Text('Departments'),
        Wrap(
          spacing: 8.0,
          children: _eventBloc.selectedDepartments.keys.map((department){
            String departmentString = _mapDepartmentToString(department);

            return FilterChip(
              label: Text(departmentString),
              selected: _eventBloc.selectedDepartments[department],
              onSelected: (newValue){
                _eventBloc.add(DepartmentClickEvent(department, newValue,));
              },
            );
          }).toList(),
        ),
        SizedBox(height: 20,),
        Text('Body'),
        SizedBox(height: 20,),
        TextField(
          controller: _tecBody,
          onChanged: (newBody){
           _eventBloc.add(TextChangeEvent(
              title: _tecTitle.text,
              body: newBody,
            ));
          },
        ),
      ],
    );
  }
  
  ListView _buildScheduleTabBody(){
    return ListView(
      shrinkWrap: true,
      children: [
        Text('Location'),
        FlatButton(
          child: Text('*INSERT ADDRESS HERE*'),
          onPressed: () => null,
        ),
        Text('Date'),
        Row(
          children: [
            FlatButton(
              child: Text('*INSERT DATE HERE*'),
              onPressed: () => null,
            ),
            Text(' AT '),
            FlatButton(
              child: Text('*INSERT TIME HERE*'),
              onPressed: () => null,
            ),
          ],
        ),
        Text('Duration'),
        FlatButton(
          child: Text('*INSERT DURATION HERE*'),
          onPressed: () => null,
        ),
      ],
    );
  }

  ListView _buildGalleryTabBody(){
    double pictureSize = MediaQuery.of(context).size.width * 0.32; // * 3 accross so 4% width left 0.04/4 = 0.01
        double paddingSize = MediaQuery.of(context).size.width * 0.01;
        if(_orientation == Orientation.landscape){
          // * 4 blocks accross so 5 paddings accross
          pictureSize = MediaQuery.of(context).size.width * 0.2375;
          paddingSize = MediaQuery.of(context).size.width * 0.01;
        }

    return ListView(
      children: [
        Wrap(
          children: [
            Padding(
              padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: pictureSize,
                height: pictureSize,
                color: Colors.red,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: pictureSize,
                height: pictureSize,
                color: Colors.green,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: pictureSize,
                height: pictureSize,
                color: Colors.purple,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: pictureSize,
                height: pictureSize,
                color: Colors.yellow,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: pictureSize,
                height: pictureSize,
                color: Colors.black,
              ),
            ),
          ],
        )
      ],
    );
  }

  String _mapDepartmentToString(Department department){
    String result;
    switch(department){
      case Department.CHURCH: result = 'Church';
      break;
      case Department.YOUTH: result = 'Youth';
      break;
      case Department.WOMEN: result = 'Women';
      break;
    }
    return result;
  }
}