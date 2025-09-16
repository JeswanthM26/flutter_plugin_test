/// A model class representing a GPS location with various attributes.
/// It includes latitude, longitude, accuracy, altitude, speed, and
/// an optional timestamp.
class LocationModel {
  /// Constructs a [LocationModel] with the given parameters.
  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    this.timestamp,
  });

  /// Creates a [LocationModel] instance from a map.
  factory LocationModel.fromMap(final Map<String, dynamic> map) =>
      LocationModel(
        latitude: map["latitude"] as double,
        longitude: map["longitude"] as double,
        accuracy: map["accuracy"] as double,
        altitude: map["altitude"] as double,
        speed: map["speed"] as double,
        timestamp: map["timestamp"] != null
            ? DateTime.parse(map["timestamp"])
            : null,
      );

  /// The latitude of the location.
  final double latitude;

  /// The longitude of the location.
  final double longitude;

  /// The accuracy of the location in meters.
  final double accuracy;

  /// The altitude of the location in meters.
  final double altitude;

  /// The speed at the location in meters per second.
  final double speed;

  /// The timestamp of the location, if available.
  final DateTime? timestamp;

  /// Converts the [LocationModel] instance to a map.
  Map<String, dynamic> toMap() => <String, dynamic>{
    "latitude": latitude,
    "longitude": longitude,
    "accuracy": accuracy,
    "altitude": altitude,
    "speed": speed,
    "timestamp": timestamp?.toIso8601String(),
  };
}
