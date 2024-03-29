import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/style.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/helpDialogTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';

class AdminDropdownList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('Admin Level',style: TextStyle(fontSize: 18),),
            SizedBox( width: 8,),
            BlocBuilder<AdminBloc, AdminState>(
              buildWhen: (_, state) {
                if (state is AdminUserAdminLevelChangedState) return true;
                return false;
            }, builder: (_, state) {
              return DropdownButton<int>(
                style: TextStyle(
                  fontSize: 18,
                  color: BlocProvider.of<AppBloc>(context).onDarkTheme ? Colors.white:Colors.black
                ),
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
        ),
        Padding(
          padding: EdgeInsets.only(right:8.0),
          child: IconButton(
            icon: Icon(AntDesign.questioncircleo),
            onPressed: (){
              showDialog(
                context: context,
                builder: (_){
                  return HelpDialogTile(
                    title: 'Admin Level (Required)',
                    subtitle: 'Level 3 gives access to all editable aspects. \nLevel 2 is a reduction of level 3.' +
                    '\nLevel 1 has the least amount of access. Only allowed to add/edit their posts',
                  );
                }
              );
            },
          ),
        )
      ],
    );
  }
}

class MyTextField extends StatelessWidget {
  final String label, hint, helpText;
  final TextEditingController controller;
  final Function(String) onTextChange;
  final bool readOnly,autoFocus, obsucureText, optional, buildHelpIcon, centerLabel;
  final int maxLength, maxLines;
  final TextInputAction textInputAction;
  final TextInputType textInputType;

  MyTextField({
    @required this.label,
    @required this.controller,
    this.onTextChange,
    this.hint,
    this.readOnly = false,
    this.autoFocus = false,
    this.obsucureText = false,
    this.maxLength,
    this.maxLines,
    this.textInputAction = TextInputAction.done,
    this.textInputType,
    this.optional = false,
    this.buildHelpIcon = true,
    this.centerLabel = false,
    this.helpText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label + ((optional) ? '':'*') ,
            style: TextStyle(fontSize: 18), 
            textAlign: centerLabel?TextAlign.center : null,
          ),
          TextField(
            controller: controller,
            onChanged: onTextChange,
            readOnly: readOnly,
            maxLength: maxLength,
            autofocus: autoFocus,
            maxLines: obsucureText?1:maxLines,
            obscureText: obsucureText,
            textInputAction: textInputAction,
            keyboardType: textInputType,
            decoration: InputDecoration(
              hintText: hint ?? '',
              suffixIcon: buildHelpIcon ? IconButton(
                icon: Icon(AntDesign.questioncircleo,color: Theme.of(context).iconTheme.color,),
                onPressed: (){
                  _showHelpDialog(context);
                },
              ):null,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) async{
    //FocusScope.of(context).requestFocus(FocusNode());
    await showDialog(
      context: context,
      builder: (_){
        return HelpDialogTile(
          title: label + ((optional) ? '':' (Required)'),
          subtitle: helpText??'N/A',
        );
      }
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
    return InkWell(
      onTap: (){
        onChanged(!value);
      },
      child: Row(
        mainAxisAlignment: boxLeftToRight ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: boxLeftToRight ? _buildLeftToRight() : _buildRightToLeft(),
      ),
    );
  }

  List<Widget> _buildLeftToRight() {
    return [
      Checkbox(value: value, onChanged: onChanged,activeColor: LightSecondaryColor,),
      Text(label,),
    ];
  }

  List<Widget> _buildRightToLeft() {
    return [
      Text(label),
      SizedBox(width: 8,),
      Checkbox(value: value, onChanged: onChanged,activeColor: LightSecondaryColor,)
    ];
  }
}

class MyRaisedButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final EdgeInsets externalPadding;
  final IconData icon;
  final bool isDestructive;
  final double fontsize;

  const MyRaisedButton({
    @required this.label,
    @required this.onPressed,
    this.externalPadding,
    this.icon,
    this.isDestructive = false,
    this.fontsize,
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
      color: isDestructive ? Color(0xffd11a2a):null,
      child: Text(label,style: TextStyle(fontSize: fontsize),),
      onPressed: onPressed,
    );
  }

  RaisedButton _buildIconButton(){
    return RaisedButton.icon(
      onPressed: onPressed, 
      icon: Icon(icon,color: Colors.white,), 
      label: Text(label,style: TextStyle(fontSize: fontsize),)
    );
  }
}

class MyFlatButton extends StatelessWidget {
   final String label;
  final Function onPressed;
  final EdgeInsets externalPadding, internalPadding;
  final IconData icon;
  final bool border, isDestructive;
  final double fontSize;
  final TextStyle _disabledText = TextStyle(color: Color(0xffb3b3b3));
  
   MyFlatButton({
    @required this.label,
    @required this.onPressed,
    this.externalPadding,
    this.icon,
    this.border = false,
    this.isDestructive = false,
    this.internalPadding,
    this.fontSize,
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
      disabledColor: Color(0xff676767),
      padding: internalPadding,
      disabledTextColor: Colors.grey,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: border&&!disabled ? Colors.blue:Colors.transparent),
        borderRadius: BorderRadius.circular(18)
      ),
      child: Text(label,style: disabled? _disabledText: 
      TextStyle(
        color: isDestructive ? Color(0xffd11a2a): Colors.blue,
        fontSize: fontSize,
      ),
      textAlign: TextAlign.center,
      ),
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
      checkmarkColor: Colors.white,
      onSelected: onSelected,
      selected: selected,
    );
  }
}

class MyDropdownList extends StatelessWidget {
  
  final String value;
  final Function(String) onChanged;
  final List<String> items;
  final String label;
  final bool disable;

  MyDropdownList({
    @required this.value,
    @required this.onChanged,
    @required this.items,
    this.label,
    this.disable = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: disable,
      child: Row(
        children: <Widget>[
          Text(label,style: TextStyle(fontSize: 18),),
          SizedBox(width: 8,),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items.map((value){
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class MySearchBar extends StatelessWidget {
  
  final Function onTap;
  final Function(String) onSubmitted;
  final FocusNode focusNode;
  final String hint;

  MySearchBar({
    @required this.focusNode,
    @required this.onSubmitted,
    this.onTap,
    this.hint,
  });
  
  @override
  Widget build(BuildContext context) {
    bool onDark = BlocProvider.of<AppBloc>(context).onDarkTheme;
    
    return Expanded(
      child: TextField(
        onTap: onTap,
        onSubmitted: onSubmitted,
        focusNode: focusNode,
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.search,),
          hintText: hint??'',
          border: OutlineInputBorder(borderSide: BorderSide.none),
          filled: true,
          fillColor: onDark ? Color(0xff383838) : Colors.white,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        ),
      ),
    );
  }
}