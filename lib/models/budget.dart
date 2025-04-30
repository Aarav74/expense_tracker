class Budget {
  final double monthlyLimit;
  final Map<String, double> categoryLimits;

  Budget({
    required this.monthlyLimit,
    this.categoryLimits = const {},
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      monthlyLimit: map['monthlyLimit'] ?? 0.0,
      categoryLimits: Map<String, double>.from(map['categoryLimits'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monthlyLimit': monthlyLimit,
      'categoryLimits': categoryLimits,
    };
  }
}