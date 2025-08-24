import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';
import '../services/api_service.dart';
import '../pages/login_page.dart';

class HomeProvider extends ChangeNotifier {
  // ----- UI state -----
  bool isLoading = false;

  // ----- Profile & session -----
  String? profileImagePath;
  String username = "";
  int accountId = 0;

  // ----- Location & weather -----
  LatLng? currentLatLng;
  String currentAddress = "";
  String temperature = "--°C";
  StreamSubscription<Position>? _positionStream;

  // ----- Tasks -----
  List<Todo> userTasks = [];

  /// Initialisation à déclencher depuis la page (initState)
  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    await Future.wait([
      _loadProfileImage(),
      _loadUsername(),
      _loadAccountIdAndTasks(),
    ]);

    await _startLocationUpdates();

    isLoading = false;
    notifyListeners();
  }

  // ===== Profile & Session =====
  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? "";
  }

  Future<void> _loadAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    accountId = prefs.getInt("account_id") ?? 0;
  }

  Future<void> _loadAccountIdAndTasks() async {
    final prefs = await SharedPreferences.getInstance();
    accountId = prefs.getInt("account_id") ?? 0;
    if (accountId != 0) {
      await loadTasks();
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    profileImagePath = prefs.getString("profile_image");
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("profile_image", image.path);
      profileImagePath = image.path;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("user_id");
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  // ===== Location & Weather =====
  Future<void> _startLocationUpdates() async {
    // Permissions
    if (!await Geolocator.isLocationServiceEnabled()) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    // Stream
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) async {
      currentLatLng = LatLng(position.latitude, position.longitude);

      // Adresse
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        currentAddress = "${p.street}, ${p.locality}, ${p.country}";
      }

      // Météo
      final url =
          "https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current_weather=true";
      try {
        final res = await http.get(Uri.parse(url));
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          temperature = "${data['current_weather']['temperature']}°C";
        }
      } catch (_) {
        // on garde la température précédente si erreur
      }

      notifyListeners();
    });
  }

  // ===== Tasks =====
  Future<void> loadTasks() async {
    try {
      userTasks = await ApiService.getTodos(accountId);
    } catch (e) {
      debugPrint("Erreur lors du chargement des tâches : $e");
      userTasks = [];
    }
    notifyListeners();
  }

  // ===== Lifecycle =====
  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
