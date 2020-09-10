import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';

class TimelinePostDBManager{
  static final CollectionReference _ref = Firestore.instance.collection('timelinePosts');

  Future<List<TimelinePost>> fetchHomeFeedTPs() async{
    var collections = await _ref
    .limit(25)
    .where('PostDeleted',isEqualTo: false)
    .orderBy('PostDate',descending: true)
    .getDocuments();
    
    return collections.documents.map((doc) => TimelinePost.fromMap(doc.documentID, doc.data)).toList();
  }

  Future<List<TimelinePost>> fetchFeedWithTags(List<String> tags) async{
    tags.sort();
  
    var collections = await _ref.limit(10)
    .where('Tags', isEqualTo: tags)
    .orderBy('PostDate',descending: true)
    .getDocuments();
    
    return collections.documents.map((doc) => TimelinePost.fromMap(doc.documentID, doc.data)).toList();
  }

  Future<List<TimelinePost>> fetchOriginalPostsByList(List<String> likedPostsIDs) async{
    List<TimelinePost> results = [];

    await Future.forEach(likedPostsIDs, (id) async{
      TimelinePost tp = await fetchOriginalPostByID(id);
      results.add(tp);
    });

    results.sort((a,b) => b.postDate.compareTo(a.postDate));
    return results;
  }

  Future<List<TimelinePost>> fetchUserPosts(String userID,) async{
    var collection = await _ref
    .where('AuthorID', isEqualTo: userID)
    .where('PostType',isEqualTo: 'original')
    .where('PostDeleted',isEqualTo: false)
    .getDocuments();

    List<TimelinePost> results = collection.documents
    .map((doc) => TimelinePost.fromMap(doc.documentID, doc.data)).toList();
    results.sort((a,b) => b.postDate.compareTo(a.postDate));
    return results;
  }

  Future<List<TimelinePost>> fetchAllUserPosts(String userID,) async{
    var collection = await _ref
    .where('AuthorID', isEqualTo: userID)
    .where('PostType',isEqualTo: 'original')
    .getDocuments();

    List<TimelinePost> results = collection.documents
    .map((doc) => TimelinePost.fromMap(doc.documentID, doc.data)).toList();
    results.sort((a,b) => b.postDate.compareTo(a.postDate));
    return results;
}

  Future<List<TimelinePost>> fetchTimelinePostsFromPostID(String postID) async{
    var collection = await _ref.where('PostID', isEqualTo: postID).getDocuments();
    List<TimelinePost> results = collection.documents.map((doc) => 
    TimelinePost.fromMap(doc.documentID, doc.data)).toList();
    return results;
  }

  Future<TimelinePost> fetchTimelinePostByID(String id) async{
    var doc = await _ref.document(id).get();
    return TimelinePost.fromMap(doc.documentID, doc.data);
  }

  Future<TimelinePost> fetchOriginalPostByID(String postID) async{
    var col = await _ref
    .where('PostType',isEqualTo: 'original',)
    .where('PostID',isEqualTo: postID)
    .getDocuments();

    return TimelinePost.fromMap(col.documents.first.documentID, col.documents.first.data);
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

  Future<Null> updateAllTPsWithPostID(String postID, TimelinePost tp) async{
    var collection = await _ref.where('PostID',isEqualTo: postID).getDocuments();
    collection.documents.forEach((doc) {
      TimelinePost tPost = TimelinePost.fromMap(doc.documentID, doc.data);
      tPost.title = tp.title;
      tPost.description = tp.description;
      tPost.gallerySources = tp.gallerySources;
      tPost.thumbnailSrc = tp.thumbnailSrc;
      tPost.tags = tp.tags;
      tPost.postDeleted = tp.postDeleted;

      updateTimelinePost(tPost);
    });
  }

  Future<Null> updateDeletedPostTPs(String postID) async{
    var collection = await _ref.where('PostID',isEqualTo: postID).getDocuments();
    await Future.forEach(collection.documents, (DocumentSnapshot doc){
      TimelinePost tp = TimelinePost.fromMap(doc.documentID, doc.data);
      tp.postDeleted= true;
      updateTimelinePost(tp);
    });
  }

  Future<bool> hasTimelinePostsChanged(String latestID) async{
    var col = await _ref.limit(1).orderBy('PostDate',descending: true).getDocuments();
    return col.documents.first.documentID.compareTo(latestID)!=0;
  }
}