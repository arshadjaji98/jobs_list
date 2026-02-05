import 'package:flutter/material.dart';

class FavoriteModel with ChangeNotifier {
  final String id, productId;

  FavoriteModel({required this.id, required this.productId});
}
