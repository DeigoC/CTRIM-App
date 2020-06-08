import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostDateTimeField extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
     return BlocBuilder<PostBloc, PostState>(
         condition: (previousState, currentState){
           if(currentState is PostScheduleState) return true;
           return false;
         },
          builder:(_,state){
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date'),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                       FlatButton(
                        child: Text(BlocProvider.of<PostBloc>(context).getSelectedDateString),
                        onPressed: () => BlocProvider.of<PostBloc>(context).add(PostSelectPostDateEvent()),
                      ),
                        Text(' AT '),
                        FlatButton(
                          child: Text( BlocProvider.of<PostBloc>(context).getSelectedTimeString),
                          onPressed: () =>  BlocProvider.of<PostBloc>(context).add(PostSelectPostTimeEvent()),
                        ),
                         MyCheckBox(
                          label: 'Date Not Applicable',
                          onChanged: (newValue) => BlocProvider.of<PostBloc>(context).add(PostDateNotApplicableClick()) ,
                          value:  BlocProvider.of<PostBloc>(context).getIsDateNotApplicable,
                        )
                    ],
                  ),
              ],),
            );
          } 
       );
  }
}

class PostLocationField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text('Location'),
            FlatButton(
              child: Text('PENDING LOCATION'),
              onPressed: () => BlocProvider.of<AppBloc>(context).add(AppToSelectLocationForPostEvent()),
            ),
        ],
      ),
    );
  }
}

class PostDepartmentField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Departments'),
              BlocBuilder<PostBloc, PostState>(
              condition: (_,state){
                if(state is PostDepartmentClickState) return true;
                return false;
              },
              builder:(_,state){
                return Wrap(
                spacing: 8.0,
                children:  BlocProvider.of<PostBloc>(context).selectedDepartments.keys.map((department){
                  String departmentString = _mapDepartmentToString(department);
                  return FilterChip(
                    label: Text(departmentString),
                    selected:  BlocProvider.of<PostBloc>(context).selectedDepartments[department],
                    onSelected: (newValue){
                        BlocProvider.of<PostBloc>(context).add(PostDepartmentClickEvent(department, newValue,));
                    },
                  );
                }).toList(),
                );
              } 
            ),
          ],
        ),
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