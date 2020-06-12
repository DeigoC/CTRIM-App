import 'package:intl/intl.dart';

class TimelinePost{
  String id, postID, authorID, postType;
  DateTime postDate;
  TimelinePost({this.postID, this.postDate, this.postType, this.authorID});

  String getPostDateString(){
    return DateFormat('dd MMM yyyy').format(postDate);
  }
}