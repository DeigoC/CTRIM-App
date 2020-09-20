import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';

class TimelinePostDBManager{
  final CollectionReference _ref = FirebaseFirestore.instance.collection('timelinePosts');

  Future<List<TimelinePost>> fetchHomeFeedTPs() async{
    var collections = await _ref
    .limit(25)
    .where('PostDeleted',isEqualTo: false)
    .orderBy('PostDate',descending: true)
    .get();
    
    return collections.docs.map((doc) => TimelinePost.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<TimelinePost>> fetchFeedWithTags(List<String> tags) async{
    tags.sort();
  
    var collections = await _ref.limit(10)
    .where('Tags', isEqualTo: tags)
    .orderBy('PostDate',descending: true)
    .get();
    
    return collections.docs.map((doc) => TimelinePost.fromMap(doc.id, doc.data())).toList();
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
    .get();

    List<TimelinePost> results = collection.docs
    .map((doc) => TimelinePost.fromMap(doc.id, doc.data())).toList();
    results.sort((a,b) => b.postDate.compareTo(a.postDate));
    return results;
  }

  Future<List<TimelinePost>> fetchAllUserPosts(String userID,) async{
    var collection = await _ref
    .where('AuthorID', isEqualTo: userID)
    .where('PostType',isEqualTo: 'original')
    .get();

    List<TimelinePost> results = collection.docs
    .map((doc) => TimelinePost.fromMap(doc.id, doc.data())).toList();
    results.sort((a,b) => b.postDate.compareTo(a.postDate));
    return results;
}

  Future<List<TimelinePost>> fetchTimelinePostsFromPostID(String postID) async{
    var collection = await _ref.where('PostID', isEqualTo: postID).get();
    List<TimelinePost> results = collection.docs.map((doc) => 
    TimelinePost.fromMap(doc.id, doc.data())).toList();
    return results;
  }

  Future<TimelinePost> fetchTimelinePostByID(String id) async{
    var doc = await _ref.doc(id).get();
    return TimelinePost.fromMap(doc.id, doc.data());
  }

  Future<TimelinePost> fetchOriginalPostByID(String postID) async{
    var col = await _ref
    .where('PostType',isEqualTo: 'original',)
    .where('PostID',isEqualTo: postID)
    .get();

    return TimelinePost.fromMap(col.docs.first.id, col.docs.first.data());
  }

  Future<Null> addTimelinePost(TimelinePost timelinePost) async{
    await _ref.limit(1).orderBy('PostDate',descending: true).get().then((col){
      int newID = int.parse(col.docs.first.id) + 1;
      timelinePost.id = newID.toString();
    });
    await _ref.doc(timelinePost.id).set(timelinePost.toJson());
  }

  Future<Null> updateTimelinePost(TimelinePost timelinePost) async{
    await _ref.doc(timelinePost.id).set(timelinePost.toJson());
  }

  Future<Null> updateAllTPsWithPostID(String postID, TimelinePost tp) async{
    var collection = await _ref.where('PostID',isEqualTo: postID).get();
    collection.docs.forEach((doc) {
      TimelinePost tPost = TimelinePost.fromMap(doc.id, doc.data());
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
    var collection = await _ref.where('PostID',isEqualTo: postID).get();
    await Future.forEach(collection.docs, (DocumentSnapshot doc){
      TimelinePost tp = TimelinePost.fromMap(doc.id, doc.data());
      tp.postDeleted= true;
      updateTimelinePost(tp);
    });
  }

  Future<bool> hasTimelinePostsChanged(String latestID) async{
    var col = await _ref.limit(1).orderBy('PostDate',descending: true).get();
    return col.docs.first.id.compareTo(latestID)!=0;
  }
}