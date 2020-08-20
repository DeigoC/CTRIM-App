import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/appStorage.dart';
import 'package:ctrim_app_v1/classes/firebase_services/idTracker.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';

class LocationDBManager{
  static final CollectionReference _ref = Firestore.instance.collection('locations');

  static List<Location> _allLocations;
  static List<Location> get allLocations => _allLocations;

  final String _subCollection = 'postsReference', _subCollectionDoc = 'postsUsed', _subCollectionField = 'posts';

  final AppStorage _appStorage;

  LocationDBManager(AppBloc appBloc):_appStorage = AppStorage(appBloc);
 
  Future<List<Location>> fetchAllLocations() async{
    var collection = await _ref.getDocuments();
    _allLocations = collection.documents.map((doc) => Location.fromMap(doc.documentID, doc.data)).toList();
    return _allLocations;
  }

  Location getLocationByID(String id){
    return _allLocations.firstWhere((l) => l.id.compareTo(id)==0,orElse: ()=> null);
  }

  Future<Null> addLocation(Location location, File file) async{
    location.id = await IDTracker().getAndUpdateNewLocationID();
    if(file != null){
      location.imgSrc = await _appStorage.uploadAndGetLocationImageSrc(location, file);
    }
    await _ref.document(location.id).setData(location.toJson());
    
    _ref.document(location.id)
    .collection(_subCollection)
    .document(_subCollectionDoc)
    .setData({'posts':[]});

    _allLocations.add(location);
  }

  Future<Null> updateLocation(Location location, File file) async{
    if(file != null){
      location.imgSrc = await _appStorage.uploadAndGetLocationImageSrc(location, file);
    }
    await _ref.document(location.id).setData(location.toJson());
    _updateLocationList(location);
  }

  void updateReferenceList(Post newPost, Post oldPost){
    if(oldPost == null){
      _addReferenceToPost(newPost);
    }else if(newPost.deleted){
      _removeReferenceToPost(oldPost);
    }
    else if(newPost.locationID.compareTo(oldPost.locationID)!=0){
      _updateReferenceToPost(newPost, oldPost);
    }
  }

  Future _addReferenceToPost(Post newPost) async{
    List<String> postIDs = await fetchPostReferenceList(newPost.locationID);
    postIDs.add(newPost.id);
    await _setNewPostReferenceList(newPost.locationID, postIDs);
  }
  
  Future _updateReferenceToPost(Post newPost, Post oldPost) async{
    _removeReferenceToPost(oldPost);
    _addReferenceToPost(newPost);
  }

  Future _removeReferenceToPost(Post post) async{
    List<String> postIDs =  await fetchPostReferenceList(post.locationID);
    postIDs.removeWhere((e) => e.compareTo(post.id)==0);
    await _setNewPostReferenceList(post.locationID, postIDs);
  }

  Future<List<String>> fetchPostReferenceList(String locationID) async{
    var doc = await _ref.document(locationID)
      .collection(_subCollection)
      .document(_subCollectionDoc)
      .get();
    
    return List.from(doc.data[_subCollectionField], growable: true);
  }

  Future _setNewPostReferenceList(String locationID, List<String> postIDs) async{
    await _ref.document(locationID)
      .collection(_subCollection)
      .document(_subCollectionDoc)
      .setData({_subCollectionField:postIDs});
  }

  void _updateLocationList(Location location){
    int index = _allLocations.indexWhere((e) => e.id.compareTo(location.id)==0);
    _allLocations[index] = location;
  }

}