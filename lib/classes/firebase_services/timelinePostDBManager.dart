import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';

class TimelinePostDBManager{
  static final CollectionReference _ref = Firestore.instance.collection('timelinePosts');

  static List<TimelinePost> _feedTPs;
  static List<TimelinePost> get feedTimelinePosts => _feedTPs;

  Future<List<TimelinePost>> fetchHomeFeedTPs() async{
    var collections = await _ref
    .limit(25)
    .where('PostDeleted',isEqualTo: false)
    .orderBy('PostDate',descending: true)
    .getDocuments();
    
    _feedTPs = collections.documents.map((doc) => TimelinePost.fromMap(doc.documentID, doc.data)).toList();
    return _feedTPs;
  }

  Future<List<TimelinePost>> fetchFeedWithTags(List<String> postIDs) async{
    List<DocumentSnapshot> snaps=[];
    await Future.forEach(postIDs, (postID)async{
      var docSnaps = await _ref
      .where('PostID',isEqualTo: postID)
      .where('PostType',isEqualTo: 'original')
      .getDocuments();
      snaps.addAll(docSnaps.documents);
    });
    
    return snaps.map((doc) => TimelinePost.fromMap(doc.documentID, doc.data)).toList();
  }

  // ? Test again
  Future<List<TimelinePost>> fetchOriginalLikedPosts(List<String> likedPostsIDs) async{
    var collection = await _ref.where('PostType', isEqualTo: 'original').getDocuments();
    List<TimelinePost> results = [];
    collection.documents.forEach((doc) {
      if(likedPostsIDs.contains(doc.data['PostID'].toString())){
        results.add(TimelinePost.fromMap(doc.documentID, doc.data));
      }
    });
    return results;
  }

  Future<List<TimelinePost>> fetchUserPosts(String userID) async{
    var collection = await _ref
    .where('AuthorID', isEqualTo: userID)
    .where('PostType',isEqualTo: 'original')
    .getDocuments();

    List<TimelinePost> results = collection.documents
    .map((doc) => TimelinePost.fromMap(doc.documentID, doc.data)).toList();
    return results;
  }

  Future<List<TimelinePost>> fetchTimelinePostsFromPostID(String postID) async{
    var collection = await _ref.where('PostID', isEqualTo: postID).getDocuments();
    List<TimelinePost> results = collection.documents.map((doc) => 
    TimelinePost.fromMap(doc.documentID, doc.data)).toList();
    return results;
  }

  Future<TimelinePost> getTimelinePostByID(String id) async{
    var doc = await _ref.document(id).get();
    return TimelinePost.fromMap(doc.documentID, doc.data);
  }

  Future<Null> addTimelinePost(TimelinePost timelinePost) async{
    await _ref.limit(1).orderBy('PostDate',descending: true).getDocuments().then((col){
      int newID = int.parse(col.documents.first.documentID) + 1;
      timelinePost.id = newID.toString();
    });
    await _ref.document(timelinePost.id).setData(timelinePost.toJson());
  }

  Future<Null> updateTimelinePost(TimelinePost timelinePost) async{
    await _ref.document(timelinePost.id).setData(timelinePost.toJson());
  }

  Future<Null> updateDeletedPostTPs(String postID) async{
    var collection = await _ref.where('PostID',isEqualTo: postID).getDocuments();
    await Future.forEach(collection.documents, (DocumentSnapshot doc){
      TimelinePost tp = TimelinePost.fromMap(doc.documentID, doc.data);
      tp.postDeleted= true;
      updateTimelinePost(tp);
    });
  }
}