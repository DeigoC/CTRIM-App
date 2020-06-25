import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminDropdownList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Admin Level'),
        SizedBox(width: 8,),
        BlocBuilder<AdminBloc, AdminState>(
          condition: (_,state){
            if(state is AdminUserAdminLevelChangedState) return true;
            return false;
          },
        builder: (_,state){
          return DropdownButton<int>(
            hint: Text('Required'),
            value:  BlocProvider.of<AdminBloc>(context).selectedUser.adminLevel,
            items: [1,2,3].map((item){
              return DropdownMenuItem<int>(
                child: Text('Lvl $item'),
                value: item,
              );
            }).toList(),
            onChanged: (newValue){
              BlocProvider.of<AdminBloc>(context).add(AdminUserAdminLevelChangeEvent(newValue));
            },
          );
        }
        ),
      ],
    );
  }
}