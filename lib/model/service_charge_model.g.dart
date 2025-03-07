// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_charge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceChargeModelAdapter extends TypeAdapter<ServiceChargeModel> {
  @override
  final int typeId = 1;

  @override
  ServiceChargeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceChargeModel(
      propertyId: fields[0] as int,
      serviceCharge: fields[1] as double,
      minAmount: fields[2] as double,
      maxAmount: fields[3] as double,
      applyOn: fields[4] as String,
      status: fields[5] as String,
      startDate: fields[6] as String,
      outletName: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ServiceChargeModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.propertyId)
      ..writeByte(1)
      ..write(obj.serviceCharge)
      ..writeByte(2)
      ..write(obj.minAmount)
      ..writeByte(3)
      ..write(obj.maxAmount)
      ..writeByte(4)
      ..write(obj.applyOn)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.outletName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceChargeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
