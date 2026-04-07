import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';
import 'package:tume_ride_passenger/services/geocoding_service.dart';

class SearchLocationScreen extends StatefulWidget {
  final String type;
  final Function(String, double, double)? onLocationSelected;

  const SearchLocationScreen({
    super.key,
    required this.type,
    this.onLocationSelected,
  });

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _fallbackLocations = [
    {'name': '📍 Current Location', 'address': 'Get your current GPS location', 'lat': 0, 'lng': 0, 'isCurrent': true},
    {'name': 'Nairobi CBD', 'address': 'Kenyatta Avenue, Nairobi', 'lat': -1.2864, 'lng': 36.8172},
    {'name': 'Westlands', 'address': 'Westlands Road, Nairobi', 'lat': -1.2675, 'lng': 36.8035},
    {'name': 'Kilimani', 'address': 'Argwings Kodhek Road, Nairobi', 'lat': -1.2931, 'lng': 36.7880},
    {'name': 'Jomo Kenyatta Airport', 'address': 'Airport North Road, Nairobi', 'lat': -1.3192, 'lng': 36.9278},
  ];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Start with fallback locations
    setState(() {
      _locations = List.from(_fallbackLocations);
    });

    // Try to get current location
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          if (mounted) {
            setState(() {
              _locations[0] = {
                'name': '📍 Current Location',
                'address': 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
                'lat': position.latitude,
                'lng': position.longitude,
                'isCurrent': true,
              };
            });
          }

          // Try to get address (don't wait for it)
          GeocodingService.reverseGeocode(
            position.latitude,
            position.longitude,
          ).then((location) {
            if (mounted && location != null) {
              setState(() {
                _locations[0] = {
                  'name': '📍 Current Location',
                  'address': location['address'],
                  'lat': position.latitude,
                  'lng': position.longitude,
                  'isCurrent': true,
                };
              });
            }
          }).catchError((e) {
            print('Address lookup failed: $e');
          });
        }
      }
    } catch (e) {
      print('Location error: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _locations = List.from(_fallbackLocations);
        _isSearching = false;
      });
      _loadLocations();
      return;
    }

    setState(() => _isSearching = true);

    try {
      List<Map<String, dynamic>> results = await GeocodingService.searchAddress(query);

      if (mounted) {
        if (results.isNotEmpty) {
          setState(() {
            _locations = results;
            _isSearching = false;
          });
        } else {
          setState(() {
            _locations = [];
            _isSearching = false;
          });
        }
      }

    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _locations = [];
          _isSearching = false;
        });
      }
    }
  }

  void _selectLocation(Map<String, dynamic> location) {
    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(
        location['address'],
        location['lat'],
        location['lng'],
      );
    } else {
      // If no callback, just pop with result
      Navigator.pop(context, {
        'address': location['address'],
        'lat': location['lat'],
        'lng': location['lng'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == 'pickup' ? 'Where are you?' : 'Where to?'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.greyLight)),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search for a location...',
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _searchLocation('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: _searchLocation,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _isSearching
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Searching...'),
                ],
              ),
            )
                : _locations.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: AppColors.grey),
                  SizedBox(height: 16),
                  Text('No locations found'),
                  SizedBox(height: 8),
                  Text('Try a different search term', style: TextStyle(fontSize: 12)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final loc = _locations[index];
                final isCurrent = loc['isCurrent'] == true;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.primaryLight.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greyLight),
                  ),
                  child: ListTile(
                    leading: Icon(
                      isCurrent ? Icons.my_location : Icons.location_on,
                      color: isCurrent ? AppColors.primary : AppColors.secondary,
                    ),
                    title: Text(
                      loc['name'],
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      loc['address'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectLocation(loc),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}