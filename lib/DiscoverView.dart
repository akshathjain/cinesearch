/*
Name: Akshath Jain
Date: 5/19/18
Purpose: discover class
*/

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Utils.dart';
import 'dart:async';
import 'dart:convert';
import 'APIKey.dart';
import 'ViewAllView.dart';


Future<List> fetchMovieList(String url) async {
  final response = await http.get(url);
  List results = json.decode(response.body)['results'];
  return results;
}

class DiscoverView extends StatefulWidget {
  @override
  createState() => new _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> with AutomaticKeepAliveClientMixin{
  List _nowPlayingData = new List();
  List _popularData = new List();
  List _topRatedData = new List();
  List _upcomingData = new List();
  
  @override
  bool get wantKeepAlive => true;

  //prevent memory leaks by ensuring that setstate only called when this is in view
  void setSafeState(VoidCallback fn()){
    if(mounted)
      setState(fn);
  }

  @override
  void initState() {
    super.initState();

    //now playing
    fetchMovieList("https://api.themoviedb.org/3/movie/now_playing?api_key=" + apiKey + "&language=en-US&page=1").then((List result){
      setSafeState((){
        _nowPlayingData = result;
      });
    });
    
    //popular
    fetchMovieList("https://api.themoviedb.org/3/movie/popular?api_key=" + apiKey + "&language=en-US&page=1").then((List result){
      setSafeState((){
        _popularData = result;
      });
    });

    //top rated
    fetchMovieList("https://api.themoviedb.org/3/movie/top_rated?api_key=" + apiKey + "&language=en-US&page=1").then((List result){
      setSafeState((){
        _topRatedData = result;
      });
    });

    //upcoming
    fetchMovieList("https://api.themoviedb.org/3/movie/upcoming?api_key=" + apiKey + "&language=en-US&page=1").then((List result){
      setSafeState((){
        _upcomingData = result;
      });
    });
  }

  @override
  Widget build(BuildContext context){

    return new ListView(
      children: <Widget>[
        //now playing
        _createDiscoverCategory(_nowPlayingData, "Now Playing", "https://api.themoviedb.org/3/movie/now_playing?api_key=" + apiKey + "&language=en-US&page="),
        Divider(),
        //popular
        _createDiscoverCategory(_popularData, "Popular", "https://api.themoviedb.org/3/movie/popular?api_key=" + apiKey + "&language=en-US&page="),
        Divider(),
        //top rated
        _createDiscoverCategory(_topRatedData, "Top Rated", "https://api.themoviedb.org/3/movie/top_rated?api_key=" + apiKey + "&language=en-US&page="),
        Divider(),
        //upcoming
        _createDiscoverCategory(_upcomingData, "Upcoming", "https://api.themoviedb.org/3/movie/upcoming?api_key=" + apiKey + "&language=en-US&page="),
      
        SizedBox(height: 16.0,),
      ],
    );
  }

  Widget _createDiscoverCategory(List data, String categoryTitle, String url){
    return new Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  categoryTitle,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FlatButton(
                  child: Text("VIEW ALL"),
                  textColor: Theme.of(context).accentColor,
                  onPressed: (){
                    Navigator.of(context).push(
                      new MaterialPageRoute(
                        builder: (context){
                          return new ViewAllView(categoryTitle, url);
                        }
                      )
                    );
                  },
                ),
              ],
            ),
          ),
          createHorizontalMovieList(data, categoryTitle, 200.0),          
        ],
      ),
    );
  }
}
