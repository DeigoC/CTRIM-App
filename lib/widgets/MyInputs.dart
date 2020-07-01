import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminDropdownList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Admin Level'),
        SizedBox(
          width: 8,
        ),
        BlocBuilder<AdminBloc, AdminState>(condition: (_, state) {
          if (state is AdminUserAdminLevelChangedState) return true;
          return false;
        }, builder: (_, state) {
          return DropdownButton<int>(
            hint: Text('Required'),
            value: BlocProvider.of<AdminBloc>(context).selectedUser.adminLevel,
            items: [1, 2, 3].map((item) {
              return DropdownMenuItem<int>(
                child: Text('Lvl $item'),
                value: item,
              );
            }).toList(),
            onChanged: (newValue) {
              BlocProvider.of<AdminBloc>(context)
                  .add(AdminUserAdminLevelChangeEvent(newValue));
            },
          );
        }),
      ],
    );
  }
}

class MyTextField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final Function(String) onTextChange;
  final bool readOnly;
  final int maxLength, maxLines;
  final TextInputAction textInputAction;

  MyTextField({
    @required this.label,
    @required this.controller,
    this.onTextChange,
    this.hint,
    this.readOnly = false,
    this.maxLength,
    this.maxLines,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,),
          TextField(
            controller: controller,
            onChanged: onTextChange,
            readOnly: readOnly,
            maxLength: maxLength,
            maxLines: maxLines,
            textInputAction: textInputAction,
            decoration: InputDecoration(hintText: hint ?? ''),
          ),
        ],
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  final String label;
  final bool value, leftToRight;
  final Function(bool) onChanged;

  MyCheckBox({
    @required this.label,
    @required this.value,
    @required this.onChanged,
    this.leftToRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          leftToRight ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: leftToRight ? _buildLeftToRight() : _buildRightToLeft(),
    );
  }

  List<Widget> _buildLeftToRight() {
    return [
      Text(label),
      SizedBox(
        width: 8,
      ),
      Checkbox(value: value, onChanged: onChanged)
    ];
  }

  List<Widget> _buildRightToLeft() {
    return [
      Text(label),
      SizedBox(
        width: 8,
      ),
      Checkbox(value: value, onChanged: onChanged)
    ];
  }
}
