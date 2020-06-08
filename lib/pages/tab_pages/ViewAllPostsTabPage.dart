import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllEventsPage{

  final BuildContext _context;

  ViewAllEventsPage(this._context);

  Widget buildAppBar(){
    return AppBar(
      title: Text('Insert Logo and search icon',),
    );
  }

  FloatingActionButton buildFAB(){
    return FloatingActionButton.extended(
      onPressed: (){
        BlocProvider.of<AppBloc>(_context).add(AppToAddPostPageEvent());
      },
      icon: Icon(Icons.add),
       label: Text('Event'),
      );
  }

  Widget buildBody(){
    return ListView(
      children: [
        buildCard1(),
        SizedBox(height:8),
        buildCard2(),
        SizedBox(height:8),
        buildCard3(),
        SizedBox(height:8),
        buildCard4(),
        SizedBox(height: 30,),
        ListTile(
          title: Text('Insert full test here'),
          onTap: (){
            BlocProvider.of<AppBloc>(_context).add(AppToViewPostPageEvent());
          },  
        )
      ],
    );
  }

 Card buildCard4() {
    return Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () => null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Youth Day out at London Bridge',
                    style: TextStyle(fontSize: 26, color: Colors.black),
                    children: [
                      TextSpan(text: '\nBy Diego C. 07 Jun 2020 YOUTH, CHURCH',
                      style: TextStyle(fontSize: 12))
                    ],
                  ),
                ),
                SizedBox(height: 8,),
                AspectRatio(
                  aspectRatio: 16/9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: 2,),
                              Expanded(
                                child: Container(
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2,),
                         Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 2,),
                              Expanded(
                                child: Container(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                         ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }

 Card buildCard3() {
    return Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () => null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Youth Day out at London Bridge',
                    style: TextStyle(fontSize: 26, color: Colors.black),
                    children: [
                      TextSpan(text: '\nBy Diego C. 07 Jun 2020 YOUTH, CHURCH',
                      style: TextStyle(fontSize: 12))
                    ],
                  ),
                ),
                SizedBox(height: 8,),
                AspectRatio(
                  aspectRatio: 16/9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(width: 3,),
                         Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 3,),
                              Expanded(
                                child: Container(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                         ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }

  Card buildCard2() {
    return Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () => null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Youth Day out at London Bridge',
                    style: TextStyle(fontSize: 26, color: Colors.black),
                    children: [
                      TextSpan(text: '\nBy Diego C. 07 Jun 2020 YOUTH, CHURCH',
                      style: TextStyle(fontSize: 12))
                    ],
                  ),
                ),
                SizedBox(height: 8,),
                Text(
'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus fringilla in ligula vel fringilla. Etiam interdum tortor eu lorem sagittis tristique eu sit amet justo. Phasellus iaculis tincidunt elit, eu dictum lorem gravida consequat'
                ,style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8,),
                AspectRatio(
                  aspectRatio: 16/9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(width: 3,),
                         Expanded(
                          child: Container(
                            color: Colors.blue,
                        ),
                         ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }

  Card buildCard1() {
    return Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () => null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Youth Day out at London Bridge',
                    style: TextStyle(fontSize: 26, color: Colors.black),
                    children: [
                      TextSpan(text: '\nBy Diego C. 07 Jun 2020 YOUTH, CHURCH',
                      style: TextStyle(fontSize: 12))
                    ],
                  ),
                ),
                SizedBox(height: 8,),
                Text(
'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus fringilla in ligula vel fringilla. Etiam interdum tortor eu lorem sagittis tristique eu sit amet justo. Phasellus iaculis tincidunt elit, eu dictum lorem gravida consequat'
                ,style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8,),
                AspectRatio(
                  aspectRatio: 16/9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.pinkAccent,
                    ),
                  )
                )
              ],
            ),
          ),
        ),
      );
  }

}