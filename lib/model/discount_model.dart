import 'package:hive/hive.dart';

part 'discount_model.g.dart'; // Required for generated adapter

@HiveType(typeId: 0) // Assign a unique typeId
class DiscountModel {
  @HiveField(0)
  final int propertyId;

  @HiveField(1)
  final String discountType;

  @HiveField(2)
  final double discountValue;

  @HiveField(3)
  final double minAmount;

  @HiveField(4)
  final double maxAmount;

  @HiveField(5)
  final String applyOn;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final String startDate;

  @HiveField(8)
  final String outletName;

  DiscountModel({
    required this.propertyId,
    required this.discountType,
    required this.discountValue,
    required this.minAmount,
    required this.maxAmount,
    required this.applyOn,
    required this.status,
    required this.startDate,
    required this.outletName,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      propertyId: int.tryParse(json['property_id'].toString()) ?? 0,
      discountType: json['discount_type'].toString(),
      discountValue: double.tryParse(json['discount_value'].toString()) ?? 0.0,
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
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_amount': minAmount,
      'max_amount': maxAmount,
      'apply_on': applyOn,
      'status': status,
      'start_date': startDate,
      'outlet_name': outletName,
    };
  }
}
