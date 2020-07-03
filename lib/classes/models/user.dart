class User{
  String id, forename,surname, contactNo, imgSrc, email;
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
  });
}