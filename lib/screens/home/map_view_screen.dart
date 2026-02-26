import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/listings_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../listings/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  ListingModel? _selectedListing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createMarkers();
    });
  }

  void _createMarkers() {
    final listingsProvider = Provider.of<ListingsProvider>(context, listen: false);
    final listings = listingsProvider.filteredListings;

    setState(() {
      _markers = listings.map((listing) {
        return Marker(
          markerId: MarkerId(listing.id ?? listing.name),
          position: LatLng(listing.latitude, listing.longitude),
          infoWindow: InfoWindow(
            title: listing.name,
            snippet: listing.category,
            onTap: () {
              setState(() {
                _selectedListing = listing;
              });
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(listing.category),
          ),
          onTap: () {
            setState(() {
              _selectedListing = listing;
            });
          },
        );
      }).toSet();
    });
  }

  double _getMarkerColor(String category) {
    switch (category) {
      case 'Hospital':
        return BitmapDescriptor.hueRed;
      case 'Police Station':
        return BitmapDescriptor.hueBlue;
      case 'Restaurant':
      case 'Café':
        return BitmapDescriptor.hueOrange;
      case 'Park':
      case 'Tourist Attraction':
        return BitmapDescriptor.hueGreen;
      case 'Pharmacy':
        return BitmapDescriptor.hueRose;
      case 'Bank':
        return BitmapDescriptor.hueCyan;
      case 'School':
        return BitmapDescriptor.hueYellow;
      case 'Hotel':
        return BitmapDescriptor.hueMagenta;
      case 'Shopping Mall':
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Map View',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppTheme.accentGold),
            tooltip: 'Center on Kigali',
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  const LatLng(
                    AppConstants.kigaliCenterLat,
                    AppConstants.kigaliCenterLng,
                  ),
                  AppConstants.defaultZoom,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ListingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentGold,
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textGray,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          // Update markers when listings change
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _createMarkers();
          });

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                    AppConstants.kigaliCenterLat,
                    AppConstants.kigaliCenterLng,
                  ),
                  zoom: AppConstants.defaultZoom,
                ),
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
              
              // Selected listing card
              if (_selectedListing != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Card(
                    color: AppTheme.secondaryDark,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListingDetailScreen(
                              listing: _selectedListing!,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedListing!.name,
                                        style: const TextStyle(
                                          color: AppTheme.textWhite,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentGold.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _selectedListing!.category,
                                          style: const TextStyle(
                                            color: AppTheme.accentGold,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppTheme.textGray),
                                  onPressed: () {
                                    setState(() {
                                      _selectedListing = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppTheme.accentGold,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _selectedListing!.address,
                                    style: const TextStyle(
                                      color: AppTheme.textGray,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Tap for details',
                                    style: TextStyle(
                                      color: AppTheme.accentGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: AppTheme.accentGold,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
