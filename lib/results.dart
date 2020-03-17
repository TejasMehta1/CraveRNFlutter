import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:http/http.dart' as http;

class ResultsPage extends StatefulWidget {
  @override
  final List results;
  final String url;

  ResultsPage(this.results, this.url);

  _ResultsPageState createState() => _ResultsPageState(results, url);
}

class _ResultsPageState extends State<ResultsPage> {
  Position _currentPosition;
  final List results;
  final String url;
  String _value;
  String sortBy;
  String radius;
  String price;

  _ResultsPageState(this.results, this.url);

  @override
  void initState() {
    if (url.indexOf("price") != -1) {
      sortBy =
          url.substring(url.indexOf("&sort_by=") + 9, url.indexOf("&price="));
      radius =
          url.substring(url.indexOf("&radius=") + 8, url.indexOf("&sort_by="));
      price = url.substring(url.indexOf("&price=") + 7, url.length);
    } else {
      radius =
          url.substring(url.indexOf("&radius=") + 8, url.indexOf("&sort_by="));
      sortBy = url.substring(url.indexOf("&sort_by=") + 9, url.length);
      price = "null";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Results"),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xE5E5E5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 5, blurRadius: 2)
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                  ),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text("Distance:"),
                          DropdownButton<String>(
                            items: [
                              DropdownMenuItem(
                                value: "1609",
                                child: Text(
                                  "1 mi.",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "8047",
                                child: Text(
                                  "5 mi.",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "16093",
                                child: Text(
                                  "10 mi.",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "32187",
                                child: Text(
                                  "20 mi.",
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              _filterResults(value, "radius");
                            },
                            value: radius,
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text("Price:"),
                          DropdownButton<String>(
                            items: [
                              DropdownMenuItem(
                                value: "1",
                                child: Text(
                                  "\$",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "2",
                                child: Text(
                                  "\$\$",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "3",
                                child: Text(
                                  "\$\$\$",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "4",
                                child: Text(
                                  "\$\$\$\$",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "null",
                                child: Text(
                                  "Any",
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              _filterResults(value, "price");
                            },
                            value: price,
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text("Sort By:"),
                          DropdownButton<String>(
                            items: [
                              DropdownMenuItem(
                                value: "best_match",
                                child: Text(
                                  "Best Match",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "rating",
                                child: Text(
                                  "Rating",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "review_count",
                                child: Text(
                                  "Review Count",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "distance",
                                child: Text(
                                  "Distance",
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              _filterResults(value, "sortBy");
                            },
                            value: sortBy,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (results.length == 0)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      "No Results Found",
                      style: TextStyle(fontSize: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(50)),
                        child: BackButton(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            Expanded(
              child: SizedBox(
                height: 200.0,
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: results.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              results[index]["image_url"],
                              width: 175,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Flex(
                              direction: Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    MapsLauncher.launchCoordinates(
                                        results[index]['coordinates']['latitude'],
                                        results[index]['coordinates']
                                            ['longitude']);
                                  },
                                  child: Text(
                                    results[index]["name"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                RatingBarIndicator(
                                  rating: results[index]["rating"],
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  direction: Axis.horizontal,
                                ),
                                Text(results[index]["price"].toString()),
                                Text((results[index]["distance"] * 0.000621371)
                                        .toStringAsFixed(2) +
                                    " mi."),
                                Text(results[index]["location"]["display_address"]
                                    [0]),
                                Text(results[index]["display_phone"])
                              ],
                            ),
                          )
                        ],
                      ));
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _filterResults(String value, String type) {
    String newUrl = url;
    if (type == "price") {
      if (newUrl.indexOf("price") != -1) {
        newUrl = newUrl.substring(0,newUrl.indexOf("&price="));
      }
      newUrl += "&price=" + value;
    }
    else if(type == "sortBy"){
      if (newUrl.indexOf("price") != -1) {
        newUrl = newUrl.replaceRange(
            newUrl.indexOf("&sort_by=") + 9, newUrl.indexOf("&price="), value);
      }
      else{
       newUrl = newUrl.replaceRange(
            newUrl.indexOf("&sort_by=") + 9, newUrl.length, value);
      }
    }
    else if (type == "radius"){
      newUrl = newUrl.replaceRange(
          newUrl.indexOf("&radius=") + 8, newUrl.indexOf("&sort_by="), value);
    }
    http.get(newUrl, headers: {HttpHeaders.authorizationHeader:
    "Bearer caG4VhMLCDUGOCbqmyejaYFDwSTE0SkB64SVd76qVtosL2H2WE9MuWqY6vePhsjh-LLwtnO4XEMwbar9uJr2uXSURmRMwtJGRW3ubDB30gZ1h2LCkkKrdhnXUAFTXnYx"}).then((resp){
      Map _responses = jsonDecode(resp.body);
      List _businesses = _responses['businesses'];
      _goToNextPage(context, _businesses, newUrl);
    });
    }

  _goToNextPage(BuildContext context, List _businesses, String url) async {
    final result = await Navigator.push( context, MaterialPageRoute(builder: (context) => ResultsPage(
        _businesses,
        url
    )));
  }
}
