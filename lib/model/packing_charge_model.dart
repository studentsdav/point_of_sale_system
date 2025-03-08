import 'package:hive/hive.dart';

part 'packing_charge_model.g.dart'; // Required for generated adapter

@HiveType(typeId: 3) // Assign a unique typeId different from other models
class PackingChargeModel {
  @HiveField(0)
  final int propertyId;

  @HiveField(1)
  final double packingCharge;

  @HiveField(2)
  final double minAmount;

  @HiveField(3)
  final double maxAmount;

  @HiveField(4)
  final String applyOn;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final String startDate;

  @HiveField(7)
  final String outletName;

  PackingChargeModel({
    required this.propertyId,
    required this.packingCharge,
    required this.minAmount,
    required this.maxAmount,
    required this.applyOn,
    required this.status,
    required this.startDate,
    required this.outletName,
  });

  factory PackingChargeModel.fromJson(Map<String, dynamic> json) {
    return PackingChargeModel(
      propertyId: int.tryParse(json['property_id'].toString()) ?? 0,
      packingCharge: double.tryParse(json['packing_charge'].toString()) ?? 0.0,
      minAmount: double.tryParse(json['min_amount'].toString()) ?? 0.0,
      maxAmount: double.tryParse(json['max_amount'].toString()) ?? 0.0,
      applyOn: json['apply_on'].toString(),
      status: json['status'].toString(),
      startDate: json['start_date'].toString(),
      outletName: json['outlet_name'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'packing_charge': packingCharge,
      'min_amount': minAmount,
      'max_amount': maxAmount,
      'apply_on': applyOn,
      'status': status,
      'start_date': startDate,
      'outlet_name': outletName,
    };
  }
}
