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

  List<Post> get _allPosts => PostDBManager.allPosts;

  List<TimelinePost> get _allTimelinePosts => TimelinePostDBManager.allTimelinePosts;

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
      result[Post.tagToString(key)] = value;
    });
    return result;
  }

  Map<Post, TimelinePost> getUserPosts(String userID) {
    Map<Post, TimelinePost> results = {};
    _allTimelinePosts.forEach((timelinePost) {
      if (timelinePost.authorID.compareTo(userID) == 0 && timelinePost.postType.compareTo('original') == 0) {
        Post thisPost = _allPosts.firstWhere((post) => post.id.compareTo(timelinePost.postID) == 0);
        if(!thisPost.deleted) results[thisPost] = timelinePost;
      }
    });
    return results;
  }

  Map<Post, TimelinePost> getUserDeletedPosts(String userID) {
    Map<Post, TimelinePost> results = {};
    _allTimelinePosts.forEach((timelinePost) {
      if (timelinePost.authorID.compareTo(userID) == 0 && timelinePost.postType.compareTo('original') == 0) {
        Post thisPost = _allPosts.firstWhere((post) => post.id.compareTo(timelinePost.postID) == 0);
        if(thisPost.deleted) results[thisPost] = timelinePost;
      }
    });
    return results;
  }

  Map<Post, TimelinePost> getPostsFromLocation(String locationID){
    Map<Post, TimelinePost> results = {};
    _allPosts.forEach((post) {
      if(post.locationID.compareTo(locationID)==0 && !post.deleted){
        TimelinePost tPost = _allTimelinePosts.firstWhere((e){
          return (e.postID.compareTo(post.id)==0 && e.postType.compareTo('original')==0);
        });
        results[post] = tPost;
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
            DateTime thisDate = DateTime(thisPost.startDate.year, thisPost.startDate.month, thisPost.startDate.day);
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

  TimelineDisplayFeedState get initialPostsData => _buildFeedData();

  // ! Mapping events to state
  @override
  TimelineState get initialState => TimelineInitial();

  @override
  Stream<TimelineState> mapEventToState(TimelineEvent event,) async* {
    if (event is TimelineFetchAllPostsEvent)yield* _displayFeedStream();
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
    else if (event is TimelineAboutTabEvent) yield* _mapAboutTabEventToState(event);
    else if(event is TimelineLocationUpdateOccuredEvent) this.mapEventToState(TimelineLocationSearchTextChangeEvent(null));
  }

  Stream<TimelineState> _mapAboutTabEventToState(TimelineAboutTabEvent event) async*{
    if(state is TimelineRebuildAboutTabEvent) yield TimelineRebuildAboutTabState();
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
    
    yield* _displayFeedStream();
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
    yield TimelineAttemptingToUploadNewPostState();
    await _postDBManager.addPost(event.post);
     TimelinePost timelinePost = _generateTimelinePost(event);
    await _timelinePostDBManager.addTimelinePost(timelinePost);
    yield TimelineNewPostUploadedState();
    yield* _displayFeedStream();
  }

  Stream<TimelineState> _displayFeedStream() async*{
    yield TimelineEmptyState();
    yield _buildFeedData();
  }

  TimelineDisplayFeedState _buildFeedData(){
    List<Post> posts = [];
    List<TimelinePost> tPosts = [];
    List<PostTag> selectedTags = [];

    if (_selectedTags.values.contains(true)) {
      _selectedTags.forEach((key, value) {
        if (value) selectedTags.add(key);
      });

      // * Add all posts that contains exactly selected tags
      _allPosts.forEach((post) {
        if(DeepCollectionEquality.unordered().equals(post.selectedTags, selectedTags)){
          posts.add(post);
        }
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
      // * Otherwise add all posts
      posts = List.from(_allPosts);
      tPosts = List.from(_allTimelinePosts);
    }
   
   // * Remove all deleted then sort by post date
    posts.removeWhere((element) => element.deleted);
    tPosts.removeWhere((tPost) => posts.firstWhere((post) => post.id == tPost.postID, orElse: ()=> null) ==null);
    tPosts.sort((x, y) => y.postDate.compareTo(x.postDate));
    
    return TimelineDisplayFeedState(
      users: allUsers,
      posts: posts,
      timelines: tPosts,
    );
  }

  Stream<TimelineState> _mapPostUpdateToState(TimelineUpdatePostEvent event) async*{
    yield TimelineAttemptingToUploadNewPostState();
    await _postDBManager.updatePost(event.post);
    _createUpdateTPost(event);
   
    yield TimelineRebuildMyPostsPageState(getUserPosts(event.uid));
    yield TimelineEmptyState();
  }

  Stream<TimelineState> _mapPostDeletedToState(TimelinePostUpdateEvent event) async*{
    event.post.deleted = true;
    _postDBManager.updatePost(event.post);
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

  void _createUpdateTPost(TimelinePostUpdateEvent event) {
    String authorID = _allTimelinePosts.firstWhere((tPost) => tPost.postID.compareTo(event.post.id) == 0).authorID;
    TimelinePost thisTPost = TimelinePost(
        id: (int.parse(_allTimelinePosts.last.id) + 1).toString(),//this is changed don't worry
        authorID: authorID,
        postDate: DateTime.now(),
        postID: event.post.id,
        updateLog: event.updateLog,
        postType: 'update'
      );
    _timelinePostDBManager.addTimelinePost(thisTPost);
  }

  List<Post> _createList(List<Post> list) {
    if (list == null) return [];
    return list;
  }
}
