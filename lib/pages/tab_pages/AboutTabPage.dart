import 'package:ctrim_app_v1/blocs/AboutBloc/about_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
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
          title: Text('About Us'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab( text: 'CTRIM',),
              Tab(text: 'Churches',),
              Tab(text: 'Admins',),
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
    String matthewVerse = '“Therefore go and make disciples of all nations, baptizing them in the ' +
    'name of the Father and of the Son and of the Holy Spirit, and ' +
    'teaching them to obey everything I have commanded you. And ' +
    'surely I am with you always, to the very end of the age."';
    String visionParagraph = 'Our vision is to become like the early Church in the Book of Acts, effective ' +
    'and strategic in disciple making. Effective and strategic in harnessing the power of The Holy Spirit, causing ' +
    'them to multiply rapidly and having the power to turn the world upside down for the Glory of God.';
    
    return ListView(
      key: PageStorageKey<String>('AboutTabPageTab1'),
      children: [
        AspectRatio(
          aspectRatio: 16/9,
          child: Container(color: Colors.pink,),
        ),
        SizedBox(height: 8,),
        Text('Christ the Redeemer International Ministries is dedicated and '+
        'committed to making true disciples who will passionately advance the Kingdom of God.', 
        textAlign: TextAlign.center,),
        SizedBox(height: 16,),
        Text('OUR MISSION',textAlign: TextAlign.center,),
        SizedBox(height: 8,),
        Text('To Win Souls and Make Disciples.',textAlign: TextAlign.center,),
        SizedBox(height: 8,),
        Text('Matthew 28:19-20',textAlign: TextAlign.center,),
        Text(matthewVerse,textAlign: TextAlign.center,),
        SizedBox(height: 16,),
        Text('OUR VISION',textAlign: TextAlign.center,),
        SizedBox(height: 8,),
        Text('To become an effective and strategic disciple-making church.',textAlign: TextAlign.center,),
        SizedBox(height: 8,),
        Text(visionParagraph,textAlign: TextAlign.center,),
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
                      BlocProvider.of<AboutBloc>(_context).setArticleToEdit(thisArticle);
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
    List<User> allUsers = BlocProvider.of<TimelineBloc>(_context).allUsers;
    return ListView.builder(
      key: PageStorageKey<String>('AboutTabPageTab3'),
      itemCount: allUsers.length,
      itemBuilder: (_,index){
        User u = allUsers[index];
        return ListTile(
          title: Text(u.forename + ' ' + u.surname),
          subtitle: Text('This is description for item $index'),
          leading: u.buildAvatar(),
          onTap: ()=> BlocProvider.of<AppBloc>(_context).add(AppToViewUserPageEvent(u)),
        );
      }
    );
  }
}