// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiscountModelAdapter extends TypeAdapter<DiscountModel> {
  @override
  final int typeId = 0;

  @override
  DiscountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiscountModel(
      propertyId: fields[0] as int,
      discountType: fields[1] as String,
      discountValue: fields[2] as double,
      minAmount: fields[3] as double,
      maxAmount: fields[4] as double,
      applyOn: fields[5] as String,
      status: fields[6] as String,
      startDate: fields[7] as String,
      outletName: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DiscountModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.propertyId)
      ..writeByte(1)
      ..write(obj.discountType)
      ..writeByte(2)
      ..write(obj.discountValue)
      ..writeByte(3)
      ..write(obj.minAmount)
      ..writeByte(4)
      ..write(obj.maxAmount)
      ..writeByte(5)
      ..write(obj.applyOn)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.outletName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
