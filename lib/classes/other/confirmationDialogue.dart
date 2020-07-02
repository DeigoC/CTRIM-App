import 'package:flutter/material.dart';

class ConfirmationDialogue{

  static Future<bool> deleteRecord ({
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
          FlatButton(child: Text('Cancel'), onPressed: (){
            Navigator.of(context).pop();
          }),
          FlatButton(child: Text('Delete'), onPressed: (){
            result = true;
            Navigator.of(context).pop();
          }),
          ],
        );
      }
    );
    return result;
  }

  static Future<bool> disableReenableUser ({
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
          FlatButton(child: Text('Cancel'), onPressed: (){
            Navigator.of(context).pop();
          }),
          FlatButton(child: Text(button), onPressed: (){
            result = true;
            Navigator.of(context).pop();
          }),
          ],
        );
      }
    );
    return result;
  }

   static Future<bool> leaveEditPage ({
    @required BuildContext context,
  }) async{
    bool result = false;
    await showDialog(
      context: context,
      builder: (_){
        return AlertDialog(
          title: Text('Leave Page'),
          content: Text('Any changes made will be discarded, do you wish to continue?'),
          actions: [
          FlatButton(child: Text('Cancel'), onPressed: (){
            Navigator.of(context).pop();
          }),
          FlatButton(child: Text('Discard'), onPressed: (){
            result = true;
            Navigator.of(context).pop();
          }),
          ],
        );
      }
    );
    return result;
  }

  static Future<bool> saveRecord ({
    @required BuildContext context,
    @required String record,
    bool editing = false,
  }) async{
    bool result = false;
    String title = editing ? 'Update $record' : 'Save $record';
    String content = editing ? 'Do you wish to save updates made?' : 'Do you wish to add new $record?';
    await showDialog(
      context: context,
      builder: (_){
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
          FlatButton(child: Text('Cancel'), onPressed: (){
            Navigator.of(context).pop();
          }),
          FlatButton(child: Text('Continue'), onPressed: (){
            result = true;
            Navigator.of(context).pop();
          }),
          ],
        );
      }
    );
    return result;
  }
}