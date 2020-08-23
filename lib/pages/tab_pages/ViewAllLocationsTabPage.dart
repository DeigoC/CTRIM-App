import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/locationCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ViewAllLocationsPage {
  BuildContext _context;
  final ScrollController _controller;

  void setContext(BuildContext context) => _context = context;

  ViewAllLocationsPage(this._context,this._controller);

  Widget buildBody() {
    List<Location> allLocations = BlocProvider.of<TimelineBloc>(_context).selectableLocations;
    return CustomScrollView(
      controller: _controller,
      key: PageStorageKey('viewAllLocationsKey'),
      slivers: [
        LocationSearchBar(),
        BlocBuilder<TimelineBloc, TimelineState>(
          condition: (_, state) {
            if (state is TimelineDisplayLocationSearchResultsState) return true;
            return false;
          },
          builder: (_, state) {
            if (state is TimelineDisplayLocationSearchResultsState) {
              allLocations = state.locations;
            }
            return SliverList(delegate: SliverChildBuilderDelegate((_, index) {
              return LocationCard(location: allLocations[index]);
            }, childCount: allLocations.length));
          },
        ),
      ],
    );
  }
}

class LocationSearchBar extends StatefulWidget {
  @override
  _LocationSearchBarState createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
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
    return SliverAppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 8,
      //leading: _searchMode ? null: Icon(FontAwesome5Solid.church,color: Colors.white,),
      floating: true,
      actions: _searchMode ? null: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _searchMode = !_searchMode;
                    _fnSearch.requestFocus();
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
