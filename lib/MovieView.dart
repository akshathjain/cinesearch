/*
Name: Akshath Jain
Date: 5/23/18
Purpose: view to display a movie fullscreen
*/

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'Utils.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'APIKey.dart';

class MovieView extends StatefulWidget {
  int _id;
  String _posterPath;
  String _title;
  String _heroTag;

  MovieView(int movieId, String heroTag) {
    this._id = movieId;
    this._heroTag = heroTag;
  }

  MovieView.withSharedElements(int movieId, String posterPath, String heroTag){
    this._id = movieId;
    this._posterPath = posterPath;
    this._heroTag = heroTag;
  }

  @override
  createState() => _posterPath == "" ? new _MovieViewState(_id, _heroTag) : new _MovieViewState.withSharedElements(_id, _posterPath, _heroTag);
}

class _MovieViewState extends State<MovieView> {
  int _id;
  String _heroTag;

  String _title = "";
  String _language = "";
  String _backdropPath = "";
  String _overview = "";
  String _posterPath = "";
  String _mpaaRating = "N/A";
  DateTime _releaseDate = new DateTime(0);
  bool _favorite = false;
  int _runtime = 0;
  String _imdbId = "";
  String _tmdbRating = "-";
  String _imdbRating = "-";
  String _rottenTomatoesRating = "-";
  List _videoList = new List();
  List _actorList = new List();
  String _collectionName = "";
  List _collectionList = new List();
  List _similarMovies = new List();

  //only show the appbar title once the flexible spacebar has fully collapsed
  ScrollController _appbarScrollController;
  bool _appbarTitleVisible = false;
  double _flexibleSpaceBarHeight = 270.0;

  _MovieViewState(int id, String heroTag) {
    this._id = id;
    this._heroTag = heroTag;
  }

  _MovieViewState.withSharedElements(int id, String posterPath, String heroTag){
    this._id = id;
    this._posterPath = posterPath;
    this._heroTag = heroTag;
  }

  @override
  void initState() {
    super.initState();

    fetchMovieInformation(_id).then((Map map) {
      setSafeState(() {
        _title = map['title'] == null ? "" : map['title'];
        _backdropPath = map['backdrop_path'] == null ? "" : map['backdrop_path'];
        _overview = map['overview'] == null ? "" : map['overview'];
        _posterPath = map['poster_path'] == null ? "" : map['poster_path'];
        _runtime = map['runtime'];
        _releaseDate = DateTime.parse(map['release_date']);
        _tmdbRating = map['vote_average'].toString();
        _imdbId = map["imdb_id"];
        map["spoken_languages"].forEach((m){
          if(_language != "")
            _language += ", " + m['name'];
          else
            _language += m['name'];
        });
      });

      fetchMovieRating(map["imdb_id"]).then((double rating){
        setSafeState(() {
          _imdbRating = rating.toString();
        });
      });

      //get collection info
      if(map['belongs_to_collection'] != null){
        fetchCollection(map['belongs_to_collection']['id']).then((List result){
          setSafeState((){
            _collectionName = map['belongs_to_collection']['name'];
            _collectionList = result;
          });
        });
      }
    });

    //get the mpaa rating
    fetchMPAARating(_id).then((List list){
      String temp = "N/A";
      for(int i = 0; i < list.length; i++){
        if(list[i]['iso_3166_1'] == "US"){
          List dates = list[i]['release_dates'];
          for(int j = 0; j < dates.length; j++){
            if(dates[j]['certification'] != ""){
              temp = dates[j]['certification'];
            }
          }
          break;
        }
      }

      setSafeState(() {
        _mpaaRating = temp;
      });
    });

    //get videos
    fetchVideos(_id).then((List list){
      setSafeState((){
        _videoList = list;
      });
    });

    //get actors
    fetchActors(_id).then((List list){
      setSafeState((){
        _actorList = list;
      });
    });

    //get similar movies
    fetchSimilarMovies(_id).then((List list){
      setSafeState((){
        _similarMovies = list;
      });
    });

    //init the scroll controller
    _appbarScrollController = new ScrollController();
    _appbarScrollController.addListener((){
      double appearOffset = 55.0;
      //check if we need to change anything before updating the layout
      if(_appbarTitleVisible && _appbarScrollController.offset <= _flexibleSpaceBarHeight - appearOffset || !_appbarTitleVisible && _appbarScrollController.offset > _flexibleSpaceBarHeight - appearOffset){
        setSafeState((){
          _appbarTitleVisible = _appbarScrollController.offset > _flexibleSpaceBarHeight - appearOffset;
        });
      }
    });

    _determineFavorite();
  }

