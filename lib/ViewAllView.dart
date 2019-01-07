/*
Name: Akshath Jain
Date: 6/2/18
Purpose: View all view
*/

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Utils.dart';
import 'dart:async';
import 'dart:convert';

class ViewAllView extends StatefulWidget{
  String _url;
  String _pageTitle;

  ViewAllView(String pageTitle, String url){
    this._url = url;
    this._pageTitle = pageTitle;
  }

  @override
  createState() => new _ViewAllViewState(_pageTitle, _url);
}

class _ViewAllViewState extends State<ViewAllView>{
  String _pageTitle;
  String _url;
  int _page = 1;
  List _movieData = new List();

  _ViewAllViewState(String pageTitle, String url){
    this._pageTitle = pageTitle;
    this._url = url;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
      ),
      body: _createBody(),
    );
  }

  Widget _createBody(){
    if(_movieData.length == 0){
      Future<List> nextPage = fetchMovieList(_url, _page++);
      nextPage.then(
        (List newData){
          setState((){
            _movieData.addAll(newData);
          });
        }
      );

      //loader indicator while first page loads
      return new Center(
        child: CircularProgressIndicator(),
      );
    }else{
      return _createGrid();
    }
  }

  Widget _createGrid(){
    return new ListView.builder(
      itemBuilder: (BuildContext context, int i){
        if(i < (_movieData.length + 2) ~/ 3){
          return buildMovieRow(context, _movieData, i, "viewallview-" + i.toString());
        }else{
          Future<List> nextPage = fetchMovieList(_url, _page++);
          nextPage.then((List newData){       
            setState(() {   
              _movieData.addAll(newData);
            });
          });
        }
      },
    );
  }
}

Future<List> fetchMovieList(String url, int page) async {
  final response = await http.get(url + page.toString());
  List results = json.decode(response.body)['results'];
  return results;
}