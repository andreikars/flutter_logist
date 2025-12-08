class Declaration {
  final int? id;
  final int? clientId;
  final String? clientName;
  final String declarationNumber;
  final String declarationType;
  final String? tnvedCode;
  final String productDescription;
  final double productValue;
  final double? netWeight;
  final int? quantity;
  final String? countryOfOrigin;
  final String? countryOfDestination;
  final String? customsOffice;
  final String status;
  final DateTime? createdAt;

  Declaration({
    this.id,
    this.clientId,
    this.clientName,
    required this.declarationNumber,
    required this.declarationType,
    this.tnvedCode,
    required this.productDescription,
    required this.productValue,
    this.netWeight,
    this.quantity,
    this.countryOfOrigin,
    this.countryOfDestination,
    this.customsOffice,
    required this.status,
    this.createdAt,
  });

  factory Declaration.fromJson(Map<String, dynamic> json) {
    return Declaration(
      id: json['id'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      declarationNumber: json['declarationNumber'] ?? '',
      declarationType: json['declarationType'] ?? '',
      tnvedCode: json['tnvedCode'],
      productDescription: json['productDescription'] ?? '',
      productValue: (json['productValue'] ?? 0).toDouble(),
      netWeight: json['netWeight']?.toDouble(),
      quantity: json['quantity'],
      countryOfOrigin: json['countryOfOrigin'],
      countryOfDestination: json['countryOfDestination'],
      customsOffice: json['customsOffice'],
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'declarationType': declarationType,
      'productDescription': productDescription,
      'productValue': productValue,
      'status': status,
    };
    if (clientId != null) data['clientId'] = clientId;
    if (tnvedCode != null) data['tnvedCode'] = tnvedCode;
    if (netWeight != null) data['netWeight'] = netWeight;
    if (quantity != null) data['quantity'] = quantity;
    if (countryOfOrigin != null) data['countryOfOrigin'] = countryOfOrigin;
    if (countryOfDestination != null) {
      data['countryOfDestination'] = countryOfDestination;
    }
    if (customsOffice != null) data['customsOffice'] = customsOffice;
    return data;
  }
}

