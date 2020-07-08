import 'package:ctrim_app_v1/blocs/AboutBloc/about_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AboutTabPage{

  final BuildContext _context;
  final TabController _tabController;

  AboutTabPage(this._context,this._tabController);

  Widget buildBody(){
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('About CTRIM'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab( text: 'Tab 1',),
              Tab(text: 'Tab 2',),
              Tab(text: 'Tab 3',),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTab1(),
            _buildTab2(),
            _buildTab3()
          ],
        ),
      ),
    );
  }

  Widget _buildTab1(){
    return ListView(
      key: PageStorageKey<String>('AboutTabPageTab1'),
      children: [
        AspectRatio(
          aspectRatio: 16/9,
          child: Container(color: Colors.pink,),
        ),
        SizedBox(height: 8,),
        Text('The rest of the "article" continues here'),
      ],
    );
  }

  Widget _buildTab2(){
    List<AboutArticle> articles = List.from(BlocProvider.of<AboutBloc>(_context).allArticles);
    articles.removeAt(0);
    return ListView.builder(
      itemCount: articles.length,
      key: PageStorageKey<String>('AboutTabPageTab2'),
      itemBuilder: (_,index){
        AboutArticle thisArticle = articles[index];
        return InkWell(
          onTap: ()=> BlocProvider.of<AppBloc>(_context).add(AppToViewChurchEvent(articles[index])),
          splashColor: Colors.blue.withAlpha(30),
          child: Container(
            decoration: BoxDecoration(image: DecorationImage(
              image: NetworkImage(thisArticle.gallerySources.keys.first),
              fit: BoxFit.cover
            )),
            width: double.infinity,
            height: MediaQuery.of(_context).size.height * 0.40,
            child: Stack(
              children:[ 
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: (){
                      BlocProvider.of<AppBloc>(_context).add(AppToEditAboutArticleEvent());
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(thisArticle.title.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 24),),
                  ),
                ),
              ],
            )
          ),
        );
      }
    );
  }

  Widget _buildTab3(){
    return ListView.builder(
      key: PageStorageKey<String>('AboutTabPageTab3'),
      itemCount: 20,
      itemBuilder: (_,index){
        return ListTile(
          title: Text('This is item $index'),
          subtitle: Text('This is description for item $index'),
        );
      }
    );
  }


}