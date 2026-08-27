class BikeFrame {
  final int frameNumber;
  final String image;

  BikeFrame({required this.frameNumber, required this.image});

  factory BikeFrame.fromJson(Map<String, dynamic> json) =>
      BikeFrame(frameNumber: json['frame_number'], image: json['image']);
}

class BikeColorVariant {
  final int id;
  final String name;
  final String tankImage;
  final List<BikeFrame> frames;

  BikeColorVariant({
    required this.id,
    required this.name,
    required this.tankImage,
    required this.frames,
  });

  factory BikeColorVariant.fromJson(Map<String, dynamic> json) {
    final framesJson = json['frames'] as List? ?? [];
    return BikeColorVariant(
      id: json['id'],
      name: json['name'],
      tankImage: json['tank_image'],
      frames: framesJson
          .map((f) => BikeFrame.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Parses '#1B3A5C' into a Flutter Color. Falls back to a neutral
  /// grey if the hex string is malformed.
  int get colorValue {
    try {
      final hex = tankImage.replaceFirst('#', '');
      return int.parse('FF$hex', radix: 16);
    } catch (_) {
      return 0xFF9C9081;
    }
  }
}
