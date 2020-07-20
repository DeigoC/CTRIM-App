import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/adminCheck.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
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
    _adminBloc = AdminBloc(BlocProvider.of<TimelineBloc>(context).allUsers,BlocProvider.of<AppBloc>(context));
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
      onWillPop: () {
        return ConfirmationDialogue.leaveEditPage(context: context);
      },
      child: BlocProvider<AdminBloc>(
        create: (_) => _adminBloc,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Edit User'),
            centerTitle: true,
          ),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    SizedBox padding = SizedBox(
      height: 8,
    );
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
          onTextChange: (newString) => _adminBloc
              .add(AdminUserModEditTextChangeEvent(forename: newString)),
        ),
        padding,
        MyTextField(
          label: 'Surname',
          controller: TextEditingController(text: widget.user.surname),
          hint: 'Required',
          onTextChange: (newString) => _adminBloc
              .add(AdminUserModEditTextChangeEvent(surname: newString)),
        ),
        padding,
        MyTextField(
          label: 'Contact No',
          controller: TextEditingController(text: widget.user.body),
          hint: 'Optional',
          onTextChange: (newString) => _adminBloc
              .add(AdminUserModEditTextChangeEvent(contactNo: newString)),
        ),
        _buildAdminLvlSelector(),
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
              listener: (_, state) {
                if (state is AdminUserModUpdateUserState) {}
              },
              buildWhen: (_, state) {
                if (state is AdminUserModEnableSaveButtonState)
                  return true;
                else if (state is AdminUserModDisableButtonState) return true;
                return false;
              },
              builder: (_, state) {
                return RaisedButton(
                  child: Text('Update User'),
                  onPressed: (state is AdminUserModEnableSaveButtonState)? () {
                    ConfirmationDialogue.saveRecord(
                      context: context,
                      record: 'User',
                      editing: true).then((confirmation) {
                      if (confirmation) {
                        BlocProvider.of<TimelineBloc>(context).add(TimelineUserUpdatedEvent(_adminBloc.selectedUser));
                        Navigator.of(context).pop();
                      }
                    });
                  }: null,
                  );
                })),
        padding,
        _buildDisableButton(),
      ],
    );
  }

  Widget _buildAdminLvlSelector(){
    if(AdminCheck.isCurrentUserAboveLvl2(context)){
      return Padding(
        padding: EdgeInsets.only(top: 8, left: 8),
        child: AdminDropdownList(),
      );
    }
    return Container();
  }

  Widget _buildDisableButton() {
    bool disabled = widget.user.disabled;
    if(AdminCheck.isCurrentUserAboveLvl2(context)){
      return RaisedButton(
        child: Text(disabled ? 'Enable User' : 'Disable User'),
        onPressed: (){
          ConfirmationDialogue.disableReenableUser(
            context: context,
            toDisable: !disabled
          ).then((confirmation){
            if(confirmation){
              var event = disabled ? TimelineUserEnabledEvent(widget.user) : TimelineUserDisabledEvent(widget.user);
              BlocProvider.of<TimelineBloc>(context).add(event);
              Navigator.of(context).pop();
            }
          });
        },
      );
    }
    return Container();
  }
}
