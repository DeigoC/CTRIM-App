import 'package:ctrim_app_v1/blocs/EventBloc/event_bloc.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainTabBody extends StatefulWidget {
  
  final EventBloc _eventBloc;

  MainTabBody(this._eventBloc);

  @override
  _MainTabBodyState createState() => _MainTabBodyState();
}

class _MainTabBodyState extends State<MainTabBody> {
  
   TextEditingController _tecBody, _tecSubtitle;

  @override
  void initState() {
    super.initState();
    _tecBody = TextEditingController();
    _tecSubtitle = TextEditingController();
  }

  @override
  void dispose() { 
    _tecBody.dispose();
    _tecSubtitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        SizedBox(height: 20,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Departments'),
               BlocBuilder(
                bloc: widget._eventBloc,
                condition: (_,state){
                  if(state is EventDepartmentClickState) return true;
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
                        widget._eventBloc.add(DepartmentClickEvent(department, newValue,));
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
        BlocBuilder(
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
        ),
         SizedBox(height: 20,),
        MyTextField(
          controller: _tecSubtitle,
          label: 'Subtitle',
          hint: '(Optional)',
          onTextChange: (newSubtitle) => null,
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