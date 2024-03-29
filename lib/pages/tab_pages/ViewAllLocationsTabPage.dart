import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/locationCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

class ViewAllLocationsPage {
  BuildContext _context;
  final ScrollController _controller;

  void setContext(BuildContext context) => _context = context;

  ViewAllLocationsPage(this._context,this._controller);

  Snap buildBody() {
    List<Location> essentialLocations = BlocProvider.of<TimelineBloc>(_context).essentialLocations;
    
    return Snap(
      controller: _controller.appBar,
      child: BlocBuilder<TimelineBloc, TimelineState>(
        buildWhen: (_, state) {
          if (state is TimelineLocationTabUpdatedState) return true;
          return false;
        },
        builder: (_, state) {
          return ListView.builder(
            physics: ClampingScrollPhysics(),
            key: PageStorageKey('viewAllLocations'),
            controller: _controller,
            itemCount: essentialLocations.length,
            itemBuilder: (_,index){
              return LocationCard(location: essentialLocations[index],);
            }
          );
        },
      ),
    );
  }

  ScrollAppBar buildAppBar(){
    return ScrollAppBar(
      controller: _controller,
      automaticallyImplyLeading: false,
      actions: [IconButton(
        icon: Icon(Icons.search),
        onPressed: (){
          BlocProvider.of<AppBloc>(_context).add(AppToSearchLocationEvent(null));
        },
      )],
      centerTitle: false,
      titleSpacing: 0,
      title: Row(
        children: [
          SizedBox(width: 4,),
          Image.asset('assets/ctrim_logo.png',width: kToolbarHeight,),
          SizedBox(width: 4,),
          Text('Locations'),
        ],
      ),
    );
  }
}
