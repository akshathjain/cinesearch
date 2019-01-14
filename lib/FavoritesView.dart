/*
Name: Akshath Jain
Date: 5/19/18
Purpose: favoritesview
*/

import 'package:flutter/material.dart';
import 'Utils.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesView extends StatefulWidget{
	@override
	createState() => new _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> with AutomaticKeepAliveClientMixin{
  int _page = 0;
  List<Map> _movieData;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _getFavorites();
  }
  
  @override
	Widget build(BuildContext context) {
		if(_movieData == null)
      return Center(child: CircularProgressIndicator(),);
  
    if(_movieData.isEmpty)
      return Center(child: Text("Movies in your Watch List will appear here."),);

    return _createGrid();
	}

  //return type future<null> because that's what the refresh indicator requires
  Future<Null> _getFavorites() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favIds = prefs.getStringList("favorites") ?? new List(); 

    setState((){
      _movieData = new List();
      for(int i = 0; i < favIds.length; i++){
        _movieData.add(json.decode(favIds[i]));
      }
    });

    return null;
  }

  Widget _createGrid(){    
    return RefreshIndicator(
      onRefresh: _getFavorites,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int i){
          if(i < (_movieData.length + 2) ~/ 3)
            return buildMovieRow(context, _movieData, i, 'favorites-row-' + i.toString());
        },
      ),
    );
  }
}
