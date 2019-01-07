/*
Name: Akshath Jain
Date: 5/19/18
Purpose: learning flutter by making a movie search app
*/

import 'package:flutter/material.dart';

import 'DiscoverView.dart';
import 'FavoritesView.dart';
import 'SearchView.dart';

void main() {
  runApp(new CineSearch());
}

class CineSearch extends StatelessWidget{
	@override
	Widget build(BuildContext context){
    //MaterialPageRoute.debugEnableFadingRoutes = true;

    return new MaterialApp(
			title: 'Cine Search',
			debugShowCheckedModeBanner: false,
			theme: new ThemeData(
				primaryColor: Colors.grey[900],
				accentColor: Colors.greenAccent[700],
        primaryColorLight: Color(0xFF484848),
			),
      home: new TabbedHome(),
		);
	}
}


class TabbedHome extends StatefulWidget{
  @override
  _TabbedHomeState createState() => new _TabbedHomeState();
}

class _TabbedHomeState extends State<TabbedHome> with TickerProviderStateMixin{
  int _bottomNavBarIndex = 0;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(
      vsync: this,
      length: 2,  
    );
    _tabController.addListener((){
      setState(() {
        _bottomNavBarIndex = _tabController.index;      
      });
    });
  }

  @override
  Widget build(BuildContext context){
   return new DefaultTabController(
      length: 2,
      child: new Builder(builder: (context){
        return new Scaffold(
          appBar: new AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            title: Text('Cine Search'),
            actions: <Widget>[
              new IconButton(
                icon: Icon(Icons.search),
                onPressed: (){
                  Navigator.push(context, new MaterialPageRoute(
                    builder: (context) => new SearchView()
                  ));
                },
              ),
            ],
          ),
          body: new TabBarView(
            controller: _tabController,
            children: <Widget>[
              new DiscoverView(),
              new FavoritesView(),
            ],
          ),
          bottomNavigationBar: new Theme(
            data: Theme.of(context).copyWith(
              //sets backgroudn color of bottom nav
              canvasColor: Theme.of(context).primaryColor,
              //sets inactive color of bottom nav
              textTheme: TextTheme(
                caption: TextStyle(color: Colors.grey[600]),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              fixedColor: Theme.of(context).accentColor,
              currentIndex: _bottomNavBarIndex,
              onTap: (index){
                _tabController.animateTo(index);
                setState((){_bottomNavBarIndex = index;});
              },
              items: [
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.explore),
                  title: Text("Discover"),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.favorite),
                  title: Text("Watch List"),
                ),
              ],
            ),
          ), 
        );
      }),
    );
  }
}
