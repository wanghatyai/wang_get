class ProductScan{
  final String productId;
  final String productName;
  final String productCode;
  final String productBarcode;
  final String productPic;
  final String productUnit;

  ProductScan({
    this.productId,
    this.productName,
    this.productCode,
    this.productBarcode,
    this.productPic,
    this.productUnit
  });

  factory ProductScan.fromJson(Map<String, dynamic> json){
    return new ProductScan(
      productId: json['pID'],
      productName: json['nproduct'],
      productCode: json['pcode'],
      productBarcode: json['bcode'],
      productPic: json['pic'],
      productUnit: json['unit1'],
    );
  }

}