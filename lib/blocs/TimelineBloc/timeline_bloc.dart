import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/locationDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/postDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/timelinePostDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/userDBManager.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  
  final LocationDBManager _locationDBManager;
  final UserDBManager _userDBManager = UserDBManager();
  final PostDBManager _postDBManager;
  final TimelinePostDBManager _timelinePostDBManager = TimelinePostDBManager();
 
  TimelineBloc(AppBloc appBloc)
  :_locationDBManager = LocationDBManager(appBloc),
  _postDBManager = PostDBManager(appBloc);

  // ! Bloc Fields
  String _locationSearchString = '';

  List<User> get allUsers => UserDBManager.allUsers;
 
  Map<TimelinePost,Post> _feedData ={};
  Map<TimelinePost,Post> get feedData =>_feedData;

  Map<PostTag, bool> _selectedTags = {
    PostTag.BELFAST: false,
    PostTag.NORTHCOAST: false,
    PostTag.PORTADOWN: false,
    PostTag.TESTIMONIES: false,
    PostTag.EVENTS: false,
    PostTag.YOUTH: false,
    PostTag.MEN: false,
    PostTag.WOMEN: false,
    PostTag.KIDS: false,
  };

  // ! Bloc Functions
  bool doesLocationHaveEvents(String locationId){ 
    //TODO needs to be a future
    return false;
  }

  Map<String, bool> getSelectedTags() {
    Map<String, bool> result = {};
    _selectedTags.forEach((key, value) {
      result[Post.tagToString(key)] = value;
    });
    return result;
  }

  List<Location> get allLocations =>LocationDBManager.allLocations;

  List<Location> get selectableLocations{
    List<Location> result = List.from(LocationDBManager.allLocations);
    result.removeAt(0);
    result.removeWhere((e) => e.deleted);
    return result;
  }

  String getLocationAddressLine(String locationID) {
    if (locationID.trim().isNotEmpty) 
      return LocationDBManager.allLocations.firstWhere((location) => location.id.compareTo(locationID) == 0).addressLine;
    return 'Pending';
  }

  // ! Future Functions
  Future<Null> reloadAllRecords() async{
    await _locationDBManager.fetchAllLocations();
    await _userDBManager.fetchAllUsers();
    await fetchMainPostFeed();
  }
   
   // * ----------------------------NEW STUFF
  Future<Map<TimelinePost, Post>> fetchLikedPostsFeed(List<String> likedPostsIDs) async{
    List<Post> likedPosts = await _postDBManager.fetchPostsByIDs(likedPostsIDs);
    List<TimelinePost> timelinePosts = await _timelinePostDBManager.fetchOriginalLikedPosts(likedPostsIDs);
    Map<TimelinePost,Post> results = {};
    timelinePosts.sort((a,b) => b.postDate.compareTo(a.postDate));
    timelinePosts.forEach((tp) {
      results[tp] = likedPosts.firstWhere((p) => p.id.compareTo(tp.postID)==0);
    });
    return results;
  }

  Future<Map<TimelinePost, Post>> fetchAllUserPosts(String userID) async{
    List<TimelinePost> timelinePosts = await _timelinePostDBManager.fetchUserPosts(userID);
    List<Post> likedPosts = await _postDBManager.fetchPostsByIDs(timelinePosts.map((tp) => tp.postID).toList());
    
    Map<TimelinePost,Post> results = {};
    timelinePosts.sort((a,b) => b.postDate.compareTo(a.postDate));
    timelinePosts.forEach((tp) {
      results[tp] = likedPosts.firstWhere((p) => p.id.compareTo(tp.postID)==0);
    });
    return results;
  }

  // ! important
  Future<Map<TimelinePost, Post>> fetchMainPostFeed() async{
    _feedData.clear();
    await _timelinePostDBManager.fetchHomeFeedTPs();

    List<String> feedIDs = [];
    TimelinePostDBManager.feedTimelinePosts.forEach((tp) {
      if(!feedIDs.contains(tp.postID)) feedIDs.add(tp.postID);
    });
    var feedPosts = await _postDBManager.fetchPostsByIDs(feedIDs);
    
    TimelinePostDBManager.feedTimelinePosts.forEach((tp) {
      _feedData[tp] = feedPosts.firstWhere((e) => e.id.compareTo(tp.postID)==0);
    });
    return _feedData;
  }

  // ! important
  Future<Map<TimelinePost, Post>> fetchPostFeedWithTags() async{
    List<String> tags = []; 
    _feedData.clear();

    _selectedTags.forEach((key, value) {
      if(value){tags.add(Post.tagToString(key));}
    });
    List<Post> posts =  await _postDBManager.fetchPostsByTags(tags);
    List<TimelinePost> tps = await _timelinePostDBManager.fetchFeedWithTags(posts.map((e) => e.id).toList());
    tps.sort((a,b) => b.postDate.compareTo(a.postDate));
  
    tps.forEach((tp) { 
      _feedData[tp] = posts.firstWhere((e) => e.id.compareTo(tp.postID)==0);
    });
    return _feedData;
  }

  Future<List<TimelinePost>> fetchPostUpdatesData(String postID) async{
    return _timelinePostDBManager.fetchTimelinePostsFromPostID(postID);
  }

  // * ---------------------------- END OF NEW STUFF

  // ! Mapping events to state
  @override
  TimelineState get initialState => TimelineInitial();

  @override
  Stream<TimelineState> mapEventToState(TimelineEvent event,) async* {
    if (event is TimelineAddNewPostEvent) yield* _mapNewPostEventToState(event);
    else if(event is TimelineFetchAllPostsEvent) yield* _buildHomeFeed();
    else if (event is TimelinePostUpdateEvent){
      if(event is TimelineUpdatePostEvent) yield* _mapPostUpdateToState(event);
      else yield* _mapPostDeletedToState(event);
    } else if (event is TimelineTagClickedEvent) yield* _mapTagChangeToState(event);
    else if (event is TimelineSearchPostEvent) yield* _mapSearchPageEventToState(event);
    else if (event is TimelineLocationSearchTextChangeEvent) yield* _mapLocationSearchEventToState(event);
    else if (event is TimelineUserUpdatedEvent)yield* _mapUserUpdatedEventToState(event);
    else if (event is TimelineUserDisabledEvent) yield* _mapUserDisabledToState(event);
    else if (event is TimelineUserEnabledEvent) yield* _mapUserEnabledToState(event);
    else if (event is TimelineAboutTabEvent) yield* _mapAboutTabEventToState(event);
    else if(event is TimelineLocationUpdateOccuredEvent) this.mapEventToState(TimelineLocationSearchTextChangeEvent(null));
  }

  Stream<TimelineState> _mapAboutTabEventToState(TimelineAboutTabEvent event) async*{
    if(state is TimelineRebuildAboutTabEvent) yield TimelineRebuildAboutTabState();
  }

  // ! Post Related

  Stream<TimelineState> _buildHomeFeed() async*{
    yield TimelineLoadingFeedState();
    Map<TimelinePost, Post> data = await fetchMainPostFeed();
    yield TimelineFetchedFeedState(data);
  }

  //TODO needs to be redone
  Stream<TimelineState> _mapTagChangeToState(TimelineTagClickedEvent event) async* {
    PostTag selectedTag = _stringToTag(event.tag);
    _selectedTags[selectedTag] = !_selectedTags[selectedTag];

    yield TimelineTagChangedState();
    if(_selectedTags.containsValue(true)){
      yield TimelineLoadingFeedState();
      await fetchPostFeedWithTags();
      yield TimelineFetchedFeedWithTagsState(_feedData);
    }else{
      yield* _buildHomeFeed();
    }
  }

  Stream<TimelineState> _mapSearchPageEventToState(TimelineSearchPostEvent event) async* {
    
  }

  Stream<TimelineState> _mapNewPostEventToState(TimelineAddNewPostEvent event) async*{
    yield TimelineAttemptingToUploadNewPostState();
    await _postDBManager.addPost(event.post);
    TimelinePost timelinePost = _createOriginalTimelinePost(event);
    await _timelinePostDBManager.addTimelinePost(timelinePost);

    _feedData[timelinePost] = event.post;//Needs to be tested
    yield TimelineNewPostUploadedState();
  }

  Stream<TimelineState> _mapPostUpdateToState(TimelineUpdatePostEvent event) async*{
    yield TimelineAttemptingToUploadNewPostState();
    await _postDBManager.updatePost(event.post);
    await _createAndUploadUpdateTPost(event);
   
    yield TimelineRebuildMyPostsPageState(null);
    yield TimelineRebuildFeedState();
    yield TimelineEmptyState();
  }
  
  Stream<TimelineState> _mapPostDeletedToState(TimelinePostUpdateEvent event) async*{
    event.post.deleted = true;
    _postDBManager.updatePost(event.post);
    await _createAndUploadUpdateTPost(event);
    await _timelinePostDBManager.updateDeletedPostTPs(event.post.id);

    await reloadAllRecords();
    yield TimelineRebuildMyPostsPageState(null);
    yield TimelineRebuildFeedState();
    yield TimelineEmptyState();
  }

  TimelinePost _createOriginalTimelinePost(TimelineAddNewPostEvent event) {
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

  // ! Location Related
  Stream<TimelineState> _mapLocationSearchEventToState(TimelineLocationSearchTextChangeEvent event) async* {
    List<Location> result = [];
    _locationSearchString = event.searchString ?? _locationSearchString;
    selectableLocations.forEach((location) {
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

  // ! Lower level details
  PostTag _stringToTag(String tag) {
    switch (tag) {
      case 'Women':return PostTag.WOMEN;
      case 'Men':return PostTag.MEN;
      case 'Youth':return PostTag.YOUTH;
      case 'Kids':return PostTag.KIDS;
      case 'Belfast':return PostTag.BELFAST;
      case 'Northcoast':return PostTag.NORTHCOAST;
      case 'Portadown':return PostTag.PORTADOWN;
      case 'Testimonies':return PostTag.TESTIMONIES;
      case 'Events':return PostTag.EVENTS;
    }
    return null;
  }

  Future _createAndUploadUpdateTPost(TimelinePostUpdateEvent event) async{
    TimelinePost thisTPost = TimelinePost(
        id: '',//this is changed don't worry
        authorID: event.uid,//needs to test
        postDate: DateTime.now(),
        postID: event.post.id,
        updateLog: event.updateLog,
        postType: 'update',
        postDeleted: event.post.deleted
      );
    await _timelinePostDBManager.addTimelinePost(thisTPost);

    if(!event.post.deleted){
       _updatePostInFeedData(event.post);
      _feedData[thisTPost] = event.post;
    }
  }

  void _updatePostInFeedData(Post post){
    List<TimelinePost> timelinePosts = _feedData.keys.where((e) => e.postID.compareTo(post.id)==0).toList();
    timelinePosts.forEach((tp) {
      _feedData[tp] = post;
    });
  }

  /* List<Post> _createList(List<Post> list) {
    if (list == null) return [];
    return list;
  } */
}
