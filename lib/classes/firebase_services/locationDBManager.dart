import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';

class LocationDBManager{
  static final CollectionReference _ref = Firestore.instance.collection('locations');

  static List<Location> _allLocations;
  static List<Location> get allLocations => _allLocations;
 
  Future<List<Location>> fetchAllLocations() async{
    var collection = await _ref.getDocuments();
    _allLocations = collection.documents.map((doc) => Location.fromMap(doc.documentID, doc.data)).toList();
    return _allLocations;
  }

  Location getLocationByID(String id){
    return _allLocations.firstWhere((l) => l.id.compareTo(id)==0,orElse: ()=> null);
  }

  Future<Null> addLocation(Location location) async{
    await _ref.document(location.id).setData(location.toJson());
  }

  Future<Null> updateLocation(Location location) async{
    await _ref.document(location.id).setData(location.toJson());
  }

}