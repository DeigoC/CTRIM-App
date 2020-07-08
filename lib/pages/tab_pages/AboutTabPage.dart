import 'package:flutter/material.dart';

class AboutTabPage{

  final BuildContext _context;
  final TabController _tabController;

  AboutTabPage(this._context, this._tabController);

  Widget buildBody(){
    return NestedScrollView(
      key: PageStorageKey<String>('AboutTabPageNestedScrollKey'),
      headerSliverBuilder: (_,__){
        return [
          SliverAppBar(
            title: Text('About'),
            centerTitle: true,
            leading: null,
            automaticallyImplyLeading: false,
            floating: true,
            pinned: true,
            snap: false,

            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab( text: 'Tab 1',),
                Tab(text: 'Tab 2',),
              ],
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTab1(),
          _buildTab2()
        ],
      ),
    );
  }

  Widget _buildTab1(){
    return ListView.builder(
      key: PageStorageKey<String>('AboutTabPageTab1'),
      itemCount: 20,
      itemBuilder: (_,index){
        return ListTile(
          title: Text('This is item $index'),
          subtitle: Text('This is description for item $index'),
        );
      }
    );
  }

  Widget _buildTab2(){
    return Center(child: Text('Tab 2'),);
  }


}