import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CurrencyService extends ChangeNotifier {
  final Box<String> _currencyBox;
  static const String _defaultCurrency = 'USD';
  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'INR': '₹',
    'CAD': '\$',
    'AUD': '\$',
  };

  CurrencyService(this._currencyBox);

  String get currentCurrency => _currencyBox.get('currency') ?? _defaultCurrency;
  String get currencySymbol => _currencySymbols[currentCurrency] ?? '\$';

  List<String> get availableCurrencies => _currencySymbols.keys.toList();

  Future<void> setCurrency(String currencyCode) async {
    if (_currencySymbols.containsKey(currencyCode)) {
      await _currencyBox.put('currency', currencyCode);
      notifyListeners();
    }
  }

  String formatAmount(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }
}