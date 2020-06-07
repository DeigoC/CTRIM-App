import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zefyr/zefyr.dart';

class MainTabBody extends StatefulWidget {
  
  final PostBloc _eventBloc;

  MainTabBody(this._eventBloc);

  @override
  _MainTabBodyState createState() => _MainTabBodyState();
}

class _MainTabBodyState extends State<MainTabBody> {
  
   TextEditingController _tecBody, _tecSubtitle, _tecTitle;

  @override
  void initState() {
    super.initState();
    _tecBody = TextEditingController();
    _tecSubtitle = TextEditingController();
    _tecTitle = TextEditingController();
  }

  @override
  void dispose() { 
    _tecBody.dispose();
    _tecSubtitle.dispose();
    _tecTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Departments'),
               BlocBuilder(
                bloc: widget._eventBloc,
                condition: (_,state){
                  if(state is PostDepartmentClickState) return true;
                  return false;
                },
                builder:(_,state){
                  return Wrap(
                  spacing: 8.0,
                  children: widget._eventBloc.selectedDepartments.keys.map((department){
                    String departmentString = _mapDepartmentToString(department);

                    return FilterChip(
                      label: Text(departmentString),
                      selected: widget._eventBloc.selectedDepartments[department],
                      onSelected: (newValue){
                        widget._eventBloc.add(PostDepartmentClickEvent(department, newValue,));
                      },
                    );
                  }).toList(),
                  );
                } 
              ),
            ],
          ),
        ),
        SizedBox(height: 20,),
         MyTextField(
          label: 'Title',
          hint: 'e.g. Youth Day Out!',
          controller: _tecTitle,
          onTextChange: (newTitle) => widget._eventBloc.add(PostTextChangeEvent(title: newTitle)),
        ),
        SizedBox(height: 20,),
        MyTextField(
          controller: _tecSubtitle,
          label: 'Subtitle',
          hint: '(Optional)',
          onTextChange: (newSubtitle) => null,
        ),
        SizedBox(height: 20,),
        /* BlocBuilder(
          bloc: widget._eventBloc,
          condition: (previousState, currentState){
            if(currentState is EventMainTabClick) return true;
            return false;
          },
          builder:(_, state){
            _tecBody.text = widget._eventBloc.eventBody;
            return MyTextField(
              label: 'Body',
              hint: '(Remember: date and location are at the next tab)',
              controller: _tecBody,
              onTextChange: (newBody) => widget._eventBloc.add(TextChangeEvent(body: newBody))
            );
          } 
        ), */
        BlocBuilder(
          bloc: widget._eventBloc,
          condition: (previousState, currentState){
            if(currentState is PostUpdateBodyState) return true;
            return false;
          },
          builder:(_,state){
            return Container(
            /* width: double.infinity,
            height: 300, */
            padding: EdgeInsets.all(8),
            child:ZefyrView(document: widget._eventBloc.getEditorDoc())
            /*  ZefyrScaffold(
              child: ZefyrEditor(
                mode: ZefyrMode.view,
                controller: ZefyrController(widget._eventBloc.getEditorDoc()),
                padding: EdgeInsets.all(16),
                focusNode: FocusNode(),
              ),
            ), */
          );
        }
        ),
         SizedBox(height: 20,),
        
        Container(
          padding: EdgeInsets.all(8),
          child: RaisedButton(
            onPressed: (){

            },
            child: Text('Preview Page'),
          ),
        ),
        Container(
          padding: EdgeInsets.all(8),
          child: RaisedButton(
            onPressed: (){
              BlocProvider.of<AppBloc>(context).add(AppToPostBodyEditorEvent(widget._eventBloc));
            },
            child: Text('Editor Page'),
          ),
        ),
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