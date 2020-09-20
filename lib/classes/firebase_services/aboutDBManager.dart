import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';


class AboutDBManager{

  final CollectionReference _ref = FirebaseFirestore.instance.collection('about');
  static List<AboutArticle> _allAboutArticles;
  static List<AboutArticle> get allAboutArticles => _allAboutArticles;

  Future<List<AboutArticle>> fetchAllPosts() async{
    var collection = await _ref.get();
    _allAboutArticles = collection.docs.map((doc) => AboutArticle.fromMap(doc.id, doc.data())).toList();
    return _allAboutArticles;
  }

  AboutArticle getArticleByID(String id){
    return _allAboutArticles.firstWhere((e) => e.id.compareTo(id)==0);
  }

  Future<Null> updateAboutArticle(AboutArticle article) async{
    CollectionReference _ref = FirebaseFirestore.instance.collection('about');

    await _ref.doc(article.id).set(article.toJson());
    _updateListArticle(article);
  }

  void _updateListArticle(AboutArticle article){
    int index = _allAboutArticles.indexWhere((e) => e.id.compareTo(article.id)==0);
    _allAboutArticles[index] = article;
  }

}