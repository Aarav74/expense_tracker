// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetHistoryEntryAdapter extends TypeAdapter<BudgetHistoryEntry> {
  @override
  final int typeId = 2;

  @override
  BudgetHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetHistoryEntry(
      fields[0] as double,
      fields[1] as DateTime,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetHistoryEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
