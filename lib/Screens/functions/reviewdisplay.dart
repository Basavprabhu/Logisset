import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewWidget extends StatelessWidget {
  final String assetName;

  ReviewWidget({required this.assetName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchReviews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error fetching reviews');
        } else if (snapshot.hasData) {
          List<Map<String, dynamic>> reviews = snapshot.data!;
          if (reviews.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18, top: 18),
              child: Text(
                'No reviews available',
                style: TextStyle(fontSize: 14),
              ),
            );
          }

          double averageRating = calculateAverageRating(reviews);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18, top: 18),
                child: Text(
                  'Average Rating: ${averageRating.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 6),
              RatingBar.builder(
                initialRating: averageRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 20,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {},
              ),
            ],
          );
        } else {
          return Text('No reviews available');
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('reviews')
        .where('assetName', isEqualTo: assetName)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    double totalRating = 0;
    int totalReviews = 0;

    for (var review in reviews) {
      if (review.containsKey('rating')) {
        totalRating += review['rating'];
        totalReviews++;
      }
    }

    if (totalReviews > 0) {
      return totalRating / totalReviews;
    } else {
      return 0;
    }
  }
}
