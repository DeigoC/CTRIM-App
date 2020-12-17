import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/locationDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/postDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/postNotification.dart';
import 'package:ctrim_app_v1/classes/firebase_services/timelinePostDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/userDBManager.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  
  
  final UserDBManager _userDBManager = UserDBManager();
  final TimelinePostDBManager _timelinePostDBManager = TimelinePostDBManager();
  PostDBManager _postDBManager;
  LocationDBManager _locationDBManager;
 
  TimelineBloc(AppBloc appBloc) : super(TimelineInitial()){
    _locationDBManager = LocationDBManager(appBloc); // ? No other way?
    _postDBManager = PostDBManager(appBloc);
  }

  // ! Bloc Fields
  List<User> get mainFeedUsers => UserDBManager.mainFeedUsers;

  List<TimelinePost> _feedData =[];
  List<TimelinePost> get feedData {
    _feedData.sort((a,b)=>b.postDate.compareTo(a.postDate));
    return _feedData;
  }

  Map<PostTag, bool> _selectedTags = {
    PostTag.BELFAST: false,
    PostTag.NORTHCOAST: false,
    PostTag.PORTADOWN: false,
    PostTag.ONLINE: false,
    PostTag.TESTIMONIES: false,
    PostTag.EVENTS: false,
    PostTag.YOUTH: false,
    PostTag.MEN: false,
    PostTag.WOMEN: false,
    PostTag.KIDS: false,
    
  };

  // ! Public Bloc Functions
  Future<bool> doesLocationHaveEvents(String locationId) async{ 
    List<String> postRefList = await _locationDBManager.fetchPostReferenceList(locationId);
    return postRefList.length > 0;
  }

  Map<String, bool> getSelectedTags() {
    Map<String, bool> result = {};
    _selectedTags.forEach((key, value) {
      result[Post().tagToString(key)] = value;
    });
    return result;
  }

  List<Location> get essentialLocations => LocationDBManager.essentialLocations;

  Future<Location> fetchLocationByID(String id) => _locationDBManager.fetchLocationByID(id);
  Future<List<Location>> fetchLocationsByPostCode(String postCode, {bool includeDeleted = false}) => 
  _locationDBManager.fetchLocationsBySearchString(postCode, includeDeleted: includeDeleted);
  Future<List<User>> fetchAllUsers() => _userDBManager.fetchAllUsers();
  Future<User> fetchUserByID(String id) => _userDBManager.fetchUserByID(id);
  Future<List<User>> fetchLevel3Users() => _userDBManager.fetchLevel3Users();

  Future<Map<String, dynamic>> fetchChurchData(AboutArticle aboutArticle) async{
    Location churchLocal = await _locationDBManager.fetchLocationByID(aboutArticle.locationID);
    User user = await _userDBManager.fetchUserByID(aboutArticle.locationPastorUID);
    return {'Location':churchLocal, 'User':user};
  }

  Future<Null> processRefresh() async{
    if(_selectedTags.values.contains(true)){
      await Future.delayed(Duration(seconds: 1,milliseconds: 500));
    }else{
      String latestTPId = _feedData.first.id;
      bool timelineUpdated = await _timelinePostDBManager.hasTimelinePostsChanged(latestTPId);
      if(timelineUpdated){
        await fetchMainPostFeed();
        await _userDBManager.fetchMainFeedUsers(_getFeedUsersID(_feedData));
      }
    }
  }

  Future<Map<String,List>> fetchLikedPostsFeed(List<String> likedPostsIDs) async{
    List<TimelinePost> timelinePosts = await _timelinePostDBManager.fetchOriginalPostsByList(likedPostsIDs);
    timelinePosts.sort((a,b) => b.postDate.compareTo(a.postDate));

    List<User> feedUsers = await _userDBManager.fetchListOfUsersByID(_getFeedUsersID(timelinePosts));
    return {'TimelinePosts':timelinePosts, 'FeedUsers':feedUsers};
  }

  Future<List<TimelinePost>> fetchAllUserPosts(String userID) async{
    return _timelinePostDBManager.fetchAllUserPosts(userID);
  }

  Future<List<TimelinePost>> fetchUserPosts(String userID) async{
    return _timelinePostDBManager.fetchUserPosts(userID);
  }

  Future<Map<String,List>> fetchPostsForLocation(String locationID) async{
    List<String> postIDs = await _locationDBManager.fetchPostReferenceList(locationID);
    List<TimelinePost> timelinePosts = await _timelinePostDBManager.fetchOriginalPostsByList(postIDs);
    timelinePosts.sort((a,b) => b.postDate.compareTo(a.postDate));
    List<User> users = await _userDBManager.fetchListOfUsersByID(_getFeedUsersID(timelinePosts));
    return {'TimelinePosts':timelinePosts, 'Users':users};
  }

  Future<Null> fetchMainPostFeed() async{
    _feedData.clear();
    _feedData = await _timelinePostDBManager.fetchHomeFeedTPs();
  }

  List<TimelinePost> _fetchPostFeedWithTags() {
    List<String> tags = []; 
    _selectedTags.forEach((key, value) {
      if(value){tags.add(Post().tagToString(key));}
    });

    List<TimelinePost> newTPs = [];
    _feedData.forEach((tp) {
      if(DeepCollectionEquality.unordered().equals(tp.tags, tags)) newTPs.add(tp);
    });
    newTPs.sort((a,b) => b.postDate.compareTo(a.postDate));

    return newTPs;
  }

  Future<List<TimelinePost>> fetchPostUpdatesData(String postID) async{
    return _timelinePostDBManager.fetchTimelinePostsFromPostID(postID);
  }

  Future<Post> fetchPostByID(String id) async{
    return _postDBManager.fetchPostByID(id);
  }

  // ! Mapping events to state
  @override
  Stream<TimelineState> mapEventToState(TimelineEvent event,) async* {
    if (event is TimelineAddNewPostEvent) yield* _mapNewPostEventToState(event);
    else if(event is TimelineFetchAllPostsEvent) yield* _buildHomeFeed();
    else if (event is TimelinePostUpdateEvent){
      if(event is TimelineUpdatePostEvent) yield* _mapPostUpdateToState(event);
      else yield* _mapPostDeletedToState(event);
    } else if (event is TimelineTagClickedEvent) yield* _mapTagChangeToState(event);
    else if (event is TimelineSearchPostEvent) yield* _mapSearchPageEventToState(event);
    else if (event is TimelineUserUpdatedEvent)yield* _mapUserUpdatedEventToState(event);
    else if (event is TimelineUserDisabledEvent) yield* _mapUserDisabledToState(event);
    else if (event is TimelineUserEnabledEvent) yield* _mapUserEnabledToState(event);
    else if (event is TimelineAboutTabEvent) yield* _mapAboutTabEventToState(event);
    else if(event is TimelineLocationUpdateOccuredEvent) yield _checkToUpdateLocationsTab(event.updatedLocation);
    else if(event is TimelineRefreshCompletedEvent) yield* _mapRefreshToState();
  }

  Stream<TimelineState> _mapRefreshToState() async*{
    yield TimelineEmptyState();
    if(!_selectedTags.values.contains(true)) yield TimelineRebuildFeedState();
  }

  Stream<TimelineState> _mapAboutTabEventToState(TimelineAboutTabEvent event) async*{
    if(state is TimelineRebuildAboutTabEvent) yield TimelineRebuildAboutTabState();
  }

  // ! Post Related
  Stream<TimelineState> _buildHomeFeed() async*{
    yield TimelineLoadingFeedState();
    await fetchMainPostFeed();
    yield TimelineRebuildFeedState();
  }
  
  Stream<TimelineState> _mapTagChangeToState(TimelineTagClickedEvent event) async* {
    PostTag selectedTag = _stringToTag(event.tag);
    _selectedTags[selectedTag] = !_selectedTags[selectedTag];

    yield TimelineTagChangedState();
    if(_selectedTags.containsValue(true)){
      yield TimelinePinPostSnackbarState();
      List<TimelinePost> data = _fetchPostFeedWithTags();
      yield TimelineDisplayFilteredFeedState(data);
    }else{
      yield TimelineUnpinPostSnackbarState();
      yield TimelineDisplayFilteredFeedState(_feedData);
    }
  }

  Stream<TimelineState> _mapSearchPageEventToState(TimelineSearchPostEvent event) async* {
    
  }

  Stream<TimelineState> _mapNewPostEventToState(TimelineAddNewPostEvent event) async*{
    yield TimelineAttemptingToUploadNewPostState();
    await _postDBManager.addPost(event.post);
    _locationDBManager.updateReferenceList(event.post, null);

    TimelinePost timelinePost = _createOriginalTimelinePost(event);
    await _timelinePostDBManager.addTimelinePost(timelinePost);
  
    _feedData.add(timelinePost);
    await _userDBManager.fetchMainFeedUsers(_getFeedUsersID(_feedData));
    yield TimelineNewPostUploadedState();
  }

  Stream<TimelineState> _mapPostUpdateToState(TimelineUpdatePostEvent event) async*{
    yield TimelineAttemptingToUploadNewPostState();
    await _postDBManager.updatePost(event.post);
    await _processUpdateTPost(event);
    
    TimelinePost updatedOriginalTPost = await _timelinePostDBManager.fetchOriginalPostByID(event.post.id);
   
    await processRefresh();
    PostNotification().notifyAllTokensAboutUpdate(PostNotificationMessage(
        body: event.updateLog, 
        postID: event.post.id, 
        title: event.post.title,
        imageSrc: event.post.firstImageSrc,
    ));
    yield TimelineRebuildMyPostsPageState(updatedOriginalTPost);
    yield TimelineRebuildFeedState();
    yield TimelineEmptyState();
  }
  
  Stream<TimelineState> _mapPostDeletedToState(TimelinePostUpdateEvent event) async*{
    yield TimelineAttemptingToUploadNewPostState();
    event.post.deleted = true;
    _postDBManager.updatePost(event.post);
    await _processUpdateTPost(event);
    
    TimelinePost updatedOriginalTPost = await _timelinePostDBManager.fetchOriginalPostByID(event.post.id);
    
    await processRefresh();
    yield TimelineRebuildMyPostsPageState(updatedOriginalTPost);
    yield TimelineRebuildFeedState();
    yield TimelineEmptyState();
  }

  // ! User Related
  Stream<TimelineState> _mapUserUpdatedEventToState(TimelineUserUpdatedEvent event) async*{
    _userDBManager.updateUser(event.updatedUser);
    yield TimelineRebuildUserListState();
    yield TimelineEmptyState();
  }

  Stream<TimelineState> _mapUserDisabledToState(TimelineUserDisabledEvent event) async* {
    event.user.disabled = true;
    _userDBManager.updateUser(event.user);
    yield TimelineRebuildUserListState();
    yield TimelineEmptyState();
  }

  Stream<TimelineState> _mapUserEnabledToState(TimelineUserEnabledEvent event) async*{
    event.user.disabled = false;
    _userDBManager.updateUser(event.user);
    yield TimelineRebuildUserListState();
    yield TimelineEmptyState();
  }

  // ! Location Related
  //TODO needs to add new location as well?
  TimelineState _checkToUpdateLocationsTab(Location updatedLocation){
    if(essentialLocations.firstWhere((e) => e.id.compareTo(updatedLocation.id)==0, orElse: ()=>null) !=null ){
      int index = essentialLocations.indexWhere((e) => e.id.compareTo(updatedLocation.id)==0,);
      essentialLocations[index] = updatedLocation;
      return TimelineLocationTabUpdatedState();
    }
    return null;
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
      case 'Online':return PostTag.ONLINE;
    }
    return null;
  }

  Future _processUpdateTPost(TimelinePostUpdateEvent event) async{
    String thumbnailSrc='';
    Map<String,String> gallerySrc ={};
    if(event.post.gallerySources.length!=0){
       gallerySrc = _getTPGallerySrc(event.post);
      if(gallerySrc.values.first=='vid'){
        thumbnailSrc = event.post.thumbnails[gallerySrc.keys.first];
      }
    }
    
    TimelinePost thisTPost = TimelinePost(
      id: '',
      authorID: event.uid,
      postDate: DateTime.now(),
      postID: event.post.id,
      updateLog: event.updateLog,
      postType: 'update',
      postDeleted: event.post.deleted,

      title: event.post.title,
      description: event.post.description,
      thumbnailSrc: thumbnailSrc,
      gallerySources: gallerySrc,
      tags: event.post.selectedTagsString
    );

    await _timelinePostDBManager.updateAllTPsWithPostID(thisTPost.postID, thisTPost);
    await _timelinePostDBManager.addTimelinePost(thisTPost);
  }

  TimelinePost _createOriginalTimelinePost(TimelineAddNewPostEvent event) {
    String thumbnailSrc='';
    Map<String,String> gallerySrc ={};
    if(event.post.gallerySources.length!=0){
       gallerySrc = _getTPGallerySrc(event.post);
      if(gallerySrc.values.first=='vid'){
        thumbnailSrc = event.post.thumbnails[gallerySrc.keys.first];
      }
    }

    return TimelinePost(
      postID: event.post.id,
      postType: 'original',
      authorID: event.authorID,
      updateLog: '',
      postDate: DateTime.now(),
      postDeleted: false,

      title: event.post.title,
      description: event.post.description,
      gallerySources: gallerySrc,
      thumbnailSrc: thumbnailSrc,
      tags: event.post.selectedTagsString
    );
  }

  List<String> _getFeedUsersID(List<TimelinePost> tps){
    List<String> results = [];
    tps.forEach((tp) {
      if(!results.contains(tp.authorID)) results.add(tp.authorID);
    });
    return results;
  }

  Map<String,String> _getTPGallerySrc(Post post){
    Map<String,String> result ={};

    if(post.gallerySources.length!=0){
      if(post.gallerySources.values.first.compareTo('vid')==0){
       result[post.gallerySources.keys.first] = 'vid';
      }else{
        for (var i = 0; i < post.gallerySources.length; i++) {
          String src = post.gallerySources.keys.elementAt(i);
          if(post.gallerySources[src]=='img'){
            result[src]='img';
          }
          if(result.length==4) break;
        }
      }
    }
    return result;
  }
}
