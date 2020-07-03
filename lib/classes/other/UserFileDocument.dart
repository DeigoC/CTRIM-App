import 'dart:io';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:path_provider/path_provider.dart';

class UserFileDocument{
  
  static Future<User> attpemtToLoginSavedUser() async{
    User rememberedUser;
    try{
       await _readLoginData().then((data){
         //TODO login as normal user
       });
    }catch(e){

    }finally{
      if(rememberedUser==null){
        await _readGuestData().then((data){
          rememberedUser = User(
            adminLevel: 0,
            likedPosts: data.length==1 ? [] : List.from(data.sublist(1)),
            onDarkTheme: data[0].compareTo('true')==0
          );
        });
      }
    }
    return rememberedUser;
  }

  static Future<List<String>> _readLoginData() async{
    List<String> content;
    try{
      final file = await _localLoginFile;
      content = await file.readAsLines();
    }catch(e){}
    return content;
  }

   static Future<List<String>> _readGuestData() async{
    List<String> content =[];
    try{
      final file = await _localGuestFile;
      content = await file.readAsLines();
    }catch(e){
      content = ['false'];
    }
    return content;
  }

  // * SAVING THE DATA
  static Future<Null> saveLoginData(String email, String password)async{
    String contents = '$email\n$password';
    await _writeToLoginFile(contents);
  }

  static Future<Null> saveNormalUserData(User user)async{
    String likedPosts ='';
    user.likedPosts.forEach((id)=>likedPosts += '\n$id');
    String contents = '${user.onDarkTheme.toString()}$likedPosts';
    await _writeToLocalUserFile(contents);
  }

  static Future<File> _writeToLocalUserFile(String contents) async{
    final file = await _localGuestFile;
    return file.writeAsString(contents);
  }

  static Future<File> get _localGuestFile async{
    final path = await _localPath;
    return File('$path/userInfo.txt');
  }

  static Future<File> _writeToLoginFile(String contents) async{
    final file = await _localLoginFile;
    return file.writeAsString(contents);
  }

  static Future<File> get _localLoginFile async{
    final path = await _localPath;
    return File('$path/login.txt');
  }

  static Future<String> get _localPath async{
    final directory = await getApplicationDocumentsDirectory();
    return directory.path; 
  }

}