import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TimelinePost{
  String id, postID, authorID, postType, updateLog;
  DateTime postDate;

  TimelinePost({this.id, this.postID, this.postDate, this.postType, this.authorID, this.updateLog});

  TimelinePost.fromMap(String id, Map<String, dynamic> data)
  : id = id,
  postID = data['PostID'],
  authorID = data['AuthorID'],
  postType = data['PostType'],
  updateLog = data['UpdateLog'],
  postDate = (data['PostDate'] as Timestamp).toDate();

  toJson(){
    return {
      'PostID':postID,
      'AuthorID':authorID,
      'PostType':postType,
      'UpdateLog': updateLog,
      'PostDate':Timestamp.fromDate(postDate),
    };
  }

  String getPostDateString(){
    return DateFormat('dd MMM yyyy').format(postDate);
  }

  String getUpdateTime(){
    return DateFormat('h:mm a').format(postDate);
  }

  String getUpdateString(){
    if(postType == 'original') return 'Original Post';
    return updateLog;
  }
}