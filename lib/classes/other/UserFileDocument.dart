import 'dart:io';
import 'package:ctrim_app_v1/classes/firebase_services/auth.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:path_provider/path_provider.dart';

class UserFileDocument{
  
  Future<User> attpemtToLoginSavedUser() async{
    User rememberedUser;
    AuthService _auth = AuthService();
    
    try{
       await _readLoginData().then((data) async{
        rememberedUser = await _auth.loginWithEmail(email: data[0], password: data[1]);
       });
    }catch(e){
      // ! Maybe the password was changed in a different phone?
    }finally{
      if(rememberedUser==null){
        await _readGuestData().then((data){
          rememberedUser = User(
            id: '0',
            adminLevel: 0,
            likedPosts: data.length==1 ? [] : List.from(data.sublist(1)),
            onDarkTheme: data[0].compareTo('true')==0
          );
        });
      }
    }
    return rememberedUser;
  }

  Future<List<String>> _readLoginData() async{
    List<String> content;
    try{
      final file = await _localLoginFile;
      content = await file.readAsLines();
    }catch(e){}
    return content;
  }

  Future<List<String>> _readGuestData() async{
    List<String> content =[];
    try{
      final file = await _localGuestFile;
      content = await file.readAsLines();
    }catch(e){
      content = ['false'];
    }
    return content;
  }

  Future<Null> deleteSaveData() async{
    final file = await _localLoginFile;
    file.delete();
  }

  // ! Checking for DeviceToken file
  Future<bool> hasDeviceTokenFile() async{
    File deviceTokenFile;
    try{
      deviceTokenFile = await _deviceTokenFile;
      await deviceTokenFile.readAsLines().then((value){ 
        //print('--------device token file says: ' +value.toString());
      });
    }catch(e){
      _writeDeviceTokenFile();
      return false;
    }
    return true;
  }

  Future<File> _writeDeviceTokenFile() async{
    final file = await _deviceTokenFile;
    return file.writeAsString("ignore this, but don't delete it either. this is just a flag");
  }

  Future<File> get _deviceTokenFile async{
    final path = await _localPath;
    return File('$path/deviceToken.txt');
  }

  // ! End of section

  // * WRITING THE DATA
  Future<Null> saveLoginData(String email, String password)async{
    String contents = '$email\n$password';
    await _writeToLoginFile(contents);
  }

  Future<Null> saveGuestUserData(User user)async{
    String likedPosts ='';
    user.likedPosts.forEach((id)=>likedPosts += '\n$id');
    String contents = '${user.onDarkTheme.toString()}$likedPosts';
    await _writeToLocalUserFile(contents);
  }
 
  Future<File> _writeToLocalUserFile(String contents) async{
    final file = await _localGuestFile;
    return file.writeAsString(contents);
  }

  Future<File> get _localGuestFile async{
    final path = await _localPath;
    return File('$path/userInfo.txt');
  }

  Future<File> _writeToLoginFile(String contents) async{
    final file = await _localLoginFile;
    return file.writeAsString(contents);
  }

  Future<File> get _localLoginFile async{
    final path = await _localPath;
    return File('$path/login.txt');
  }

  Future<String> get _localPath async{
    final directory = await getApplicationDocumentsDirectory();
    return directory.path; 
  }

}