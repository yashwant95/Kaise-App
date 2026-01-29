class Category {
  final String id;
  final String label;
  final String icon;
  final String color;
  final int order;

  Category({
    required this.id,
    required this.label,
    required this.icon,
    this.color = 'blue',
    this.order = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? 'blue',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'label': label,
      'icon': icon,
      'color': color,
      'order': order,
    };
  }
}
