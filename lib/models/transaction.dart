import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  final int id;
  final String transactionCode;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final int? referenceId;
  final String? referenceType;
  final String? mpesaReceipt;
  final String status;
  final String? description;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.transactionCode,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.referenceId,
    this.referenceType,
    this.mpesaReceipt,
    required this.status,
    this.description,
    required this.createdAt,
  });

  bool get isCredit => type == 'topup' || type == 'refund' || type == 'promo_credit';
  bool get isDebit => type == 'ride_payment' || type == 'payout' || type == 'commission_payment';
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';

  String get formattedAmount {
    final prefix = isCredit ? '+' : '-';
    return '$prefix KES ${amount.toStringAsFixed(0)}';
  }

  String get formattedBalance => 'KES ${balanceAfter.toStringAsFixed(0)}';

  String get transactionTitle {
    switch (type) {
      case 'topup':
        return 'Wallet Top Up';
      case 'ride_payment':
        return 'Ride Payment';
      case 'refund':
        return 'Refund';
      case 'promo_credit':
        return 'Promo Credit';
      case 'payout':
        return 'Withdrawal';
      case 'commission_payment':
        return 'Commission Payment';
      default:
        return 'Transaction';
    }
  }

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
