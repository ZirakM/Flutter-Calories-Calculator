class Food {
  int id;
  String name;
  int calories;
  String date;

  Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'calories': calories, 'date': date};
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      date: map['date'],
    );
  }
}
