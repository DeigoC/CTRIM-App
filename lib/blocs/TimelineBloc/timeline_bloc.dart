import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  // ! Test Data
  List<Post> _testPosts = [
    Post(
        id: '1',
        title: 'Title here',
        locationID: '1',
        eventDate: DateTime.now().subtract(Duration(days: 16)),
        description: 'This is the first test of so many to come',
        gallerySources: {
          'https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fstatic.onecms.io%2Fwp-content%2Fuploads%2Fsites%2F38%2F2016%2F05%2F12214218%2Fsimple_bites_family_backyard.jpg&q=85':
              'img',
          'https://i.ytimg.com/vi/mwux1_CNdxU/maxresdefault.jpg': 'img',
          'https://www.lakedistrict.gov.uk/__data/assets/image/0018/123390/families-and-children.jpg':
              'img',
        },
        selectedTags: [PostTag.YOUTH],
        body:
            '[{"insert":"This is a test"},{"insert":"\\n","attributes":{"heading":1}},{"insert": "\\n item 1"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"item 2"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"another item"},{"insert":"\\n","attributes":{"block":"ol"}}]',
        detailTableHeader: 'This is the header for the table',
        detailTable: [
          ['Item 1', 'This is test number 1'],
          ['Really long item 2 which is pretty long', 'This is test number 2'],
          ['', 'This is the trailing of test 3']
        ]),
    Post(
        id: '2',
        title: 'Title Post #2',
        eventDate: DateTime.now().subtract(Duration(days: 7)),
        description: '',
        body:
            '[{"insert":"This is a test"},{"insert":"\\n","attributes":{"heading":1}},{"insert": "\\n item 1"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"item 2"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"another item"},{"insert":"\\n","attributes":{"block":"ol"}}]',
        detailTable: [],
        detailTableHeader: '',
        locationID: '2',
        selectedTags: [PostTag.YOUTH, PostTag.CHURCH],
        gallerySources: {
          'https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/screen-shot-2020-04-09-at-12-29-32-pm-1586449781.png?crop=1.00xw:0.985xh;0,0.0151xh&resize=480:*':
              'img',
          'https://www.netbase.com/wp-content/uploads/Brands%E2%80%99-Meme-Marketing-Makes-Sentiment-Analysis-More-Important-Than-Ever.png':
              'img',
        }),
    Post(
        id: '3',
        eventDate: DateTime.now().subtract(Duration(days: 5)),
        title: 'Title Post #3 and this one will be the long title',
        description: 'The big image',
        body:
            '[{"insert":"This is a test"},{"insert":"\\n","attributes":{"heading":1}},{"insert": "\\n item 1"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"item 2"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"another item"},{"insert":"\\n","attributes":{"block":"ol"}}]',
        detailTable: [],
        detailTableHeader: '',
        locationID: '2',
        selectedTags: [PostTag.YOUTH, PostTag.CHURCH],
        gallerySources: {
          'https://mamasgeeky.com/wp-content/uploads/2020/03/coronavirus-meme-1.jpg':
              'img',
        }),
    Post(
        id: '4',
        eventDate: DateTime.now().subtract(Duration(days: 2)),
        title: 'Youth dayout at London Bridge',
        description:
            'So this day we went to London Bridge, pretty cool eh? Yeah this is going to be a long description i hope. This is supposed to be at least 2 lines',
        locationID: '0',
        body:
            '[{"insert":"This is a test"},{"insert":"\\n","attributes":{"heading":1}},{"insert": "\\n item 1"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"item 2"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"another item"},{"insert":"\\n","attributes":{"block":"ol"}}]',
        detailTable: [],
        detailTableHeader: '',
        selectedTags: [PostTag.WOMEN],
        gallerySources: {}),
    Post(
        id: '5',
        eventDate: DateTime.now().add(Duration(days: 2)),
        isDateNotApplicable: true,
        title: 'Youth dayout at London Bridge, The Sequel!',
        description:
            'So this day we went to London Bridge, pretty cool eh? \nWell this is something...',
        locationID: '0',
        body:
            '[{"insert":"This is a test"},{"insert":"\\n","attributes":{"heading":1}},{"insert": "\\n item 1"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"item 2"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"another item"},{"insert":"\\n","attributes":{"block":"ol"}}]',
        detailTable: [],
        detailTableHeader: '',
        selectedTags: [PostTag.WOMEN],
        gallerySources: {
          'https://img.delicious.com.au/WqbvXLhs/del/2016/06/more-the-merrier-31380-2.jpg':
              'img',
          'https://teamjimmyjoe.com/wp-content/uploads/2019/09/funny-memes-america-one-picture-ronald-mcdonald.jpg':
              'img',
          'https://i.ytimg.com/vi/Zo_Y-n__Cbc/maxresdefault.jpg': 'img',
          'https://www.demilked.com/magazine/wp-content/uploads/2019/10/5da8209a0da15-8-5cac5c63d855a__700.jpg':
              'img',
        }),
  ];

  List<TimelinePost> _testTimelinePosts = [
    TimelinePost(
        id: '1',
        postID: '1',
        postType: 'original',
        authorID: '1',
        postDate: DateTime.now().subtract(Duration(days: 2))),
    TimelinePost(
        id: '2',
        postID: '2',
        postType: 'original',
        authorID: '2',
        postDate: DateTime.now().subtract(Duration(days: 14))),
    TimelinePost(
        id: '3',
        postID: '2',
        postType: 'update',
        authorID: '2',
        updateLog: 'This is a test log',
        postDate: DateTime.now().subtract(Duration(days: 1))),
    TimelinePost(
        id: '4',
        postID: '3',
        postType: 'original',
        authorID: '1',
        postDate: DateTime.now().subtract(Duration(days: 30))),
    TimelinePost(
        id: '5',
        postID: '4',
        postType: 'original',
        authorID: '1',
        postDate: DateTime.now().subtract(Duration(days: 2))),
    TimelinePost(
        id: '6',
        postID: '5',
        postType: 'original',
        authorID: '2',
        postDate: DateTime.now().subtract(Duration(days: 1))),
  ];

  List<User> _testUsers = [
    User(
      id: '1',
      forename: 'Diego',
      surname: 'Collado',
      email: 'diego@email',
      adminLevel: 3,
      contactNo: '012301230',
      likedPosts: [],
    ),
    User(
      id: '3',
      forename: 'Claudette',
      surname: 'Collado',
      email: 'claudette@email',
      adminLevel: 2,
      contactNo: '0111111111111110',
      likedPosts: [],
    ),
    User(
      id: '2',
      forename: 'Dana',
      surname: 'Collado',
      email: 'DaNa@email',
      adminLevel: 1,
      contactNo: '0111111111111110',
      likedPosts: [],
    ),
  ];

  List<Location> _testLocations = [
    Location(
        id: '0',
        addressLine: 'Address not Required',
        description: "When the post doesn't require this field - select this"),
    Location(
        id: '1',
        addressLine: '48 The Demesne, Carryduff, Belfast, BT8 8GU',
        description: 'Used for events',
        imgSrc: 'https://img2.propertypal.com/hd/p/595087/17026074.jpg'),
    Location(
        id: '2',
        addressLine: '5-7 Conway St, Belfast BT13 2DE',
        description: 'Church Building #•2',
        imgSrc:
            'https://media-cdn.tripadvisor.com/media/photo-s/06/e2/e4/c1/conway-mill-preservation.jpg'),
    Location(
        id: '3',
        addressLine: '81 Saintfield Rd, Belfast BT8 7HN',
        description: "Domino's Pizza"),
    Location(
        id: '4',
        addressLine: '461 Ormeau Rd, Ormeau, Belfast BT7 3GR',
        description: 'Subway Ormeau'),
    Location(
        id: '5',
        addressLine: '369 Lisburn Rd, Belfast BT9 7EP',
        description: 'Tesco Workplace'),
    Location(
        id: '6',
        addressLine: '95 Saintfield Rd, Carryduff, CountyDown BT8 8ER',
        description: 'KFC KFC KFC!'),
  ];

  // ! Bloc Fields
  String _locationSearchString = '';

  List<User> get allUsers => _testUsers;

  Map<PostTag, bool> _selectedTags = {
    PostTag.YOUTH: false,
    PostTag.CHURCH: false,
    PostTag.WOMEN: false,
  };

  // ! Bloc Functions
  bool doesLocationHaveEvents(String locationId){ 
    for (var i = 0; i < _testPosts.length; i++) {
      if(_testPosts[i].locationID.compareTo(locationId)==0) return true;
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
    _testTimelinePosts.forEach((timelinePost) {
      if (timelinePost.authorID.compareTo(userID) == 0 && timelinePost.postType.compareTo('original') == 0) {
        Post thisPost = _testPosts.firstWhere((post) => post.id.compareTo(timelinePost.postID) == 0);
        if(!thisPost.deleted) results[thisPost] =timelinePost.getPostDateString();
      }
    });
    return results;
  }

  Map<Post, String> getUserDeletedPosts(String userID) {
    Map<Post, String> results = {};
    _testTimelinePosts.forEach((timelinePost) {
      if (timelinePost.authorID.compareTo(userID) == 0 && timelinePost.postType.compareTo('original') == 0) {
        Post thisPost = _testPosts.firstWhere((post) => post.id.compareTo(timelinePost.postID) == 0);
        if(thisPost.deleted) results[thisPost] = timelinePost.getPostDateString();
      }
    });
    return results;
  }

  Map<DateTime, List<Post>> getPostsForGalleryTab() {
    Map<DateTime, List<Post>> result = {};

    _testTimelinePosts.forEach((tPost) {
      if (tPost.postType.compareTo('original') == 0) {
        Post thisPost = _testPosts.firstWhere((post) => post.id.compareTo(tPost.postID) == 0);
        if (thisPost.gallerySources.length != 0 && !thisPost.deleted) {
          if (thisPost.isDateNotApplicable) {
            result[tPost.postDate] = _createList(result[tPost.postDate]);
            result[tPost.postDate].add(thisPost);
          } else {
            result[thisPost.eventDate] =_createList(result[thisPost.eventDate]);
            result[thisPost.eventDate].add(thisPost);
          }
        }
      }
    });
    result.keys.toList().sort((a, b) => a.compareTo(b));
    return result;
  }

  List<Location> get allLocations => _testLocations;

  List<Location> get locationsForTab {
    List<Location> result = List.from(_testLocations);
    result.removeAt(0);
    result.removeWhere((e) => e.deleted);
    return result;
  }

  String getLocationAddressLine(String locationID) {
    if (locationID.trim().isNotEmpty) {
      return _testLocations
          .firstWhere((location) => location.id.compareTo(locationID) == 0)
          .addressLine;
    }
    return 'Pending';
  }

  List<TimelinePost> getAllUpdatePosts(String postID){
    List<TimelinePost> result = [];
    _testTimelinePosts.forEach((tPost) {
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
    if (event is TimelineFetchAllPostsEvent)yield _displayFeed();
    else if (event is TimelineAddNewPostEvent)yield _mapNewPostEventToState(event);
    else if (event is TimelinePostUpdateEvent){
      if(event is TimelineUpdatePostEvent) yield _mapPostUpdateToState(event);
      else yield _mapPostDeletedToState(event);
    } else if (event is TimelineTagClickedEvent) yield* _mapTagChnageToState(event);
    else if (event is TimelineSearchPostEvent) yield* _mapSearchPageEventToState(event);
    else if (event is TimelineLocationSearchTextChangeEvent) yield* _mapLocationSearchEventToState(event);
    else if (event is TimelineAlbumSearchEvent)yield* _mapAlbumSearchEventToState(event);
    else if (event is TimelineUserUpdatedEvent)yield _mapUserUpdatedEventToState(event);
    else if (event is TimelineDisplayCurrentUserLikedPosts)yield _getCurrentUserLikedPosts(event.likedPosts);
    else if(event is TimelineUserDisabledEvent) yield _mapUserDisabledToState(event);
    else if(event is TimelineUserEnabledEvent) yield _mapUserEnabledToState(event);
    else if(event is TimelineLocationDeletedEvent) _mapLocationDeletedToState(event);
  }

  Stream<TimelineState> _mapAlbumSearchEventToState(TimelineAlbumSearchEvent event) async* {
    if (event is TimelineAlbumSearchTextChangeEvent) {
      List<Post> results = [];
      _testPosts.forEach((post) {
        if (post.title.toLowerCase().contains(event.newSearch.toLowerCase()) &&
            post.gallerySources.length != 0) {
          results.add(post);
        }
      });
      yield TimelineAlbumDisplaySearchResultsState(results);
      yield TimelineEmptyState();
    }
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

  Stream<TimelineState> _mapTagChnageToState(TimelineTagClickedEvent event) async* {
    PostTag selectedTag = _stringToTag(event.tag);
    _selectedTags[selectedTag] = !_selectedTags[selectedTag];

    yield TimelineTagChangedState();
    yield _displayFeed();
  }

  Stream<TimelineState> _mapLocationSearchEventToState( TimelineLocationSearchTextChangeEvent event) async* {
    List<Location> result = [];
    _locationSearchString = event.searchString ?? _locationSearchString;
    _testLocations.forEach((location) {
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

  TimelineState _displayFeedBySearch(String search) {
    List<Post> posts = [];
    List<TimelinePost> tPosts = [];

    // * Get all Posts that contains the search string in their titles
    _testPosts.forEach((post) {
      if (post.title.toLowerCase().contains(search.toLowerCase()) &&
          !posts.contains(post)) {
        posts.add(post);
      }
    });

    if (posts.length == 0) return TimelineDisplayEmptyFeedState();

    // * Get all original tPosts that contains the posts
    posts.forEach((post) {
      _testTimelinePosts.forEach((tPost) {
        if (tPost.postID.compareTo(post.id) == 0 &&
            tPost.postType == 'original' &&
            !tPosts.contains(tPost)) {
          tPosts.add(tPost);
        }
      });
    });

    return TimelineDisplaySearchFeedState(
      users: _testUsers,
      posts: posts,
      timelines: tPosts,
    );
  }

  TimelineState _mapNewPostEventToState(TimelineAddNewPostEvent event) {
    _insertPostID(event.post);
    TimelinePost timelinePost = _generateTimelinePost(event.post);
    _testPosts.add(event.post);
    _testTimelinePosts.add(timelinePost);
    return _displayFeed();
  }

  TimelineState _displayFeed() {
    _testTimelinePosts.sort((x, y) => y.postDate.compareTo(x.postDate));
    List<Post> posts = [];
    List<TimelinePost> tPosts = [];
    List<PostTag> selectedTags = [];

    if (_selectedTags.values.contains(true)) {
      _selectedTags.forEach((key, value) {
        if (value) selectedTags.add(key);
      });

      // * Add all posts that contains selected tags
      selectedTags.forEach((selectedTag) {
        _testPosts.forEach((post) {
          if (post.selectedTags.contains(selectedTag) && !posts.contains(post)) {
            posts.add(post);
          }
        });
      });

      // * Add all timeline posts that contains the post
      posts.forEach((post) {
        _testTimelinePosts.forEach((tPost) {
          if (tPost.postID.compareTo(post.id) == 0 && !tPosts.contains(tPost)) {
            tPosts.add(tPost);
          }
        });
      });

    } else {
      posts = List.from(_testPosts);
      tPosts = List.from(_testTimelinePosts);
    }

    // ! NOT TOO SURE ABOUT THESE TWO
    posts.removeWhere((element) => element.deleted);
    tPosts.removeWhere((tPost) => posts.firstWhere((post) => post.id == tPost.postID, orElse: ()=> null) ==null);

    return TimelineDisplayFeedState(
      users: _testUsers,
      posts: posts,
      timelines: tPosts,
    );
  }

  TimelineState _mapUserUpdatedEventToState(TimelineUserUpdatedEvent event) {
    int index = _testUsers
        .indexWhere((user) => user.id.compareTo(event.updatedUser.id) == 0);
    _testUsers[index] = event.updatedUser;
    return TimelineEmptyState();
  }

  TimelineState _mapPostUpdateToState(TimelineUpdatePostEvent event) {
    int index = _testPosts.indexWhere((post) => post.id.compareTo(event.post.id) == 0);
    _testPosts[index] = event.post;
    _createUpdateTPost(event);
    return TimelineRebuildMyPostsPageState(getUserPosts(event.uid));
  }

  TimelineState _mapPostDeletedToState(TimelinePostUpdateEvent event){
    int index = _testPosts.indexWhere((post) => post.id.compareTo(event.post.id) == 0);
    _testPosts[index].deleted = true;
    _createUpdateTPost(event);
    return TimelineRebuildMyPostsPageState(getUserPosts(event.uid));
  }

  TimelinePost _generateTimelinePost(Post post) {
    return TimelinePost(
      postID: post.id,
      postType: 'original',
      authorID: '1',
      postDate: DateTime.now(),
    );
  }

  TimelineState _mapUserDisabledToState(TimelineUserDisabledEvent event){
    int index = _testUsers.indexWhere((e) => e.id == event.user.id);
    _testUsers[index].disabled = true;
    return TimelineRebuildUserListState();
  }

  TimelineState _mapUserEnabledToState(TimelineUserEnabledEvent event){
    int index = _testUsers.indexWhere((e) => e.id == event.user.id);
    _testUsers[index].disabled = false;
    return TimelineRebuildUserListState();
  }

  TimelineDisplaySearchFeedState _getCurrentUserLikedPosts(List<String> postIDs) {
    List<Post> posts = [];
    List<TimelinePost> tPosts = [];

    _testPosts.forEach((post) {
      if (postIDs.contains(post.id)) {
        posts.add(post);
      }
    });

    posts.forEach((post) {
      _testTimelinePosts.forEach((tPost) {
        if (tPost.postID.compareTo(post.id) == 0 &&
            tPost.postType == 'original' &&
            !tPosts.contains(tPost)) {
          tPosts.add(tPost);
        }
      });
    });

    return TimelineDisplaySearchFeedState(
      users: _testUsers,
      posts: posts,
      timelines: tPosts,
    );
  }

  void _mapLocationDeletedToState(TimelineLocationDeletedEvent event){
    int index = _testLocations.indexWhere((e) => e.id.compareTo(event.location.id)==0);
    _testLocations[index].deleted = true;
    this.mapEventToState(TimelineLocationSearchTextChangeEvent(null));
  }

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
    post.id = (int.parse(_testPosts.last.id) + 1).toString();
  }

  void _createUpdateTPost(TimelinePostUpdateEvent event) {
    String authorID = _testTimelinePosts.firstWhere((tPost) => tPost.postID.compareTo(event.post.id) == 0).authorID;
    _testTimelinePosts.add(TimelinePost(
        id: (int.parse(_testTimelinePosts.last.id) + 1).toString(),
        authorID: authorID,
        postDate: DateTime.now(),
        postID: event.post.id,
        updateLog: event.updateLog,
        postType: 'update'));
  }

  List<Post> _createList(List<Post> list) {
    if (list == null) return [];
    return list;
  }

  //TODO this should not exist
  void updateLocation(Location location) {
    int index =
        _testLocations.indexWhere((l) => l.id.compareTo(location.id) == 0);
    _testLocations[index] = location;
  }
}
