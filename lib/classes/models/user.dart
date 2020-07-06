class User{
  String id, forename,surname, contactNo, imgSrc, email, authID;
  int adminLevel;
  List<String> likedPosts;
  bool disabled, onDarkTheme;

  User({
    this.id, 
    this.forename, 
    this.surname,
    this.contactNo,
    this.imgSrc,
    this.email,
    this.adminLevel,
    this.likedPosts,
    this.disabled = false,
    this.onDarkTheme = false,
    this.authID = '',
  });

  User.fromMap(String id, Map<String,dynamic> data) 
  : id = id,
  forename = data['Forename'],
  surname = data['Surname'],
  authID = data['AuthID'],
  adminLevel = data['AdminLevel'],
  contactNo = data['ContactNo'],
  disabled = data['Disabled'],
  imgSrc = data['ImgSrc'],
  likedPosts = List.from(data['LikedPosts'], growable: true),
  onDarkTheme = data['OnDarkTheme'],
  email = data['Email'];

  toJson(){
    return {
      'AdminLevel':adminLevel,
      'AuthID':authID,
      'ContactNo':contactNo,
      'Disabled':disabled,
      'Email':email,
      'Forename':forename,
      'ImgSrc':imgSrc??'',
      'LikedPosts':likedPosts??[],
      'OnDarkTheme':onDarkTheme,
      'Surname':surname,
    };
  }

}