  //prevent memory leaks by ensuring that setstate only called when this is in view
  void setSafeState(VoidCallback fn()){
    if(mounted)
      setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new CustomScrollView(
        controller: _appbarScrollController,
        slivers: _createBody(),
      ),
    );
  }

  Widget _createAppBarBackground(){
    return new Stack(
      alignment: AlignmentDirectional.bottomStart,
      children:<Widget>[
        _backdropPath != null && _backdropPath != "" ? new CachedNetworkImage(
          imageUrl: "http://image.tmdb.org/t/p/w1280" + _backdropPath,
          height: 270.0,
          fit: BoxFit.cover,
          fadeInDuration: new Duration(milliseconds: 250),
          fadeOutDuration: new Duration(milliseconds: 100),
        ) : SizedBox(height: 270.0),
        new SizedBox(
          height: 150.0,
          child: Container(
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        new Container(
          height: 150.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            child: new Row(
              children: <Widget>[
                new Hero(
                  tag: _heroTag,
                  child: Container(
                    width: 100.0,
                    height: 120.0,
                    child: Card(
                      child: _posterPath != null && _posterPath != "" ? new CachedNetworkImage(
                        imageUrl: "http://image.tmdb.org/t/p/w500" + _posterPath,
                        height: 120.0,
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ) : imagePlaceHolder(120.0)
                    )
                  ),
                ),
                SizedBox(width: 16.0,),
                new Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text( //title
                        _title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0,),
                      new Row(
                        children: <Widget>[
                          new Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              border: new Border.all(width: 1.0, color: Colors.white70, style: BorderStyle.solid),
                              borderRadius: new BorderRadius.only(
                                topLeft: new Radius.circular(2.0),
                                topRight: new Radius.circular(2.0),
                                bottomLeft: new Radius.circular(2.0),
                                bottomRight: new Radius.circular(2.0),
                              ),
                            ),
                            child: new Text( //mpaa rating
                              _mpaaRating,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.white70,
                              ),
                            ) ,
                          ),
                          SizedBox(width: 6.0,),
                          _dotSeperator(),
                          SizedBox(width: 6.0,),
                          new Text(
                            _releaseDate.year.toString(),
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(width: 6.0,),
                          _dotSeperator(),
                          SizedBox(width: 6.0,),
                          new Text( //runtime
                            _format(_runtime),
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),                  
                ),
              ],
            ),
          )
        ),
      ]
    );
  }

  List<Widget> _createBody(){
    return <Widget>[
      new SliverAppBar(
        actions: <Widget>[
          new IconButton(
            icon: new Icon(_favorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _saveFavorites,         
          ),
        ],
        expandedHeight: _flexibleSpaceBarHeight,
        flexibleSpace: FlexibleSpaceBar(
          background: _createAppBarBackground(),
        ),
        pinned: true,
        title: AnimatedOpacity(
          opacity: _appbarTitleVisible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 100),
          child: Text(_title)
        ),
      ),
      new SliverList(
        delegate: new SliverChildListDelegate(<Widget>[
          new Container(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _ratingWidget("images/tmdbLogo.png", _tmdbRating),
                _ratingWidget("images/imdbLogo.png", _imdbRating),
                //_ratingWidget("images/rottentomatoesLogo.png", _rottenTomatoesRating),
              ],
            ),
          ),
          new Container(
            padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
            child: new Card(
              child: new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      'Overview',
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontFamily: "Roboto"),
                    ),
                    new SizedBox(height: 8.0),
                    new Text(
                      _overview,
                      style: new TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.0,
                        color: Colors.black54,
                        decoration: TextDecoration.none,
                        fontFamily: "Roboto"
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _videoList != null && _videoList.isNotEmpty ? new Container(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 16.0),
                    child: new Text(
                      "Videos",
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontFamily: "Roboto"
                      ),
                    )
                  ),
                  Container(
                    height: 155.0,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: new ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int i){
                        if(_videoList != null && i < _videoList.length){
                          var margin = const EdgeInsets.all(0.0);
                          
                          if(i == 0)
                            margin = const EdgeInsets.only(left: 9.0);
                          else if(i == _videoList.length - 1)
                            margin = const EdgeInsets.only(right: 9.0);

                          return new Container(
                            margin: margin,
                            width: 120.0,
                            child: Card(
                              child: InkWell(
                                onTap: () => _openYoutube("https://www.youtube.com/watch?v=" + _videoList[i]["key"]),
                                child: Column(
                                  children: <Widget>[
                                    Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        CachedNetworkImage(
                                          imageUrl: "https://img.youtube.com/vi/" + _videoList[i]["key"].toString() + "/1.jpg",
                                          fit: BoxFit.fitWidth,
                                        ),
                                        Icon(Icons.play_circle_filled, color: Colors.white,),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                                      child: Text(
                                        _videoList[i]['name'],
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 8.0,),
                ],
              ),
            ),
          ) : Container(),
          _actorList != null && _actorList.isNotEmpty ? new Container(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 16.0),
                    child: new Text(
                      "Cast",
                      textAlign: TextAlign.left,
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontFamily: "Roboto"
                      ),
                    )
                  ),
                  Container(
                    height: 178.0,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: new ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int i){
                        if(_actorList != null && i < _actorList.length){
                          var margin = const EdgeInsets.all(0.0);
                          
                          if(i == 0)
                            margin = const EdgeInsets.only(left: 9.0);
                          else if(i == _actorList.length - 1)
                            margin = const EdgeInsets.only(right: 9.0);

                          return new Container(
                            margin: margin,
                            width: 120.0,
                            child: Card(
                              child: InkWell(
                                child: Column(
                                  children: <Widget>[
                                    new Container(
                                      height: 100.0,
                                      width: 120.0,
                                      child: _actorList[i]["profile_path"] != null ? CachedNetworkImage(
                                        imageUrl: "http://image.tmdb.org/t/p/w185" + _actorList[i]["profile_path"],
                                        fit: BoxFit.fitWidth,
                                      ) : _actorPlaceHolder(100.0),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _actorList[i]['name'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 8.0,),
                                          Text(
                                            _actorList[i]['character'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 8.0,),
                ],
              ),
            ),
          ) : Container(),
          _collectionList != null && _collectionList.isNotEmpty ? new Container(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 16.0),
                    child: new Text(
                      _collectionName,
                      textAlign: TextAlign.left,
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontFamily: "Roboto"
                      ),
                    )
                  ),
                  createHorizontalMovieList(_collectionList, "collection", 155.0),
                  SizedBox(height: 16.0,),
                ],
              ),
            ),
          ) : Container(),
          _similarMovies != null && _similarMovies.isNotEmpty ? new Container(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 16.0),
                    child: new Text(
                      "Similar Movies",
                      textAlign: TextAlign.left,
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontFamily: "Roboto"
                      ),
                    )
                  ),
                  createHorizontalMovieList(_similarMovies, "similarMovies", 155.0),
                  SizedBox(height: 16.0,),
                ],
              ),
            ),
          ) : Container(),
          new Container(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 16.0),
                    child: new Text(
                      "Facts",
                      textAlign: TextAlign.left,
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontFamily: "Roboto"
                      ),
                    )
                  ),
                  Container(
                    height: 155.0,
                    margin: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                    child: Column(
                      children: <Widget>[
                        _createFact("Title", _title),
                        _createFact("Language", _language),
                        _createFact("Release Date", _getDate(_releaseDate)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    ];
  }

  Widget _ratingWidget(String imageAsset, String rating){
    return Column(
      children: <Widget>[
        new Container(
          height: 35.0,
          child: Center(
            child: new Image.asset(
              imageAsset,
              width: 32.0,
            )
          ),
        ),
        new SizedBox(height: 4.0,),
        new Text(rating),
      ],
    );
  }

  void _determineFavorite() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List favs = prefs.getStringList("favorites") ?? new List();
    bool isFav = false;
    for(int i = 0; i < favs.length; i++){
      if(json.decode(favs[i])["id"] == _id){
        isFav = true;
        break;
      }
    }
    
    setState(() {
      _favorite = isFav;
    });
  }

  void _saveFavorites() async{
    setState(() {
      _favorite = !_favorite;
    });
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList("favorites") ?? new List<String>(); //the ?? is a null check.. if left is null, then the right happens
    Map saveData = {
      "id": _id,
      "title": _title,
      "poster_path": _posterPath
    };

    if(!_favorite){ //its in the list and is not a favorite, remove it
      for(int i = 0; i < favs.length; i++){
        if(json.decode(favs[i])["id"] == _id){
          favs.removeAt(i);
          break;
        }
      }
    }else if(_favorite){ //its not in the list, and is a favorite, add it; if is favorite and in list, readd to ensure that everything is up to date
      for(int i = 0; i < favs.length; i++){
        if(json.decode(favs[i])["id"] == _id){
          favs.removeAt(i);
          break;
        }
      }
      favs.add(json.encode(saveData));
    }

    prefs.setStringList("favorites", favs);
  }

  String _format(int min){
    if(min != null)
      return (min ~/ 60).toString() + " hr " + (min - 60 * (min ~/ 60)).toString() + " min";
    else
      return "";
  }

  Widget _dotSeperator(){
    return Text(
      "•",
      style: TextStyle(
        fontSize: 14.0,
        color: Colors.white70,
      ),
    );
  }

  void _openYoutube(String url) async{
    if(await canLaunch(url))
      await launch(url);
  }
  
  Widget _actorPlaceHolder(double height){
    return new Container(
      height: height,
      color: Colors.blueGrey,
      child:new Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
        ),
      )
    );
  }

  Widget _createFact(String t, String d){
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(t, style: TextStyle(fontWeight: FontWeight.bold,),),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(d),
            )
          ],
        ),
        SizedBox(height: 12.0),
      ],
    );
  }

  String _getDate(DateTime dt){
    List months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[dt.month - 1] + " " + dt.day.toString() + ", " + dt.year.toString(); 
  }
}


