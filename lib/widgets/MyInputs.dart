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
  final bool value, boxLeftToRight;
  final Function(bool) onChanged;

  MyCheckBox({
    @required this.label,
    @required this.value,
    @required this.onChanged,
    this.boxLeftToRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          boxLeftToRight ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: boxLeftToRight ? _buildLeftToRight() : _buildRightToLeft(),
    );
  }

  List<Widget> _buildLeftToRight() {
    return [
      Checkbox(value: value, onChanged: onChanged),
      //SizedBox(width: 8,),
      Text(label),
    ];
  }

  List<Widget> _buildRightToLeft() {
    return [
      Text(label),
      SizedBox(width: 8,),
      Checkbox(value: value, onChanged: onChanged)
    ];
  }
}

class MyRaisedButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final EdgeInsets externalPadding;
  final IconData icon;

  const MyRaisedButton({
    @required this.label,
    @required this.onPressed,
    this.externalPadding,
    this.icon,
    Key key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: externalPadding??EdgeInsets.zero,
      child: icon==null?_buildNormalButton():_buildIconButton(),
    );
  }

  RaisedButton _buildNormalButton(){
    return RaisedButton(
      child: Text(label),
      onPressed: onPressed,
    );
  }

  RaisedButton _buildIconButton(){
    return RaisedButton.icon(
      onPressed: onPressed, 
      icon: Icon(icon,color: Colors.white,), 
      label: Text(label,)
    );
  }
}

class MyFlatButton extends StatelessWidget {
   final String label;
  final Function onPressed;
  final EdgeInsets externalPadding;
  final IconData icon;
  final bool border;
  final TextStyle _disabledText = TextStyle(color: Colors.white);
  
   MyFlatButton({
    @required this.label,
    @required this.onPressed,
    this.externalPadding,
    this.icon,
    this.border = false,
    Key key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return Padding(
      padding: externalPadding??EdgeInsets.zero,
      child: icon==null?_buildNormalButton():_buildIconButton(),
    );
  }

  FlatButton _buildNormalButton(){
    bool disabled = onPressed==null;
    return FlatButton(
      disabledColor: Colors.grey,
      disabledTextColor: Colors.grey,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: border&&!disabled ? Colors.blue:Colors.transparent),
        borderRadius: BorderRadius.circular(18)
      ),
      child: Text(label,style: disabled? _disabledText: TextStyle(color: Colors.blue),),
      onPressed: onPressed,
    );
  }

  FlatButton _buildIconButton(){
    return FlatButton.icon(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: border ? Colors.blue:Colors.transparent),
        borderRadius: BorderRadius.circular(18)
      ),
      onPressed: onPressed, 
      icon: Icon(icon,color: Colors.blue,), 
      label: Text(label,style: TextStyle(color: Colors.blue),)
    );
  }
}

class MyFilterChip extends StatelessWidget {
  final String label;
  final bool selected, filteringPosts;
  final Function(bool) onSelected;

  MyFilterChip({
    @required this.label,
    @required this.selected,
    @required this.onSelected, 
    this.filteringPosts = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      backgroundColor: filteringPosts ? null : Colors.grey,
      label: Text(label),
      onSelected: onSelected,
      selected: selected,
    );
  }
}