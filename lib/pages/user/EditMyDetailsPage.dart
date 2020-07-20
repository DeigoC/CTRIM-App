import 'dart:io';

import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zefyr/zefyr.dart';

class EditMyDetailsPage extends StatefulWidget {
  @override
  _EditMyDetailsPageState createState() => _EditMyDetailsPageState();
}

class _EditMyDetailsPageState extends State<EditMyDetailsPage> {
  
  User _user;
  ZefyrController _textController;
  FocusNode _fnBody;
  AdminBloc _adminBloc;
  File _imageFile;

  @override
  void initState() {
    User originalU = BlocProvider.of<AppBloc>(context).currentUser;
    _user = User(
      id: originalU.id,
      forename: originalU.forename,
      surname: originalU.surname,
      body: originalU.body,
      imgSrc: originalU.imgSrc
    );
    _adminBloc = AdminBloc(BlocProvider.of<TimelineBloc>(context).allUsers,BlocProvider.of<AppBloc>(context));
    _adminBloc.setupUserToEdit(originalU);

    _fnBody = FocusNode();
    _textController = ZefyrController(_user.getBodyDocument());
    super.initState();
  }

  @override
  void dispose() { 
    _fnBody.dispose();
    _textController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        bool result = false;
        await ConfirmationDialogue.saveRecord(
          editing: true, discardOption: true, context: context,record: 'User details').then((_){
          if(_ != null){
            if(_){
              _adminBloc.add(AdminSaveMyDetailsEvent(
                document: _textController.document,
                file: _imageFile,
                hasDeletedSrc: _user.imgSrc=='',
              ));
                result = false;
            }else{
              // ! Discards the changes
              result = true;
            }
          }
        });
        return result;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Edit my data'),),
        body: BlocListener(
          bloc: _adminBloc,
          listener: (_,state){
            if(state is AdminUserImageUploadingState){
              ConfirmationDialogue.uploadTaskStarted(context: context);
            }else if(state is AdminUserImageUploadCompleteState){
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }else if(state is AdminUserModUpdateUserState){
              BlocProvider.of<AppBloc>(context).setCurrentUser(state.updatedUser);
            }
          },
          child: _buildBody()
        ),
      ),
    );
  }

  Widget _buildBody(){
    return ZefyrScaffold(
      child: ListView(
        children: [
          _buildUserImageControls(),
          SizedBox(height: 8,),
          Text(_user.forename + ' ' + _user.surname, textAlign: TextAlign.center, style: TextStyle(fontSize: 24),),
          Text('(Contact users of higher admin levels to modify name.)', textAlign: TextAlign.center,),
          SizedBox(height: 32,),
          Text('Edit your details. The first lines visible in the box will be displayed.', textAlign: TextAlign.center,),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(16)
              ),
              width: double.infinity,
              height: 150,
                child: ZefyrEditor(
                mode: ZefyrMode.edit,
                controller: _textController,
                focusNode: _fnBody,
                autofocus: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserImageControls(){
    return Container(
      padding: EdgeInsets.all(8),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(flex: 2,),
          _buildUserImageContainer(),
          Column(
            children: [
              IconButton(icon: Icon(Icons.add_photo_alternate),onPressed: (){
                _pickImgFile().then((file) { setState(() {_imageFile = file;});} );
              },),
              IconButton(icon: Icon(Icons.delete_outline),onPressed: (){
                if(_user.imgSrc != '' && _imageFile == null){
                  // ! Confimation message
                  ConfirmationDialogue.deleteRecord(context: context, record: 'image').then((confirmation){
                    if(confirmation){
                       setState(() {_user.imgSrc = '';});
                    }
                  });
                }else{setState(() {_imageFile = null;});}
              },),
            ],
          ),
          Spacer(flex: 1,),
        ],
      )
    );
  }

  Widget _buildUserImageContainer(){
    double imageSize =  MediaQuery.of(context).size.width * 0.5;
     if(_imageFile != null){
      return Container(
        width: imageSize,
        height:imageSize, 
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: FileImage(_imageFile), fit: BoxFit.cover)
        ),
      );
    }else if(_user.imgSrc != ''){
      return Container(
        width: imageSize,
        height:imageSize, 
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: NetworkImage(_user.imgSrc), fit: BoxFit.cover)
        ),
      );
    }
    return Container(
      height:imageSize, 
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle
      ),
      width:imageSize,
      child: Center(child: Text(_user.forename[0] + _user.surname[0],style: TextStyle(fontSize: 28),)),
    );
  }

  Future<File> _pickImgFile() async{
    File result;
    result = await FilePicker.getFile(type: FileType.image,);
    return result;
  }
}