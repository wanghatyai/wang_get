import 'package:flutter/material.dart';

import 'package:wang_get/report_image_detail.dart';

class ReportDetailPage extends StatefulWidget {

  var receiveProducts;
  ReportDetailPage({Key key, this.receiveProducts}) : super(key: key);

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text(widget.product.productName.toString()),
        title: Text("รายละเอียดรับสินค้า"),
        actions: <Widget>[
          /*IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: (){
                //Navigator.pushReplacementNamed(context, '/Order');
              }
          )*/
        ],
      ),
      body: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      leading: Image.network('http://www.wangpharma.com/cms/product/${widget.receiveProducts.recevicProductPic}', fit: BoxFit.cover, width: 70, height: 70),
                      title: Text('${widget.receiveProducts.recevicProductName}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Code : ${widget.receiveProducts.recevicProductCode}'),
                          Text('Barcode : ${widget.receiveProducts.recevicTCbarcode}'),
                          Text('ลัง : ${widget.receiveProducts.recevicTCqtyBox}', style: TextStyle(color: Colors.red),),
                          Text('หน่วยย่อย : ${widget.receiveProducts.recevicTCqtySub} ${widget.receiveProducts.recevicProductUnit}', style: TextStyle(color: Colors.lightBlue),),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: <Widget>[
                        Text("รูปวันหมดอายุ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReportImageDetailPage(receiveProductPic: widget.receiveProducts.recevicPic)));
                          },
                          child: Image.network('http://www.wangpharma.com/cms/FileUpload/Warehouse/receiveBox/${widget.receiveProducts.recevicPic}', fit: BoxFit.cover, width: 120, height: 100),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: <Widget>[
                        Text("รูปราคาป้าย", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ReportImageDetailPage(receiveProductPic: widget.receiveProducts.recevicPicEx)));
                          },
                          child: Image.network('http://www.wangpharma.com/cms/FileUpload/Warehouse/receiveBox/${widget.receiveProducts.recevicPicEx}', fit: BoxFit.cover, width: 120, height: 100),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: <Widget>[
                        Text("รูป LOT สินค้า", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ReportImageDetailPage(receiveProductPic: widget.receiveProducts.recevicPicPriceTag)));
                          },
                          child: Image.network('http://www.wangpharma.com/cms/FileUpload/Warehouse/receiveBox/${widget.receiveProducts.recevicPicPriceTag}', fit: BoxFit.cover, width: 120, height: 100),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
      ),
    );
  }
}
