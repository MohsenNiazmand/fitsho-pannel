class MetadataItem {
  const MetadataItem({
    required this.id,
    required this.type,
    required this.key,
    required this.labelFa,
    required this.labelEn,
    this.icon,
    this.order = 0,
    this.isActive = true,
    this.extraData,
  });

  final String id;
  final String type;
  final String key;
  final String labelFa;
  final String labelEn;
  final String? icon;
  final int order;
  final bool isActive;
  final Map<String, dynamic>? extraData;

  MetadataItem copyWith({
    String? id,
    String? type,
    String? key,
    String? labelFa,
    String? labelEn,
    String? icon,
    int? order,
    bool? isActive,
    Map<String, dynamic>? extraData,
  }) {
    return MetadataItem(
      id: id ?? this.id,
      type: type ?? this.type,
      key: key ?? this.key,
      labelFa: labelFa ?? this.labelFa,
      labelEn: labelEn ?? this.labelEn,
      icon: icon ?? this.icon,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      extraData: extraData ?? this.extraData,
    );
  }
}