Future<Map> fetchMovieInformation(int id) async {
  final response = await http.get("https://api.themoviedb.org/3/movie/" +
      id.toString() +
      "?api_key=" + apiKey + "&language=en-US");
  Map results = json.decode(response.body);
  return results;
}

Future<List> fetchMPAARating(int id) async {
  final response = await http.get("https://api.themoviedb.org/3/movie/" +
      id.toString() +
      "/release_dates?api_key=" + apiKey + "&language=en-US");
  Map results = json.decode(response.body);
  return results['results'];
}

Future<double> fetchMovieRating(String imdbId) async {
  if(imdbId != null){
    final response = await http.get("https://imdb.filmapi.com/v1/movie/" + imdbId);
    Map results = json.decode(response.body)['data'];
    if(results != null)
      return double.parse(json.decode(response.body)['data']['attributes']['rating']['score'].toString());
    else
      return null;
  }
  return null;
}

Future<List> fetchVideos(int id) async{
  final response = await http.get("https://api.themoviedb.org/3/movie/" + id.toString() + "/videos?api_key=" + apiKey + "&language=en-US");
  return json.decode(response.body)['results'];
}

Future<List> fetchActors(int id) async{
  final response = await http.get("https://api.themoviedb.org/3/movie/" + id.toString() + "/credits?api_key=" + apiKey + "");
  return json.decode(response.body)['cast'];
}

Future<List> fetchCollection(int collectionId) async{
  var response = await http.get("https://api.themoviedb.org/3/collection/" + collectionId.toString() + "?api_key=" + apiKey + "&language=en-US");
  List list =  json.decode(response.body)['parts'];
  //sort by date
  list.sort((a, b) => DateTime.parse(a['release_date']).compareTo(DateTime.parse(b['release_date'])));
  return list;
}

Future<List> fetchSimilarMovies(int id) async{
  final response = await http.get("https://api.themoviedb.org/3/movie/" + id.toString() + "/similar?api_key=" + apiKey + "&language=en-US&page=1");
  return json.decode(response.body)['results'];
}