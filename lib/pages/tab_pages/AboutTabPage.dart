import 'package:ctrim_app_v1/blocs/AboutBloc/about_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:ctrim_app_v1/classes/other/adminCheck.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/gallerySlideShow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/network.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTabPage{

  final BuildContext _context;
  final TabController _tabController;

  AboutTabPage(this._context,this._tabController);

  Widget buildBody(){
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            SizedBox(width: 4,),
            Image.asset('assets/ctrim_logo.png',width: kToolbarHeight,),
            SizedBox(width: 4,),
            Text('About Us'),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab( text: 'CTRIM',),
            Tab(text: 'Churches',),
            Tab(text: 'Contact Us',),
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
    );
  }

  Widget _buildTab1(){
    AboutArticle thisArticle = BlocProvider.of<AboutBloc>(_context).allArticles.first;
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
        GallerySlideShow(galleryItems:thisArticle.gallerySources,),
        SizedBox(height: 32,),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal:8.0),
          child: Text('Christ the Redeemer International Ministries is dedicated and '+
          'committed to making true disciples who will passionately advance the Kingdom of God.', 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18
            ),
          ),
        ),
        SizedBox(height: 64,),

        Text('OUR MISSION',textAlign: TextAlign.center,style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
        SizedBox(height: 18,),

        Text('To Win Souls and Make Disciples.',textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),),
        SizedBox(height: 18,),

        Text('Matthew 28:19-20',textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18,fontStyle: FontStyle.italic,decoration: TextDecoration.underline),),
        
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(matthewVerse,textAlign: TextAlign.center,style: TextStyle(fontSize: 18),),
        ),
        SizedBox(height: 64,),

        Text('OUR VISION',textAlign: TextAlign.center,style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
        SizedBox(height: 18,),

        Text('To become an effective and strategic disciple-making church.',textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),),
        SizedBox(height: 18,),

        Padding(
          padding: EdgeInsets.symmetric(horizontal:8.0),
          child: Text(visionParagraph,textAlign: TextAlign.center,style: TextStyle(fontSize: 18),),
        ),
        SizedBox(height: 16,),

        MyRaisedButton(
          externalPadding: EdgeInsets.all(8),
          label: 'Learn More',
          onPressed: (){
            AppBloc.openURL(thisArticle.socialLinks['Website'], _context);
          },
        ),
        SizedBox(height: 16,),
      ],
    );
  }

  Widget _buildTab2(){
    return BlocBuilder<TimelineBloc, TimelineState>(
      condition: (_,state){
        if(state is TimelineRebuildAboutTabState) return true;
        return false;
      },
      builder:(_,state) {
          List<AboutArticle> articles = List.from(BlocProvider.of<AboutBloc>(_context).allArticles);
          articles.removeAt(0);

        return ListView.builder(
          itemCount: articles.length,
          key: PageStorageKey<String>('AboutTabPageTab2'),
          itemBuilder: (_,index){
            AboutArticle thisArticle = articles[index];
            return InkWell(
              onTap: ()=> BlocProvider.of<AppBloc>(_context).add(AppToViewChurchEvent(articles[index])),
              splashColor: Colors.black,//Colors.black.withAlpha(30),
              child: Container(
                decoration: BoxDecoration(image: DecorationImage(
                  image: NetworkImageWithRetry(thisArticle.firstImage),
                  fit: BoxFit.cover
                )),
                width: double.infinity,
                height: MediaQuery.of(_context).size.height * 0.40,
                child: Stack(
                  children:[ 
                    AdminCheck().isCurrentUserAboveLvl2(_context)?
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        tooltip: 'Edit Details',
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: (){
                          BlocProvider.of<AboutBloc>(_context).setArticleToEdit(thisArticle);
                          BlocProvider.of<AppBloc>(_context).add(AppToEditAboutArticleEvent());
                        },
                      ),
                    ):Container(),
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
    );
  }

  Widget _buildTab3(){
   return ListView(
     children: [
       SizedBox(height: MediaQuery.of(_context).size.height * 0.1,),
       Padding(
         padding: const EdgeInsets.all(8.0),
         child: Text('Got Questions? Get In Touch With Us', textAlign: TextAlign.center, style: TextStyle(fontSize: 32),),
       ),
       SizedBox(height: 8,),
       MyRaisedButton(
         externalPadding: EdgeInsets.all(8),
         label: 'hello@ctrim.co.uk',
         icon: Icons.email,
         onPressed: (){
           _launchEmail();
         },
       ),
      SizedBox(height: 8,),
     ],
   );
  }

  void _launchEmail() {
    final Uri email = Uri(
      scheme: 'mailto',
      path: 'hello@ctrim.co.uk',
      /* queryParameters: {
        'subject':'*Subject*'
      } */
    );
    launch(email.toString());
  }
}