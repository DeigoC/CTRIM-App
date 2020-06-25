import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/models/confirmationDialogue.dart';
import 'package:ctrim_app_v1/models/user.dart';
import 'package:ctrim_app_v1/widgets/generic/MyDropdownList.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditUserPage extends StatefulWidget {

  final User user;
  EditUserPage(this.user);
  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  
  AdminBloc _adminBloc;

  @override
  void initState() {
    _adminBloc = AdminBloc(BlocProvider.of<TimelineBloc>(context).allUsers);
    _adminBloc.setupUserToEdit(widget.user);
    super.initState();
  }

  @override
  void dispose() { 
    _adminBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        return ConfirmationDialogue.leaveEditPage(context: context);
      },
          child: BlocProvider<AdminBloc>(
        create: (_) => _adminBloc,
        child: Scaffold(
          appBar: AppBar(title: Text('Edit User'),centerTitle: true,),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody(){
    SizedBox padding = SizedBox(height: 8,);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('ID: ' + _adminBloc.selectedUser.id),
        ),
        padding,
        MyTextField(
          label: 'Forename',
          controller: TextEditingController(text: widget.user.forename),
          hint: 'Required',
          onTextChange: (newString) => _adminBloc.add(AdminUserModEditTextChangeEvent(forename: newString)),
        ),
        padding,
        MyTextField(
          label: 'Surname',
          controller: TextEditingController(text: widget.user.surname),
          hint: 'Required',
          onTextChange: (newString) => _adminBloc.add(AdminUserModEditTextChangeEvent(surname: newString)),
        ),
        padding,
        MyTextField(
          label: 'Contact No',
          controller: TextEditingController(text: widget.user.contactNo),
          hint: 'Optional',
          onTextChange: (newString) => _adminBloc.add(AdminUserModEditTextChangeEvent(contactNo: newString)),
        ),
        padding,
        Padding(
          padding: const EdgeInsets.only(left:8.0),
          child: AdminDropdownList(),
        ),
        padding,
        MyTextField(
          label: 'Email',
          controller: TextEditingController(text: widget.user.email),
          hint: 'Required',
          readOnly: true,
        ),
        padding,
         Container(
         padding: EdgeInsets.all(8),
         child: BlocConsumer(
           bloc: _adminBloc,
           listener: (_,state){
             if(state is AdminUserModUpdateUser){
              
             }
           },
           buildWhen: (_,state){
             if(state is AdminUserModEnableSaveButtonState) return true;
             else if(state is AdminUserModDisableButtonState) return true;
             return false;
           },
            builder:(_,state){
            return RaisedButton(
             child: Text('Register User'),
             onPressed:(state is AdminUserModEnableSaveButtonState) ? (){
                ConfirmationDialogue.saveRecord(context: context, record: 'User', editing: true).then((confirmation){
                 if(confirmation){
                  BlocProvider.of<TimelineBloc>(context).add(TimelineUserUpdatedEvent(_adminBloc.selectedUser));
                  Navigator.of(context).pop();
                 }
               });
             }: null,
           );
          }
         )
       )
      ],
    );
  }
}