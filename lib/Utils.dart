/*
Name: Akshath Jain
Date: 5/27/18
Purpose: General class with grid view construction methods to prevent code repeats
*/

import 'package:flutter/material.dart';
import 'MovieView.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget buildMovieRow(BuildContext context, List movieData, int i, String heroTagStart){
  return new Container(
    height: 205.0,
    margin: EdgeInsets.only(top: (i == 0 ? 8.0 : 4.0)),
    child: Container( 
      padding: const EdgeInsets.only(left: 6.0, right: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(2.0),
              child: buildMovieCard(context, movieData[3*i], heroTagStart + movieData[3*i]['id'].toString())
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(2.0),
              child: (3*i+1 < movieData.length) ? buildMovieCard(context, movieData[3*i+1], heroTagStart + movieData[3*i+1]['id'].toString()) : Container(), //check to make sure the last one is in the list (if there are an odd number of entries)
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(2.0),
              child: (3*i+2 < movieData.length) ? buildMovieCard(context, movieData[3*i+2], heroTagStart + movieData[3*i+2]['id'].toString()) : Container(), //check to make sure the last one is in the list (if there are an odd number of entries)
            ),
          ),
        ],
      )  
    ), 
  );
}

Widget buildMovieCard(BuildContext context, Map data, String heroTag) {
  return new Card(
    child: new InkWell(
      onTap: () => createMovieView(context, data['id'], data['poster_path'], heroTag),
      child: new Container(
        child:new Column(
          children: <Widget>[
            new LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints){ 
                return new Hero(
                  tag: heroTag,
                  child: (data["poster_path"]) != null ? 
                    CachedNetworkImage(
                      imageUrl:  "http://image.tmdb.org/t/p/w500" + data["poster_path"],
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                      fadeInDuration: new Duration(milliseconds: 100),
                      fadeOutDuration: new Duration(milliseconds: 100),
                      height: 140.0,
                      width: constraints.maxWidth,
                    ) 
                    : imagePlaceHolder(140.0),
                );
              }
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: new Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ), 
    ),
  );
}

//create a page that shows more info about a movie when clicked
void createMovieView(BuildContext context, int id, String posterPath, String heroTag) {
  Navigator.of(context).push(    
    new MaterialPageRoute(
      builder: (context){
        if(posterPath != null)
          return new MovieView.withSharedElements(id, posterPath, heroTag);
        else
          return new MovieView(id, heroTag);
      }
    )
  );
}

Widget imagePlaceHolder(double height){
  return new Container(
    height: height,
    color: Colors.blueGrey,
    child:new Center(
      child: Icon(
        Icons.movie,
        color: Colors.white,
      ),
    )
  );
}

Widget createHorizontalMovieList(List data, String heroTagStart, double movieHeight){
  if(movieHeight == null){
    movieHeight = 155.0;
  }

  if(data == null || data.isEmpty)
    return new Center(child: CircularProgressIndicator());

  return new Container( 
    height: movieHeight,
    child: new ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int i){
        if(data != null && i < data.length){
          var margin = const EdgeInsets.all(0.0);
          
          if(i == 0)
            margin = const EdgeInsets.only(left: 9.0);
          else if(i == data.length - 1)
            margin = const EdgeInsets.only(right: 9.0);

          return new Container(
            margin: margin,
            width: 120.0,
            child: Card(
              child: InkWell(
                onTap: () => createMovieView(context, data[i]["id"], data[i]["poster_path"], 'discoverview-' + heroTagStart + data[i]['id'].toString()),
                child: Column(
                  children: <Widget>[
                    new Container(
                      height: movieHeight - 60.0,
                      width: 120.0,
                      child: Hero(
                        tag: 'discoverview-' + heroTagStart + data[i]['id'].toString(),
                        child: data[i]["poster_path"] != null ? CachedNetworkImage(
                            imageUrl: "http://image.tmdb.org/t/p/w500" + data[i]["poster_path"],
                            fit: BoxFit.fitWidth,
                          ) : imagePlaceHolder(movieHeight - 60.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            data[i]['original_title'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
    )
  );
}