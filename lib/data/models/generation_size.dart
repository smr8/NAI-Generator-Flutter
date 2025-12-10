class GenerationSize {
  final int width;
  final int height;

  const GenerationSize({
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {"width": width, "height": height};
  }

  factory GenerationSize.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 1024;
      return 1024;
    }

    return GenerationSize(
        width: parseInt(json["width"]), height: parseInt(json["height"]));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GenerationSize) return false;
    return other.width == width && other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);
}
