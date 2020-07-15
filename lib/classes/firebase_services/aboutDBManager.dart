import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';

class AboutDBManager{

  final CollectionReference _ref = Firestore.instance.collection('about');

  static List<AboutArticle> _allAboutArticles;
  static List<AboutArticle> get allAboutArticles => _allAboutArticles;

  Future<List<AboutArticle>> fetchAllPosts() async{
    var collection = await _ref.getDocuments();
    _allAboutArticles = collection.documents.map((doc) => AboutArticle.fromMap(doc.documentID, doc.data)).toList();
    return _allAboutArticles;
  }

  AboutArticle getArticleByID(String id){
    return _allAboutArticles.firstWhere((e) => e.id.compareTo(id)==0);
  }

  Future<Null> updateAboutArticle(AboutArticle article) async{
    await _ref.document(article.id).setData(article.toJson());
  }

  void updateListArticle(AboutArticle article){
    int index = _allAboutArticles.indexWhere((e) => e.id.compareTo(article.id)==0);
    _allAboutArticles[index] = article;
  }

}