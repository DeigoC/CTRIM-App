import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TimelinePost{
  String id, postID, authorID, postType, updateLog, title, description, thumbnailSrc;
  DateTime postDate;
  bool postDeleted;

  List<String> tags;
  Map<String,String> gallerySources;

  TimelinePost({
    this.id, 
    this.postID, 
    this.postDate, 
    this.postType, 
    this.authorID, 
    this.updateLog, 
    this.postDeleted = false,
    this.title,
    this.thumbnailSrc,
    this.description,
    this.gallerySources,
    this.tags,
  });

  TimelinePost.fromMap(String id, Map<String, dynamic> data)
  : id = id,
  postID = data['PostID'],
  authorID = data['AuthorID'],
  postType = data['PostType'],
  updateLog = data['UpdateLog'],
  postDeleted = data['PostDeleted'],
  gallerySources = Map<String,String>.from(data['GallerySources']),
  title = data['Title'],
  description = data['Description'],
  thumbnailSrc = data['ThumbnailSrc'],
  tags = List.from(data['Tags']),
  postDate = (data['PostDate'] as Timestamp).toDate();

  toJson(){
    return {
      'PostID':postID,
      'AuthorID':authorID,
      'PostType':postType,
      'UpdateLog': updateLog,
      'PostDeleted':postDeleted??false,
      'Title':title,
      'Description':description,
      'ThumbnailSrc':thumbnailSrc??'',
      'GallerySources':gallerySources,
      'Tags':tags,
      'PostDate':Timestamp.fromDate(postDate),
    };
  }

  String  getPostDateString ()=> DateFormat('dd MMM yyyy').format(postDate);
  String  getUpdateTime ()=> DateFormat('h:mm a').format(postDate);

  String getUpdateString(){
    if(postType == 'original') return 'Original Post';
    return updateLog;
  }

  String getTagsString(){
    String result = '';
    tags.forEach((tag) {
      result += ' • ' + tag.toUpperCase();
    });
    return result;
  }
}