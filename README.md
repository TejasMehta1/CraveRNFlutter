# CraveRN

CraveRN is a cross-platform mobile application designed to help users find where to satisfy
their cravings instantly. The application allows the user to either search
what they desire or take a short quiz to help them find exactly what they want.
The quiz is comprised of picking one out of four pictures for a few rounds. The
service then calls Yelp's Fusion 360 API and returns results matching the user's
preferences.

## Architecture

The application is designed using Flutter with some iOS and Android customization.

## Front End Pages

### Home:

<br />
The user has two options to search. They can either enter input into the search box or they can complete the quiz
by clicking one of the four pictures until the quiz is over.
![Home Page](https://lh3.googleusercontent.com/hw13bgDlmcbGtdHLflwYOIGe54Yc5P9mUXIYX6xuJVOWirlrYKaYPIPHGs-YOGVD_DnpJL2NA1jsxgv-QEE6kOh3ETXZL3e1vbFjkiJusatgOkeGDbVIWAsURW2novWgOq-I-i7udGmZF_RiWYZNIbjeUXmtE8jSSSsaVFXkoTZc4reDSn2iP5ZljpC-rXGxxgLbG5J1bRuFUBzwgdaaE50wDYuNmwJeQTsq7nA-OnwWG9S_ygtKC4kgiRwrJJ-Ed_EjT2ayxYdjOeGNhEXUrJ9DpBTj1g042OySAt3aIDwSHeJssZyV2D3_zSQBqTApegWU3bO4eFhTlu0wGCSvihyhFJ8Bt-AfZk1p6L1UQj5VNEAUoiFJRrEiuNp3tvJsWNtAGxTjvhPPXUAOntfyFSOds8c2_L2TQYoL9ycLKGVTkRQlF96JZuzF_5HHMuAE7PZ-igPwtpOQfxeuiVj9oUH694_pFPJN-aPoPz5uxgUvA_LDvAlzQ8ObDh6IL24RmyX0HOKuFmx5fZZ1ADnQSIR4f8aBtuxDJjn5cFRm5OudHo9KUKlOFBKb3e3gBSX-FdA_LlUy_ho3RzX__cF0OnUJZpVjfIk8_fK0GTOauILhMVIpODCLy8jVM4fpYPCfC7ROJ1UQl-N9F57nK0BT6qOlwf0is2mS3iR64SSD-nF9N0mIew2-TK4l=w3584-h2080-no)

### Results:
The user is displayed a scrollable list of restaurant results. There are three filters that can be modified to show different results on the top labeled distance, price, and sort by.

![Results](https://lh3.googleusercontent.com/cb6ATPzO4epBrkAGVF6JGrcJ6mN7DE6eYovXdEIHs5Gc80pwmQNQH8Uecu6lY7UZ1BSOPHhVU_tHkxgCMeTPGnofYOTLsckoMm7KJFiNBkG9Znj2gYhOOl0_SgyiA_GSXhXQKz_YUt-JEXJAVPTQRUlXHKqDlKG_ivBuqdNzJcsBCyPptSNJD3hcS3njtukeyuna4xZzNpGagEnHwCMivo7msUtIQoMTZnbXZvJKaeCnkFZGqZxcvhXf-KJ7P8ekdtbn0szkmp2WDBnjBa1SdEd0izoXshRPlj-C2e0OPqVmjgEr34Vgqm_cwbUhP2ebwv_xEEG3cMP8h1vlik5Px_AYT5uNmJ1ZNiFRtaQILu0iuyBvqvJemTQupqiP0bPGXVuJECxk4afRwi2yqVmRHin5lEk1FnMVEbplYXr7mP3sz0RwB3u3-xRFJh7SnXSHmyvcRFkBL3qoXLlfK6xBOJYfeFepKjxwisI9fStfbQGcKGtWOpPrvKQ1LYeCUrP4VaBEsMtAzI2zVtRI25BF-LGoSp9OG-YTLPHChRXuwRq84S7kh7DTZxfel4xVBr1k-8LMwKliYOsYx0C2dHEVAsnxzr5LMBig6nEmi5Zk8k_nLQ3dCVisEQd0UnrO7U4Oa5ohfLhII02Yhh4ePtvEQns5YgJX3E5RBnyIywiLU3il38lFbmPgrzGY=w3584-h2080-no)

### /results
The results endpoint is called by home.html after the user either enters a text query or
completes the four picture quiz. The endpoint expects the following parameters:
* typeOfMeal
* specificMeal
* restaurantType
* dietaryRestriction
* latitude
* longitude
* city
* state
* price
* distance
* sort_by

The typeOfMeal, restaurantType, dietaryRestriction, price, and distance can have a "null" value.

The endpoint takes these queries, processes them in a way that the Yelp Fusion API can understand, and returns the output
from the api to the results.html document. I pass in the open_now parameter to be true so it only results in restaurants currently
open.
```
{
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
}
```