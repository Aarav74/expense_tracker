import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final double amount;
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final String? description;

  @HiveField(5) // New field
  final String? location;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    this.location, required String title, // Added to constructor
  });
}