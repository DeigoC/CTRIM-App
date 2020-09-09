import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/locationCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

class ViewAllLocationsPage {
  BuildContext _context;
  final ScrollController _controller;

  void setContext(BuildContext context) => _context = context;

  ViewAllLocationsPage(this._context,this._controller);

  Widget buildBody() {
    List<Location> essentialLocations = BlocProvider.of<TimelineBloc>(_context).essentialLocations;
    
    return Snap(
      controller: _controller.appBar,
      child: BlocBuilder<TimelineBloc, TimelineState>(
        condition: (_, state) {
          if (state is TimelineDisplayLocationSearchResultsState) return true;
          return false;
        },
        builder: (_, state) {
          if (state is TimelineDisplayLocationSearchResultsState) {
            essentialLocations = state.locations;
          }
          return ListView.builder(
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

  Widget buildAppBar(){
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
      title: Row(
        children: [
          Icon(FontAwesome5Solid.church,color: Colors.white,),
          SizedBox(width: 24,),
          Text('Locations'),
        ],
      ),
    );
   //return LocationSearchBar(_controller);
  }
}

class LocationSearchBar extends StatefulWidget with PreferredSizeWidget {
  final ScrollController _controller;
  LocationSearchBar(this._controller);

  @override
  _LocationSearchBarState createState() => _LocationSearchBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _LocationSearchBarState extends State<LocationSearchBar>{
  FocusNode _fnSearch;
  TextEditingController _tecSearch;
  bool _searchMode = false;

  @override
  void initState() {
    _tecSearch = TextEditingController();
    _fnSearch = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _fnSearch.dispose();
    _tecSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollAppBar(
      controller: widget._controller,
      automaticallyImplyLeading: false,
      titleSpacing: 8,
      actions: _searchMode ? null: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              _searchMode = !_searchMode;
              _fnSearch.requestFocus();
              widget._controller.appBar.tooglePinState();
            });
          },
          tooltip: 'Search for address',
        ),
      ],
      title: _searchMode ? TextField(
        controller: _tecSearch,
        focusNode: _fnSearch,
        onChanged: (newSearch) {
          setState(() {
            BlocProvider.of<TimelineBloc>(context)
            .add(TimelineLocationSearchTextChangeEvent(newSearch));
          });
        },
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(8),
            hintText: 'Search by Address',
            suffixIcon: IconButton(
              icon: (_tecSearch.text.length > 0)
                  ? Icon(Icons.clear)
                  : Icon(Icons.keyboard_arrow_right),
              onPressed: () {
                if (_tecSearch.text.length > 0) {
                  setState(() {
                    _tecSearch.clear();
                    BlocProvider.of<TimelineBloc>(context)
                        .add(TimelineLocationSearchTextChangeEvent(''));
                  });
                } else {
                  setState(() {
                    _searchMode = !_searchMode;
                    //widget._controller.appBar.setPinState(_searchMode);
                    widget._controller.appBar.tooglePinState();//?
                    FocusScope.of(context).requestFocus();
                  });
                }
              },
            )),
      ): Row(
        children: [
          Icon(FontAwesome5Solid.church,color: Colors.white,),
          SizedBox(width: 24,),
          Text('Locations'),
        ],
      ),
      centerTitle: true,
    );
  }
}
