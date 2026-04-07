import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tume_ride_passenger/services/api_service.dart';
import 'package:tume_ride_passenger/config/api_constants.dart';
import 'package:tume_ride_passenger/widgets/custom_button.dart';
import 'package:tume_ride_passenger/widgets/custom_text_field.dart';
import 'package:tume_ride_passenger/utils/snackbar.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';
import 'package:geocoding/geocoding.dart';

class AddEditAddressScreen extends StatefulWidget {
  final String? type;
  final int? addressId;
  final String? name;
  final String? address;
  final double? lat;
  final double? lng;

  const AddEditAddressScreen({
    super.key,
    this.type,
    this.addressId,
    this.name,
    this.address,
    this.lat,
    this.lng,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  late GoogleMapController _mapController;
  LatLng _selectedLocation = const LatLng(-1.2921, 36.8219);
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.name != null) {
      _nameController.text = widget.name!;
    }
    if (widget.address != null) {
      _addressController.text = widget.address!;
    }
    if (widget.lat != null && widget.lng != null) {
      _selectedLocation = LatLng(widget.lat!, widget.lng!);
    }
  }

  Future<void> _searchAddress() async {
    if (_addressController.text.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      List<Location> locations = await locationFromAddress(_addressController.text);
      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _selectedLocation = LatLng(location.latitude, location.longitude);
        });
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _selectedLocation, zoom: 15),
          ),
        );
      }
    } catch (e) {
      showSnackBar(context, message: 'Address not found', isError: true);
    }

    setState(() => _isSearching = false);
  }

  Future<void> _saveAddress() async {
    if (_nameController.text.trim().isEmpty) {
      showSnackBar(context, message: 'Please enter a name for this address', isError: true);
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      showSnackBar(context, message: 'Please enter an address', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final api = ApiService();
    Map<String, dynamic> response;

    if (widget.addressId != null) {
      // Update existing address
      response = await api.post(ApiConstants.profile, data: {
        'action': 'update-address',
        'address_id': widget.addressId,
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'lat': _selectedLocation.latitude,
        'lng': _selectedLocation.longitude,
      });
    } else if (widget.type != null && (widget.type == 'home' || widget.type == 'work')) {
      // Update home/work address
      response = await api.post(ApiConstants.profile, data: {
        'action': ApiConstants.addresses,
        widget.type: _addressController.text.trim(),
      });
    } else {
      // Add new custom address
      response = await api.post(ApiConstants.profile, data: {
        'action': ApiConstants.addAddress,
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'lat': _selectedLocation.latitude,
        'lng': _selectedLocation.longitude,
      });
    }

    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      showSnackBar(context, message: 'Address saved successfully');
      Navigator.pop(context, true);
    } else {
      showSnackBar(
        context,
        message: response['message'] ?? 'Failed to save address',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.addressId != null ? 'Edit Address' : 'Add Address'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (latLng) {
              setState(() {
                _selectedLocation = latLng;
              });
              _getAddressFromLatLng(latLng);
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLocation,
                infoWindow: const InfoWindow(title: 'Selected Location'),
              ),
            },
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _addressController,
                      hint: 'Search address',
                      prefixIcon: Icons.search,
                      onSubmitted: (_) => _searchAddress(),
                    ),
                  ),
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchAddress,
                    ),
                ],
              ),
            ),
          ),

          // Bottom Form
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.3,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      if (widget.type == null && widget.addressId == null)
                        CustomTextField(
                          controller: _nameController,
                          label: 'Address Name',
                          hint: 'e.g., Home, Work, Gym',
                          prefixIcon: Icons.label,
                        ),
                      const SizedBox(height: 16),

                      Text(
                        _addressController.text.isNotEmpty
                            ? _addressController.text
                            : 'Selected location on map',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                            'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 24),

                      CustomButton(
                        text: 'Save Address',
                        onPressed: _saveAddress,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _addressController.text = [
            place.name,
            place.thoroughfare,
            place.subThoroughfare,
            place.locality,
          ].where((s) => s != null && s.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      // Ignore
    }
  }
}
