import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';

class TimelinePostDBManager{
  static final CollectionReference _ref = Firestore.instance.collection('timelinePosts');

  static List<TimelinePost> _allTimelinePosts;
  static List<TimelinePost> get allTimelinePosts => _allTimelinePosts;

  static List<TimelinePost> _feedTPs;
  static List<TimelinePost> get feedTimelinePosts => _feedTPs;

  //TODO delete maybe?
  Future<List<TimelinePost>> fetchAllTimelinePosts() async{
    var collection = await _ref.getDocuments();

    // ! This works!
    /* _ref.limit(5).orderBy(
      'PostDate', 
      descending: true
    ).getDocuments().then((col){
      print('--------------LENGTH IS ' + col.documents.length.toString());
      var v1 = col.documents.elementAt(0),v2 = col.documents.elementAt(1);
      TimelinePost tp1 = TimelinePost.fromMap(v1.documentID, v1.data),tp2 = TimelinePost.fromMap(v2.documentID, v2.data);
      print('--------------T1 - ' + tp1.id);
      print('--------------T2 - ' + tp2.id);
    }); */

    _allTimelinePosts = collection.documents.map((doc) => TimelinePost.fromMap(doc.documentID, doc.data)).toList();
    return _allTimelinePosts;
  }

  Future<List<TimelinePost>> fetchHomeFeedTPs(List<String> deletedPostsIDs) async{
    // * Load all deleted Posts here and make it so that we don't fetch any TPs related to these
    var collections = await _ref.limit(25).orderBy('PostDate',descending: true).getDocuments();
    _feedTPs = collections.documents
    .map((doc) => TimelinePost.fromMap(doc.documentID, doc.data)).toList();
    return _feedTPs;
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
    var collection = await _ref.where('AuthorID', isEqualTo: userID).getDocuments();
    List<TimelinePost> results = collection.documents.map((doc) => 
    TimelinePost.fromMap(doc.documentID, doc.data)).toList();
    results.removeWhere((e) => e.postType.compareTo('original')!=0);
    return results;
  }

  TimelinePost getTimelinePostByID(String id){
    return _allTimelinePosts.firstWhere((tp) => tp.id.compareTo(id)==0);
  }

  Future<Null> addTimelinePost(TimelinePost timelinePost) async{
    await _ref.getDocuments().then((collection){
      List<int> allIDs = collection.documents.map((e) => int.parse(e.documentID)).toList();
      allIDs.sort();

      timelinePost.id = (allIDs.last + 1).toString();
    });
    await _ref.document(timelinePost.id).setData(timelinePost.toJson());
    _allTimelinePosts.add(timelinePost);
  }

  Future<Null> updateTimelinePost(TimelinePost timelinePost) async{
    await _ref.document(timelinePost.id).setData(timelinePost.toJson());
    
    int index = _allTimelinePosts.indexWhere((e) => e.id.compareTo(timelinePost.id)==0);
    _allTimelinePosts[index] = timelinePost;
  }
}