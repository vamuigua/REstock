class ShoppingList {
  final int? id;
  final String name;
  final String? firebaseId;

  ShoppingList({
    this.id,
    required this.name,
    this.firebaseId,
  });

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'],
      name: map['name'],
      firebaseId: map['firebase_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'firebase_id': firebaseId,
    };
  }

  ShoppingList copyWith({
    int? id,
    String? name,
    String? firebaseId,
  }) {
    return ShoppingList(
      name: name ?? this.name,
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
    );
  }
}
