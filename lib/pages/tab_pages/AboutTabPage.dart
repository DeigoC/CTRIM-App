import 'package:flutter/material.dart';

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
    List<Color> colors = [
      Colors.red,
      Colors.pink,
      Colors.blue,
      Colors.yellow,
    ];
    return ListView.builder(
      itemCount: 4,
      key: PageStorageKey<String>('AboutTabPageTab2'),
      itemBuilder: (_,index){
        return InkWell(
          onTap: ()=> null,
          splashColor: Colors.blue.withAlpha(30),
          child: Container(
            color: colors[index],
            width: double.infinity,
            height: MediaQuery.of(_context).size.height * 0.40,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Church #$index'),
              ),
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