/*
Name: Akshath Jain
Date: 5/24/18
Purpose: search view class
*/

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Utils.dart';


class SearchView extends StatefulWidget{
  @override
  createState() => new _SearchView();
}

//get the movielist from search term
Future<Map> fetchMovies(String searchTerm, int page) async{
  final response = await http.get("https://api.themoviedb.org/3/search/movie?api_key=6866b6e81ff7327379e4b8d14ba50af1&language=en-US&query=" + searchTerm + "&page=" + page.toString() + "&include_adult=false");
  return json.decode(response.body);
}

class _SearchView extends State<SearchView>{
  List _movieData = new List();
  int _totalPages;
  int _page = 1;
  bool _noResults = false;
  String _searchTerm = "";
  TextEditingController _inputController = new TextEditingController(); //used to clear the search text
  FocusNode _inputFocus = new FocusNode(); //used to focus input when search cleared

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: new TextField(
          controller: _inputController,
          focusNode: _inputFocus,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search',
          ),
          style: TextStyle(
            fontSize: 20.0, 
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          onSubmitted: (String term){
            _page = 1;
            _searchTerm = term;
            _movieData = new List();
            _noResults = false;
            _getMovies(term);
          }
        ),
        actions: <Widget>[
          _showClearSearch(),
        ],
      ),
      body: _createBody(),
    );
  }

  void _getMovies(String term){
    if(term != null || term != ""){
      fetchMovies(term, _page++).then((Map map){
        setState((){
          _totalPages = map['total_pages'];
          List data = map['results'];
          
          if(data != null && data.isNotEmpty){
            if(_movieData != null)
              _movieData.addAll(data);
            else
              _movieData = data;
          }else{
            _noResults = true;
          }
        });
      });
    }    
  }

  Widget _createGrid(){
    if(_movieData == null)
      return new Container();
    else if(_movieData.isEmpty)
      return new Center(child: Text('No results'),);

    return new ListView.builder(
      itemBuilder: (BuildContext context, int i){
        if(i < (_movieData.length + 2) ~/ 3){
          return buildMovieRow(context, _movieData, i, 'search-row-' + i.toString());
        }else{
          if(_page <= _totalPages)
            _getMovies(_searchTerm);
        }
      },
    );
  }

  Widget _createBody(){
    if(_searchTerm == "")
      return Center(child: Text('Search for something'),);

    if(_noResults)
      return Center(child: Text('No movies found',));

    if(_movieData != null && _movieData.isNotEmpty)
      return _createGrid();
    else
      return Center(child: CircularProgressIndicator(),);    
  }

  Widget _showClearSearch(){
    if(_searchTerm != ""){
      return new IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){
          _searchTerm = "";
          _inputController.clear();
          FocusScope.of(context).requestFocus(_inputFocus);
        },
      );
    }
    return Container();
  }
}

