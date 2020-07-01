import 'package:intl/intl.dart';

class TimelinePost{
  String id, postID, authorID, postType, updateLog;
  DateTime postDate;
  TimelinePost({this.id, this.postID, this.postDate, this.postType, this.authorID, this.updateLog});

  String getPostDateString(){
    return DateFormat('dd MMM yyyy').format(postDate);
  }

  String getUpdateString(){
    if(postType == 'original') return 'Original Post';
    return updateLog;
  }
}