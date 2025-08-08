import 'package:flutter_riverpod/flutter_riverpod.dart';

// Sous-titre global affiché sous le logo Dinor dans l'en-tête
final headerSubtitleProvider = StateProvider<String?>((ref) => null);

// Route courante pour gérer l'affichage du titre
final currentRouteProvider = StateProvider<String>((ref) => '/');


