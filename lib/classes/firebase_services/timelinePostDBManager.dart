import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';

class TimelinePostDBManager{
  static final CollectionReference _ref = Firestore.instance.collection('timelinePosts');

  static List<TimelinePost> _allTimelinePosts;
  static List<TimelinePost> get allTimelinePosts => _allTimelinePosts;

  Future<List<TimelinePost>> fetchAllTimelinePosts() async{
    var collection = await _ref.getDocuments();
    _allTimelinePosts = collection.documents.map((doc) => TimelinePost.fromMap(doc.documentID, doc.data)).toList();
    return _allTimelinePosts;
  }

  TimelinePost getTimelinePostByID(String id){
    return _allTimelinePosts.firstWhere((tp) => tp.id.compareTo(id)==0);
  }

  Future<Null> addTimelinePost(TimelinePost timelinePost) async{
    await _ref.getDocuments().then((collection){
      timelinePost.id = (int.parse(collection.documents.last.documentID) + 1).toString();
    });
    await _ref.document(timelinePost.id).setData(timelinePost.toJson());
  }

  Future<Null> updateTimelinePost(TimelinePost timelinePost) async{
    await _ref.document(timelinePost.id).setData(timelinePost.toJson());
  }
}