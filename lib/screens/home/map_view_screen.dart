import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/listings_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../listings/listing_detail_screen.dart';
import '../listings/create_listing_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  ListingModel? _selectedListing;
  Set<Marker> _markers = {};
  int _listingsCount = 0;

  // Called ONLY after map is created - updates markers via setState so GoogleMap renders them
  void _refreshMarkers(List<ListingModel> listings) {
    debugPrint('🔄 Refreshing markers for ${listings.length} listings');
    final newMarkers = <Marker>{};

    // Test marker at Kigali center
    newMarkers.add(
      Marker(
        markerId: const MarkerId('kigali_center'),
        position: const LatLng(AppConstants.kigaliCenterLat, AppConstants.kigaliCenterLng),
        infoWindow: const InfoWindow(title: 'Kigali City Center'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    for (final listing in listings) {
      debugPrint('   📍 ${listing.name}: (${listing.latitude}, ${listing.longitude})');
      newMarkers.add(
        Marker(
          markerId: MarkerId(listing.id ?? listing.name),
          position: LatLng(listing.latitude, listing.longitude),
          infoWindow: InfoWindow(
            title: listing.name,
            snippet: listing.category,
          ),
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            setState(() {
              _selectedListing = listing;
            });
          },
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
      _listingsCount = listings.length;
    });

    debugPrint('✅ Markers updated: ${_markers.length} total');

    // Move camera to fit all markers after a brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _fitMarkersInView();
    });
  }

  void _fitMarkersInView() {
    if (_mapController == null || _markers.isEmpty) return;
    try {
      double minLat = _markers.first.position.latitude;
      double maxLat = _markers.first.position.latitude;
      double minLng = _markers.first.position.longitude;
      double maxLng = _markers.first.position.longitude;
      for (final m in _markers) {
        if (m.position.latitude < minLat) minLat = m.position.latitude;
        if (m.position.latitude > maxLat) maxLat = m.position.latitude;
        if (m.position.longitude < minLng) minLng = m.position.longitude;
        if (m.position.longitude > maxLng) maxLng = m.position.longitude;
      }
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - 0.02, minLng - 0.02),
            northeast: LatLng(maxLat + 0.02, maxLng + 0.02),
          ),
          60,
        ),
      );
      debugPrint('📷 Camera fitted to markers');
    } catch (e) {
      debugPrint('❌ Camera fit error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View', style: TextStyle(color: AppTheme.textWhite)),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppTheme.accentGold),
            tooltip: 'Center on Kigali',
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  const LatLng(AppConstants.kigaliCenterLat, AppConstants.kigaliCenterLng),
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
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
          }

          if (provider.error != null) {
            return Center(
              child: Text('Error: ${provider.error}',
                  style: const TextStyle(color: AppTheme.textGray)),
            );
          }

          // When map is ready and listings have loaded (or changed), refresh markers
          if (_mapController != null && provider.allListings.length != _listingsCount) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _refreshMarkers(provider.allListings);
            });
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(AppConstants.kigaliCenterLat, AppConstants.kigaliCenterLng),
                  zoom: AppConstants.defaultZoom,
                ),
                // Use state-based markers - populated only after map is created
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  debugPrint('🗺️ onMapCreated fired!');
                  _mapController = controller;
                  // CRITICAL: Use postFrameCallback to call setState after build completes
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _refreshMarkers(provider.allListings);
                  });
                },
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
              ),

              // Empty state overlay
              if (provider.allListings.isEmpty)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryDark.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentGold, width: 2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_location_alt, size: 80, color: AppTheme.accentGold),
                          const SizedBox(height: 24),
                          const Text('No Listings on Map',
                              style: TextStyle(color: AppTheme.textWhite, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Text('Create your first listing to see it here',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textGray, fontSize: 16)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const CreateListingScreen())),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Listing'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentGold,
                              foregroundColor: AppTheme.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Debug overlay
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryDark.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.accentGold, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Listings: ${provider.allListings.length}',
                          style: const TextStyle(color: AppTheme.textWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Markers: ${_markers.length}',
                          style: const TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Map: ${_mapController != null ? "Ready" : "Loading"}',
                          style: TextStyle(
                              color: _mapController != null ? Colors.green : Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: _selectedListing!))),
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
                                      Text(_selectedListing!.name,
                                          style: const TextStyle(
                                              color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentGold.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(_selectedListing!.category,
                                            style: const TextStyle(
                                                color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppTheme.textGray),
                                  onPressed: () => setState(() => _selectedListing = null),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: AppTheme.accentGold, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(_selectedListing!.address,
                                      style: const TextStyle(color: AppTheme.textGray, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Expanded(
                                  child: Text('Tap for details',
                                      style: TextStyle(
                                          color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                Icon(Icons.arrow_forward, color: AppTheme.accentGold, size: 16),
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

