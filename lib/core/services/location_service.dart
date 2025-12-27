import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now).
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return null;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<Placemark?> getPlacemarkFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  String? getRegionFromPlacemark(Placemark place) {
    // Map Brazilian states to regions
    // adminArea is usually the State name (e.g. "São Paulo", "Bahia")
    final state = place.administrativeArea?.toLowerCase() ?? '';
    final country = place.isoCountryCode?.toUpperCase() ?? '';

    if (country != 'BR') return null; // Only for Brazil for now

    // Map of states to regions
    const regions = {
      'acre': 'norte',
      'alagoas': 'nordeste',
      'amapá': 'norte',
      'amazonas': 'norte',
      'bahia': 'nordeste',
      'ceará': 'nordeste',
      'distrito federal': 'centro_oeste',
      'espírito santo': 'sudeste',
      'goiás': 'centro_oeste',
      'maranhão': 'nordeste',
      'mato grosso': 'centro_oeste',
      'mato grosso do sul': 'centro_oeste',
      'minas gerais': 'sudeste',
      'pará': 'norte',
      'paraíba': 'nordeste',
      'paraná': 'sul',
      'pernambuco': 'nordeste',
      'piauí': 'nordeste',
      'rio de janeiro': 'sudeste',
      'rio grande do norte': 'nordeste',
      'rio grande do sul': 'sul',
      'rondônia': 'norte',
      'roraima': 'norte',
      'santa catarina': 'sul',
      'são paulo': 'sudeste',
      'sergipe': 'nordeste',
      'tocantins': 'norte',
    };

    for (var entry in regions.entries) {
      if (state.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }
}
