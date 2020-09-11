import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmationDialogue{

  Future<bool> userLogout ({
    @required BuildContext context,
  }) async{
    bool result = false;
    await showDialog(
      context: context,
      builder: (_){
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Do you wish to continue?'),
          actions: [
          MyFlatButton(label: 'Cancel', onPressed: (){
            Navigator.of(context).pop();
          }),
          MyFlatButton(label: 'Yes', onPressed: (){
            result = true;
            Navigator.of(context).pop();
          }),
          ],
        );
      }
    );
    return result;
  }

  Future<bool> deleteRecord ({
    @required BuildContext context,
    @required String record,
  }) async{
    bool result = false;
    await showDialog(
      context: context,
      builder: (_){
        return AlertDialog(
          title: Text('Deletion Confirmation'),
          content: Text('Do you want to delete this $record?'),
          actions: [
          MyFlatButton(label: 'Cancel', onPressed: (){
            Navigator.of(context).pop();
          }),
          MyFlatButton(label: 'Delete', isDestructive: true, onPressed: (){
            result = true;
            Navigator.of(context).pop();
          }),
          ],
        );
      }
    );
    return result;
  }

  Future<bool> disableReenableUser ({
    @required BuildContext context,
    @required bool toDisable,
  }) async{
    bool result = false;
    String content = toDisable ? 'Are you sure you want to disable this user?' : 
    'Are you sure you want to enable this user?';
    String button = toDisable ? 'Disable' : 'Enable';
    String title = toDisable ? 'Disable User Confirmation' : 'Enable User Confirmation'; 
    await showDialog(
      context: context,
      builder: (_){
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
          MyFlatButton(label: 'Cancel', onPressed: (){
            Navigator.of(context).pop();
          }),
          MyFlatButton(label: button, onPressed: (){
            result = true;
            Navigator.of(context).pop();
          }),
          ],
        );
      }
    );
    return result;
  }

   Future<bool> leaveEditPage ({
    @required BuildContext context,
    bool creatingRecord = false,
  }) async{
    bool result = false;
    String content = creatingRecord ?
    'Do you wish to continue?':
    'Any changes made will be discarded, do you wish to continue?';
    await showDialog(
      context: context,
      builder: (_){
        return AlertDialog(
          title: Text('Leave Page'),
          content: Text(content),
          actions: [
          MyFlatButton(label: 'Cancel', onPressed: (){
            Navigator.of(context).pop();
          }),
          MyFlatButton(label: 'Continue', onPressed: (){
            result = true;
            Navigator.of(context).pop();
          }),
          ],
        );
      }
    );
    return result;
  }

  Future<bool> saveRecord ({
    @required BuildContext context,
    @required String record,
    bool editing = false,
    bool discardOption = false,
  }) async{
    bool result = false;
    String title = editing ? 'Update $record' : 'Save $record';
    String content = editing ? 'Do you wish to save updates made?' : 'Do you wish to add new $record?';
    await showDialog(
      barrierDismissible: discardOption ? false:true,
      context: context,
      builder: (_){
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
          discardOption ? MyFlatButton(
            label: 'Cancel', onPressed: (){
              result = null;
              Navigator.of(context).pop();
            },
          ):Container(),
          MyFlatButton(label: discardOption ? 'Discard':'Cancel', onPressed: (){
            Navigator.of(context).pop();
          }),
          MyFlatButton(label: 'Continue', onPressed: (){
            result = true;
            Navigator.of(context).pop();
          }),
          ],
        );
      }
    );
    return result;
  }

  Future<bool> sendNotification ({
    @required BuildContext context,
  }) async{
    bool result = false;
    await showDialog(
      context: context,
      builder: (_){
        return AlertDialog(
          title: Text('Notify everyone of this post?'),
          content: Text('Do you wish to continue? Do not abuse this!'),
          actions: [
            MyFlatButton(
              label: 'Cancel',
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            MyFlatButton(
              label: 'Notify Users',
              onPressed: (){
                result = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
    return result;
  }

  void uploadTaskStarted({
    @required BuildContext context,
    //@required AppBloc appBloc,
  }){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_){
        return WillPopScope(
          onWillPop: ()async=>false,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
            child: BlocBuilder<AppBloc, AppState>(
              condition: (_,state){
                if(state is AppMapUploadTaskToDialogueState) return true;
                else if(state is AppCompressingImageTaskState) return true;
                else if(state is AppCompressingVideoTaskState) return true;
                return false;
              },
              builder: (_,state){
                String title = 'Uploading...',subtitle="Waiting for next task.";
                Widget trailing = Text('');

                if(state is AppMapUploadTaskToDialogueState){
                  return StreamBuilder<StorageTaskEvent>(
                    stream: state.task.events,
                    builder: (_,snap){
                      String percentage;
                      if(snap.hasData){
                        int totalByteCount = snap.data.snapshot.totalByteCount;
                        int amountTransfered = snap.data.snapshot.bytesTransferred;
                        percentage = ((amountTransfered/totalByteCount) * 100).round().toString() + '%';
                        title = state.fileName;
                        subtitle = 'Uploading Item ${state.itemNo} / ${state.totalLength}';
                      }else{
                        percentage = '0%';
                      }
                      trailing = Text(percentage);
                       return ListTile(
                        title: Text(title),
                        subtitle: Text(subtitle),
                        trailing: trailing,
                      );
                    },
                  );
                }

                else if(state is AppCompressingImageTaskState){
                  title = state.fileName;
                  subtitle = 'Compressing Item ${state.itemNo} / ${state.totalLength}, Please wait...';
                  trailing = CircularProgressIndicator();
                }

                else if(state is AppCompressingVideoTaskState){
                  title = state.fileName;
                  subtitle = 'Compressing Item ${state.itemNo} / ${state.totalLength} | Please wait...';
                  trailing = CircularProgressIndicator();
                }

                return ListTile(
                  title: Text(title),
                  subtitle: Text(subtitle),
                  trailing: trailing,
                );
              },
            ),
          ),
        );
      }
    );
  }
}