import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/firebase_services/appStorage.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';

class LocationDBManager{
  static final CollectionReference _ref = Firestore.instance.collection('locations');

  static List<Location> _allLocations;
  static List<Location> get allLocations => _allLocations;

  final AppStorage _appStorage = AppStorage();
 
  Future<List<Location>> fetchAllLocations() async{
    var collection = await _ref.getDocuments();
    _allLocations = collection.documents.map((doc) => Location.fromMap(doc.documentID, doc.data)).toList();
    return _allLocations;
  }

  Location getLocationByID(String id){
    return _allLocations.firstWhere((l) => l.id.compareTo(id)==0,orElse: ()=> null);
  }

  Future<Null> addLocation(Location location, File file) async{
    await _ref.getDocuments().then((collection){
      // TODO: remember to sort ids first!
      location.id = (int.parse(collection.documents.last.documentID) + 1).toString();
    });
    if(file != null){
      location.imgSrc = await _appStorage.uploadAndGetLocationImageSrc(location, file);
    }
    await _ref.document(location.id).setData(location.toJson());
    _allLocations.add(location);
  }

  Future<Null> updateLocation(Location location, File file) async{
    if(file != null){
      location.imgSrc = await _appStorage.uploadAndGetLocationImageSrc(location, file);
    }
    await _ref.document(location.id).setData(location.toJson());
    _updateLocationList(location);
  }

  void _updateLocationList(Location location){
    int index = _allLocations.indexWhere((e) => e.id.compareTo(location.id)==0);
    _allLocations[index] = location;
  }

}