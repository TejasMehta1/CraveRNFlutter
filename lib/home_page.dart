import 'dart:convert';
import 'dart:io';

import 'package:crave_rn/results.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Position> _futurePosition;
  Position _currentPosition;
  List _currentImageURLS = ['assets/dessert.jpg','assets/appetizer.jpg','assets/mainDish.jpg','assets/drinks.jpg'];
  List _choices = [];
  List _currentImageLabels = ['dessert','appetizer','mainDish','drinks'];
  Map _imageOrder = {
    "round1" : [ "dessert", "appetizer", "mainDish", "drinks" ],
    "round2" : {
      "appetizer" : [ "chips", "dumplings", "tapas", "friedSnacks" ],
      "dessert" : [ "iceCream", "cookies", "cake", "doughnut" ],
      "drinks" : [ "alcohol", "boba", "juice", "coffee" ],
      "mainDish" : [ "italian", "indian", "asian", "mexican" ]
    },
    "round3" : [ "1", "2", "3", "4" ],
    "round4" : [ "foodTruck", "fastFood", "buffets", "anything" ],
    "round5" : [ "healthy", "glutenFree", "vegan", "none" ],
    "round6" : [ "1mi", "5mi", "10mi", "20mi" ]
  };
  Map _categories = {
    "foodTruck": "foodtrucks",
    "fastFood": "hotdogs",
    "buffets": "buffets",
    "anything": "null",
    "healthy": "healthmarkets",
    "glutenFree": "gluten_free",
    "vegan": "vegan",
    "none": "null",
    "null": "null"
  };
  int _roundCounter = 2;
  Position p;
  final myController = TextEditingController();

  @override
  void initState() {
    _getCurrentLocation();
//    _loadImagesFirst(-1);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, 300),
            child: Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 5, blurRadius: 2)
                  ],
                  image: DecorationImage(
                      image: AssetImage("assets/mainBackground.jpg"),
                      fit: BoxFit.cover)),
              width: MediaQuery.of(context).size.width,
              height: 800,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 80, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: RichText( text: new TextSpan(text: 'Crave ', style: GoogleFonts.handlee(
                            textStyle: TextStyle(
                                fontSize: 60,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)), children:
                        <TextSpan>[
                          new TextSpan(text: 'RN', style: new TextStyle(fontStyle: FontStyle.italic)),
                        ], ), ),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * .8,
                          decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.only(
                                  topLeft: Radius.circular(40.0),
                                  topRight: Radius.circular(40.0),
                                  bottomLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(40))),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 11, // 20%
                                child: Center(
                                  child: Text(
                                    "I'm Craving: ",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 17,
                                child: TextFormField(
                                  onEditingComplete: () {
                                    _searchTermYelpGetResults(myController.text);
                                  },
                                    controller: myController,
                                    decoration: new InputDecoration.collapsed(
                                        hintText: 'Tacos, Pizza, etc')),
                              ),
                              Expanded(
                                flex: 6, // 20%
                                child: RaisedButton(
                                    child: Text(
                                      "RN",
                                      style: GoogleFonts.handlee(
                                          textStyle: TextStyle(
                                        color: Colors.white,
                                      )),
                                    ),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0),
                                    ),
                                    color: Colors.blue,
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      _searchTermYelpGetResults(myController.text);
                                    }),
                              ),
                              Expanded(
                                flex: 1, // 20%
                                child: Container(),
                              )
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/mainBackground.jpg"),
                    fit: BoxFit.cover)),
            child: GridView.count(
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this produces 2 rows.
              crossAxisCount: 2,
              // Generate 100 widgets that display their index in the List.
              children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 30.0,
                              spreadRadius: 5.0,
                              offset: Offset(
                                0.0,
                                0.0,
                              ),
                            ),
                          ]
                      ),
                      child: Material(
                        elevation: 4.0,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                        color: Colors.transparent,
                        child: Ink.image(
                          image: new AssetImage(_currentImageURLS[0]),
                          fit: BoxFit.cover,
                          width: 160.0,
                          height: 120.0,
                          child: InkWell(
                            onTap: () => _logChoice(0),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 30.0,
                              spreadRadius: 5.0,
                              offset: Offset(
                                0.0,
                                0.0,
                              ),
                            ),
                          ]
                      ),
                      child: Material(
                        elevation: 4.0,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                        color: Colors.transparent,
                        child: Ink.image(
                          image: new AssetImage(_currentImageURLS[1]),
                          fit: BoxFit.cover,
                          width: 160.0,
                          height: 120.0,
                          child: InkWell(
                            onTap: () => _logChoice(1),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 30.0,
                              spreadRadius: 5.0,
                              offset: Offset(
                                0.0,
                                0.0,
                              ),
                            ),
                          ]
                      ),
                      child: Material(
                        elevation: 4.0,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                        color: Colors.transparent,
                        child: Ink.image(
                          image: new AssetImage(_currentImageURLS[2]),
                          fit: BoxFit.cover,
                          width: 160.0,
                          height: 120.0,
                          child: InkWell(
                            onTap: () => _logChoice(2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 30.0,
                              spreadRadius: 5.0,
                              offset: Offset(
                                0.0,
                                0.0,
                              ),
                            ),
                          ]
                      ),
                      child: Material(
                        elevation: 4.0,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                        color: Colors.transparent,
                        child: Ink.image(
                          image: new AssetImage(_currentImageURLS[3]),
                          fit: BoxFit.cover,
                          width: 160.0,
                          height: 120.0,
                          child: InkWell(
                            onTap: () => _logChoice(3),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          )),
    );
  }

  _searchTermYelpGetResults(String _searchTerm){
    _futurePosition.then((Position position) {
      _currentPosition = position;
      String url = "https://api.yelp.com/v3/businesses/search?";
      url = url
          + "latitude=" + position.latitude.toString()
          + "&longitude=" + position.longitude.toString()
          + "&term=" + _searchTerm
          + "&open_now=true"
          + "&radius=16093"
          + "&sort_by=best_match";
      print(url);
      http.get(url, headers: {HttpHeaders.authorizationHeader:
      "Bearer YELP_API_KEY"}).then((resp){
        Map _responses = jsonDecode(resp.body);
        List _businesses = _responses['businesses'];
        _goToNextPage(context, _businesses, url);
      });
    }).catchError((e) {
      print(e);
    });
  }

  _logChoice(int imageLoc) {
    if(_roundCounter <= 6) {
      String lastChoice = _currentImageLabels[imageLoc];
      _choices.add(lastChoice);
      _loadImages(lastChoice);
    }
    else {
      String _mainFood = _choices[1];
      String _price = _choices[2];
      String _restaurantType = _choices[3];
      String _dietaryRestriction = _choices[4];
      String _commaCategories = _categories[_restaurantType] + "," + _categories[_dietaryRestriction];
      String _distance = _currentImageLabels[imageLoc];
      String _radius = _distance.substring(0, _distance.indexOf("mi"));
      double _radiusInMeters = double.parse(_radius)*1609.34;
      _radius = _radiusInMeters.toStringAsFixed(0);
      String _sortBy = "best_match";
      _getYelpResults(_mainFood, _price, _commaCategories, _radius, _sortBy);
    }
  }

  _getYelpResults(String _mainFood, String _price, String _commaCategories, String _radius, String _sortBy){
      _futurePosition.then((Position position) {
        _currentPosition = position;
        String url = "https://api.yelp.com/v3/businesses/search?";
        url = url
            + "latitude=" + position.latitude.toString()
            + "&longitude=" + position.longitude.toString()
            + "&term=" + _mainFood
            + "&open_now=true"
            + "&categories" + _commaCategories
            + "&radius=" + _radius
            + "&sort_by=" + _sortBy
            + "&price=" + _price;
        print(url);
        http.get(url, headers: {HttpHeaders.authorizationHeader:
        "Bearer YELP_API_KEY"}).then((resp){
           Map _responses = jsonDecode(resp.body);
           List _businesses = _responses['businesses'];
           _goToNextPage(context, _businesses, url);
        });
      }).catchError((e) {
        print(e);
      });
  }


  _loadImages(String lastChoice) {
    String currentRound = "round" + _roundCounter.toString();
    _currentImageLabels.clear();
    List _currentImageURLSTemp = [];
    if (_roundCounter == 2) {
      for (int i = 0; i < 4; i++) {
        _currentImageLabels.insert(i, _imageOrder[currentRound][lastChoice][i]);
      }
    } else {
      for (int i = 0; i < 4; i++) {
        _currentImageLabels.insert(i, _imageOrder[currentRound][i]);
      }
    }
    for (int i = 0; i < 4; i++) {
      String urlTemplate = "assets/" + _currentImageLabels[i] + ".jpg";
      _currentImageURLSTemp.insert(i, urlTemplate);
    }
    setState(() {
      _currentImageURLS = _currentImageURLSTemp;
    });
    _roundCounter++;
  }

  _loadImagesFirst(int imageLoc) {
//    databaseReference.once().then((DataSnapshot snapshot) {
//      _imageOrder = snapshot.value;
//      print(_imageOrder);
      _loadImages(null);
//    });
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    _futurePosition = geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }


  _goToNextPage(BuildContext context, List _businesses, String url) async {
    final result = await Navigator.push( context, MaterialPageRoute(builder: (context) => ResultsPage(
        _businesses,
        url
    )));
    setState(() {
      _currentImageURLS = ['assets/dessert.jpg','assets/appetizer.jpg','assets/mainDish.jpg','assets/drinks.jpg'];
      _choices = [];
      _currentImageLabels = ['dessert','appetizer','mainDish','drinks'];
      _roundCounter = 2;
      myController.clear();
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }
}

