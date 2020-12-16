import 'dart:io';

import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/socialLinks.dart';
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
  AdminBloc _adminBloc;
  File _imageFile;
  TextEditingController _tecRole;

  @override
  void initState() {
    User originalU = BlocProvider.of<AppBloc>(context).currentUser;
    _user = User(
      role: originalU.role,
      id: originalU.id,
      forename: originalU.forename,
      surname: originalU.surname,
      socialLinks: Map<String,String>.from(originalU.socialLinks),
      likedPosts: List.from(originalU.likedPosts),
      body: originalU.body,
      imgSrc: originalU.imgSrc
    );
    _adminBloc = AdminBloc(BlocProvider.of<AppBloc>(context));
    _adminBloc.setupUserToEdit(originalU);
   
    _tecRole = TextEditingController(text: _user.roleString);
    super.initState();
  }

  @override
  void dispose() { 
    _tecRole.dispose();
    _adminBloc.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        bool result = false;
        await ConfirmationDialogue().saveRecord(
          editing: true, discardOption: true, context: context,record: 'User details').then((_){
          if(_ != null){
            if(_){
              _user.role = _tecRole.text.trim();
              _adminBloc.add(AdminSaveMyDetailsEvent(
                file: _imageFile,
                hasDeletedSrc: _user.imgSrc=='',
                role: _tecRole.text,
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
        appBar: AppBar(title: Text('Edit my Data'),),
        body: BlocListener(
          cubit: _adminBloc,
          listener: (_,state){
            if(state is AdminUserImageUploadingState){
              ConfirmationDialogue().uploadTaskStarted(context: context);
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
    return ListView(
      children: [
        _buildUserImageControls(),
        SizedBox(height: 8,),
        Text(_user.forename + ' ' + _user.surname, textAlign: TextAlign.center, style: TextStyle(fontSize: 24),),
        Text('(Contact other admins to modify name.)', textAlign: TextAlign.center,),
        MyFlatButton(
          label: 'View viable admins',
          onPressed: (){
            showDialog(
              context: context,
              builder: (_){
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)
                  ),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: _buildLevel3UserList(),
                  ),
                );
              }
            );
          },
        ),
        SizedBox(height: 32,),
        MyTextField(
          label: 'Role',
          optional: true,
          buildHelpIcon: false,
          centerLabel: true,
          controller: _tecRole,
        ),
        SizedBox(height: 32,),
        Text('Social Links / Contacts', textAlign: TextAlign.center, style: TextStyle(fontSize: 18),),
        SizedBox(height: 8,),
        Column(
          children: [
            BlocBuilder(
              cubit: _adminBloc,
              buildWhen: (_,state){
                if(state is AdminUserRebuildSocialLinkState) return true;
                return false;
              },
              builder:(_,state)=> SocialLinksDisplay(_adminBloc.selectedUser.socialLinks)),
            SizedBox(height: 8,),
            MyRaisedButton(
              label: 'Edit Social Links',
              onPressed: (){
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_){
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: SocialLinksEdit(_adminBloc),
                        ),
                      ),
                    );
                  }
                );
                
              },
            )
          ],
        ),
        SizedBox(height: 32,),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildUserBodySection(),
        ),
        MyRaisedButton(
          externalPadding: EdgeInsets.all(8),
          label: 'Edit Text',
          onPressed: (){
            BlocProvider.of<AppBloc>(context).add(AppToEditUserBodyPageEvent(_adminBloc));
          },
        ),
        SizedBox(height: 8,),
      ],
    );
  }

  Widget _buildLevel3UserList(){
    return FutureBuilder<List<User>>(
      future: BlocProvider.of<TimelineBloc>(context).fetchLevel3Users(),
      builder: (_,snap){
        Widget result;

        if(snap.hasData){
          result = Column(
            children: [
              Text('Users able to modify details:',style: TextStyle(fontSize: 18),),
              SizedBox(height: 8,),
              Expanded(
                child: ListView.builder(
                  itemCount: snap.data.length,
                  itemBuilder: (_,index){
                    User u = snap.data[index];
                    return ListTile(
                      title: Text(u.forename + ' ' + u.surname),
                      leading: u.buildAvatar(context),
                      subtitle: Text('Lvl: ' + u.adminLevel.toString())
                    );
                  }
                ),
              ),
            ],
          );
        }else if(snap.hasError){
          result = Center(child: Text('Something went wrong!'),);
        }else{
          result = Center(child: CircularProgressIndicator());
        }

        return result;
      },
    );
  }

  Widget _buildUserBodySection(){
    return BlocBuilder(
      cubit: _adminBloc,
      buildWhen: (_,state){
        if(state is AdminUserRebuildBodyState) return true;
        return false;
      },
      builder: (_,state) => ZefyrView(document: _adminBloc.selectedUser.getBodyDoc(),),
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
                  ConfirmationDialogue().deleteRecord(context: context, record: 'image').then((confirmation){
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
    FilePickerResult result;
    result = await FilePicker.platform.pickFiles(type: FileType.image,);
    return File(result.files.first.path);
  }
}