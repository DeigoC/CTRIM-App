import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/locationDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/postDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/timelinePostDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/userDBManager.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  
  final LocationDBManager _locationDBManager = LocationDBManager();
  final UserDBManager _userDBManager = UserDBManager();
  final PostDBManager _postDBManager = PostDBManager();
  final TimelinePostDBManager _timelinePostDBManager = TimelinePostDBManager();
 
  // ! Bloc Fields
  String _locationSearchString = '';

  List<User> get allUsers => UserDBManager.allUsers;

  List<Post> get _allPosts => PostDBManager.allPosts;

  List<TimelinePost> get _allTimelinePosts => TimelinePostDBManager.allTimelinePosts;

  Map<PostTag, bool> _selectedTags = {
    PostTag.YOUTH: false,
    PostTag.CHURCH: false,
    PostTag.WOMEN: false,
  };

  // ! Bloc Functions
  Future<Null> reloadAllRecords() async{
    await _locationDBManager.fetchAllLocations();
    await _postDBManager.fetchAllPosts();
    await _timelinePostDBManager.fetchAllTimelinePosts();
    await _userDBManager.fetchAllUsers();
  }

  bool doesLocationHaveEvents(String locationId){ 
    for (var i = 0; i < _allPosts.length; i++) {
      if(_allPosts[i].locationID.compareTo(locationId)==0) return true;
    }
    return false;
  }

  Map<String, bool> getSelectedTags() {
    Map<String, bool> result = {};
    _selectedTags.forEach((key, value) {
      result[_tagToString(key)] = value;
    });
    return result;
  }

  Map<Post, String> getUserPosts(String userID) {
    Map<Post, String> results = {};
    _allTimelinePosts.forEach((timelinePost) {
      if (timelinePost.authorID.compareTo(userID) == 0 && timelinePost.postType.compareTo('original') == 0) {
        Post thisPost = _allPosts.firstWhere((post) => post.id.compareTo(timelinePost.postID) == 0);
        if(!thisPost.deleted) results[thisPost] =timelinePost.getPostDateString();
      }
    });
    return results;
  }

  Map<Post, String> getUserDeletedPosts(String userID) {
    Map<Post, String> results = {};
    _allTimelinePosts.forEach((timelinePost) {
      if (timelinePost.authorID.compareTo(userID) == 0 && timelinePost.postType.compareTo('original') == 0) {
        Post thisPost = _allPosts.firstWhere((post) => post.id.compareTo(timelinePost.postID) == 0);
        if(thisPost.deleted) results[thisPost] = timelinePost.getPostDateString();
      }
    });
    return results;
  }

  Map<DateTime, List<Post>> getPostsForGalleryTab() {
    Map<DateTime, List<Post>> unsortedResult = {};
    Map<DateTime, List<Post>> sortedResult = {};

    _allTimelinePosts.forEach((tPost) {
      if (tPost.postType.compareTo('original') == 0) {
        Post thisPost = _allPosts.firstWhere((post) => post.id.compareTo(tPost.postID) == 0);
        if (thisPost.gallerySources.length != 0 && !thisPost.deleted) {
          if (thisPost.isDateNotApplicable) {
            DateTime thisDate = DateTime(tPost.postDate.year, tPost.postDate.month, tPost.postDate.day);
            unsortedResult[thisDate] = _createList(unsortedResult[thisDate]);
            unsortedResult[thisDate].add(thisPost);
          } else {
            DateTime thisDate = DateTime(thisPost.eventDate.year, thisPost.eventDate.month, thisPost.eventDate.day);
            unsortedResult[thisDate] =_createList(unsortedResult[thisDate]);
            unsortedResult[thisDate].add(thisPost);
          }
        }
      }
    });

    // * Sorts by date
    List<DateTime> sortedDates =  unsortedResult.keys.toList();
    sortedDates.sort((a, b) => a.compareTo(b));
    sortedDates.forEach((date) {
      sortedResult[date] = unsortedResult[date];
    });
    return sortedResult;
  }

  List<Location> get allLocations => LocationDBManager.allLocations;

  List<Location> get locationsForTab {
    List<Location> result = List.from(allLocations);
    result.removeAt(0);
    result.removeWhere((e) => e.deleted);
    return result;
  }

  String getLocationAddressLine(String locationID) {
    if (locationID.trim().isNotEmpty) 
      return allLocations.firstWhere((location) => location.id.compareTo(locationID) == 0).addressLine;
    return 'Pending';
  }

  List<TimelinePost> getAllUpdatePosts(String postID){
    List<TimelinePost> result = [];
    _allTimelinePosts.forEach((tPost) {
      if(tPost.postID.compareTo(postID)==0){
        result.add(tPost);
      }
    });
    result.sort((a,b) => a.postDate.compareTo(b.postDate));
    return result;
  }

  // ! Mapping events to state
  @override
  TimelineState get initialState => TimelineInitial();

  @override
  Stream<TimelineState> mapEventToState(TimelineEvent event,) async* {
    if (event is TimelineFetchAllPostsEvent)yield* _displayFeed();
    else if (event is TimelineAddNewPostEvent) yield* _mapNewPostEventToState(event);
    else if (event is TimelinePostUpdateEvent){
      if(event is TimelineUpdatePostEvent) yield* _mapPostUpdateToState(event);
      else yield* _mapPostDeletedToState(event);
    } else if (event is TimelineTagClickedEvent) yield* _mapTagChnageToState(event);
    else if (event is TimelineSearchPostEvent) yield* _mapSearchPageEventToState(event);
    else if (event is TimelineLocationSearchTextChangeEvent) yield* _mapLocationSearchEventToState(event);
    else if (event is TimelineAlbumSearchEvent)yield* _mapAlbumSearchEventToState(event);
    else if (event is TimelineUserUpdatedEvent)yield* _mapUserUpdatedEventToState(event);
    else if (event is TimelineDisplayCurrentUserLikedPosts)yield _getCurrentUserLikedPosts(event.likedPosts);
    else if (event is TimelineUserDisabledEvent) yield* _mapUserDisabledToState(event);
    else if (event is TimelineUserEnabledEvent) yield* _mapUserEnabledToState(event);
    else if (event is TimelineLocationDeletedEvent) _mapLocationDeletedToState(event);
    else if (event is TimelineLocationUpdatedEvent) _updateLocation(event);
  }

  Stream<TimelineState> _mapAlbumSearchEventToState(TimelineAlbumSearchEvent event) async* {
    if (event is TimelineAlbumSearchTextChangeEvent) {
      List<Post> results = [];
      _allPosts.forEach((post) {
        if (post.title.toLowerCase().contains(event.newSearch.toLowerCase()) &&
            post.gallerySources.length != 0) {
          results.add(post);
        }
      });
      yield TimelineAlbumDisplaySearchResultsState(results);
      yield TimelineEmptyState();
    }
  }

  // ! Post Related
  Stream<TimelineState> _mapTagChnageToState(TimelineTagClickedEvent event) async* {
    PostTag selectedTag = _stringToTag(event.tag);
    _selectedTags[selectedTag] = !_selectedTags[selectedTag];
    
    yield* _displayFeed();
    yield TimelineTagChangedState();
  }

  Stream<TimelineState> _mapSearchPageEventToState(TimelineSearchPostEvent event) async* {
    if (event is TimelineSearchTextChangeEvent) {
      if (event.searchString.isEmpty) {
        yield TimelineDisplayEmptySearchState();
      } else {
        yield _displayFeedBySearch(event.searchString);
        yield TimelineEmptyState();
      }
    }
  }

  TimelineState _displayFeedBySearch(String search) {
    List<Post> posts = [];
    List<TimelinePost> tPosts = [];

    // * Get all Posts that contains the search string in their titles
    _allPosts.forEach((post) {
      if (post.title.toLowerCase().contains(search.toLowerCase()) &&
          !posts.contains(post)) {
        posts.add(post);
      }
    });

    if (posts.length == 0) return TimelineDisplayEmptyFeedState();

    // * Get all original tPosts that contains the posts
    posts.forEach((post) {
      _allTimelinePosts.forEach((tPost) {
        if (tPost.postID.compareTo(post.id) == 0 &&
            tPost.postType == 'original' &&
            !tPosts.contains(tPost)) {
          tPosts.add(tPost);
        }
      });
    });

    return TimelineDisplaySearchFeedState(
      users: allUsers,
      posts: posts,
      timelines: tPosts,
    );
  }

  Stream<TimelineState> _mapNewPostEventToState(TimelineAddNewPostEvent event) async*{
    _insertPostID(event.post);
    TimelinePost timelinePost = _generateTimelinePost(event);
     
    yield TimelineAttemptingToUploadNewPostState();
    await _postDBManager.addPost(event.post).then((_){
      _allPosts.add(_postDBManager.getPostByID(event.post.id));
    });
    await _timelinePostDBManager.addTimelinePost(timelinePost).then((_) =>  _allTimelinePosts.add(timelinePost));
    yield TimelineNewPostUploadedState();
    yield* _displayFeed();
  }

  Stream<TimelineState> _displayFeed() async*{
    _allTimelinePosts.sort((x, y) => y.postDate.compareTo(x.postDate));
    List<Post> posts = [];
    List<TimelinePost> tPosts = [];
    List<PostTag> selectedTags = [];

    if (_selectedTags.values.contains(true)) {
      _selectedTags.forEach((key, value) {
        if (value) selectedTags.add(key);
      });

      // * Add all posts that contains selected tags
      selectedTags.forEach((selectedTag) {
        _allPosts.forEach((post) {
          if (post.selectedTags.contains(selectedTag) && !posts.contains(post)) {
            posts.add(post);
          }
        });
      });

      // * Add all timeline posts that contains the post
      posts.forEach((post) {
        _allTimelinePosts.forEach((tPost) {
          if (tPost.postID.compareTo(post.id) == 0 && !tPosts.contains(tPost)) {
            tPosts.add(tPost);
          }
        });
      });

    } else {
      posts = List.from(_allPosts);
      tPosts = List.from(_allTimelinePosts);
    }
   
    posts.removeWhere((element) => element.deleted);
    tPosts.removeWhere((tPost) => posts.firstWhere((post) => post.id == tPost.postID, orElse: ()=> null) ==null);

    yield TimelineDisplayFeedState(
      users: allUsers,
      posts: posts,
      timelines: tPosts,
    );
    yield TimelineEmptyState();
  }

  Stream<TimelineState> _mapPostUpdateToState(TimelineUpdatePostEvent event) async*{
    int index = _allPosts.indexWhere((post) => post.id.compareTo(event.post.id) == 0);

    yield TimelineAttemptingToUploadNewPostState();
    await _postDBManager.updatePost(event.post);
    _allPosts[index] = event.post;
    _createUpdateTPost(event);

    print('----------EVENT POST SRC LENGTH IS ' + event.post.gallerySources.length.toString());
    yield TimelineRebuildMyPostsPageState(getUserPosts(event.uid));
    yield TimelineEmptyState();
  }

  Stream<TimelineState> _mapPostDeletedToState(TimelinePostUpdateEvent event) async*{
    int index = _allPosts.indexWhere((post) => post.id.compareTo(event.post.id) == 0);
    _allPosts[index].deleted = true;
    _postDBManager.updatePost(_allPosts[index]);
    _createUpdateTPost(event);
    yield TimelineRebuildMyPostsPageState(getUserPosts(event.uid));
    yield TimelineEmptyState();
  }

  TimelinePost _generateTimelinePost(TimelineAddNewPostEvent event) {
    return TimelinePost(
      postID: event.post.id,
      postType: 'original',
      authorID: event.authorID,
      updateLog: '',
      postDate: DateTime.now(),
    );
  }

  // ! User Related
  Stream<TimelineState> _mapUserUpdatedEventToState(TimelineUserUpdatedEvent event) async*{
    int index = allUsers.indexWhere((user) => user.id.compareTo(event.updatedUser.id) == 0);
    allUsers[index] = event.updatedUser;
    _userDBManager.updateUser(event.updatedUser);
    yield TimelineRebuildUserListState();
    yield TimelineEmptyState();
  }

  Stream<TimelineState> _mapUserDisabledToState(TimelineUserDisabledEvent event) async* {
    int index = allUsers.indexWhere((e) => e.id == event.user.id);
    allUsers[index].disabled = true;
    _userDBManager.updateUser(allUsers[index]);
    yield TimelineRebuildUserListState();
    yield TimelineEmptyState();
  }

  Stream<TimelineState> _mapUserEnabledToState(TimelineUserEnabledEvent event) async*{
    int index = allUsers.indexWhere((e) => e.id == event.user.id);
    allUsers[index].disabled = false;
    _userDBManager.updateUser(allUsers[index]);
    yield TimelineRebuildUserListState();
    yield TimelineEmptyState();
  }

  TimelineDisplaySearchFeedState _getCurrentUserLikedPosts(List<String> postIDs) {
    List<Post> posts = [];
    List<TimelinePost> tPosts = [];

    _allPosts.forEach((post) {
      if (postIDs.contains(post.id)) {
        posts.add(post);
      }
    });

    posts.forEach((post) {
      _allTimelinePosts.forEach((tPost) {
        if (tPost.postID.compareTo(post.id) == 0 &&
            tPost.postType == 'original' &&
            !tPosts.contains(tPost)) {
          tPosts.add(tPost);
        }
      });
    });

    return TimelineDisplaySearchFeedState(
      users: allUsers,
      posts: posts,
      timelines: tPosts,
    );
  }

  // ! Location Related
  Stream<TimelineState> _mapLocationSearchEventToState( TimelineLocationSearchTextChangeEvent event) async* {
    List<Location> result = [];
    _locationSearchString = event.searchString ?? _locationSearchString;
    allLocations.forEach((location) {
      if (location.id != '0' &&
          location.addressLine
              .toLowerCase()
              .contains(_locationSearchString.toLowerCase())) {
        result.add(location);
      }
    });
    yield TimelineDisplayLocationSearchResultsState(result);
    yield TimelineEmptyState();
  }

  void _mapLocationDeletedToState(TimelineLocationDeletedEvent event){
    int index = allLocations.indexWhere((e) => e.id.compareTo(event.location.id)==0);
    allLocations[index].deleted = true;
    _locationDBManager.updateLocation(allLocations[index]);
    this.mapEventToState(TimelineLocationSearchTextChangeEvent(null));
  }

  void _updateLocation(TimelineLocationUpdatedEvent event) {
    int index = allLocations.indexWhere((l) => l.id.compareTo(event.location.id) == 0);
    allLocations[index] = event.location;
    _locationDBManager.updateLocation(event.location);
  }

  // ! Lower level details
  PostTag _stringToTag(String tag) {
    switch (tag) {
      case 'Women':
        return PostTag.WOMEN;
      case 'Church':
        return PostTag.CHURCH;
      case 'Youth':
        return PostTag.YOUTH;
    }
    return null;
  }

  String _tagToString(PostTag tag) {
    switch (tag) {
      case PostTag.CHURCH:
        return 'Church';
      case PostTag.WOMEN:
        return 'Women';
      case PostTag.YOUTH:
        return 'Youth';
    }
    return '';
  }

  void _insertPostID(Post post) {
    post.id = (int.parse(_allPosts.last.id) + 1).toString();
  }

  void _createUpdateTPost(TimelinePostUpdateEvent event) {
    String authorID = _allTimelinePosts.firstWhere((tPost) => tPost.postID.compareTo(event.post.id) == 0).authorID;
    TimelinePost thisTPost = TimelinePost(
        id: (int.parse(_allTimelinePosts.last.id) + 1).toString(),
        authorID: authorID,
        postDate: DateTime.now(),
        postID: event.post.id,
        updateLog: event.updateLog,
        postType: 'update'
      );
    _allTimelinePosts.add(thisTPost);
    _timelinePostDBManager.addTimelinePost(thisTPost);
  }

  List<Post> _createList(List<Post> list) {
    if (list == null) return [];
    return list;
  }
}
