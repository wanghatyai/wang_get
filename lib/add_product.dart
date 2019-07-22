import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:wang_get/product_scan_model.dart';
import 'package:wang_get/image_detail.dart';

//import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';



class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {

  List units = [];
  String _currentUnit;

  String act = "Unit";

  File imageFile1;
  File imageFile2;
  File imageFile3;

  var loading = false;
  String barcode;
  List<ProductScan> _product = [];
  List<ProductScan> _search = [];

  TextEditingController barcodeProduct = TextEditingController();
  TextEditingController boxAmount = TextEditingController();
  TextEditingController unitAmount = TextEditingController();
  TextEditingController typeUnit = TextEditingController();
  TextEditingController receiveDetail = TextEditingController();

  _getUiitProduct() async{
    final res = await http.get('http://wangpharma.com/API/receiveProduct.php?act=$act');

    if(res.statusCode == 200){

      setState(() {

        var jsonData = json.decode(res.body);

        //units = jsonData;

        jsonData.forEach((unit) => units.add(unit['unitName']));

        print(units);
        return units;

      });

    }else{
      throw Exception('Failed load Json');
    }
  }

  _onDropDownItemSelected(newValueSelected){
    setState(() {
      _currentUnit = newValueSelected;
    });
  }

  _openCamera(camPosition) async {
      var picture = await ImagePicker.pickImage(source: ImageSource.camera);
      this.setState((){
        if(camPosition == 1){
          imageFile1 = picture;
        }else if(camPosition == 2){
          imageFile2 = picture;
        }else{
          imageFile3 = picture;
        }
      });
      //Navigator.of(context).pop();
  }

  _decideImageView(camPosition){

    File imageFileC;

    if(camPosition == 1){
      imageFileC = imageFile1;
    }else if(camPosition == 2){
      imageFileC = imageFile2;
    }else{
      imageFileC = imageFile3;
    }

    if(imageFileC == null){
      return Image (
        image: AssetImage ( "assets/photo_default_2.png" ), width: 100, height: 100,
      );
    }else{
      return GestureDetector(
        onTap: () {
          print("open img.");
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImageDetailPage(imageFile: imageFileC)));
        },
        child: Image.file(imageFileC, width: 100, height: 100),
      );
    }
  }

  onSearch(String text) async{
    _search.clear();
    if(text.isEmpty){
      setState(() {});
      return;
    }

    searchProduct(text);

    _product.forEach((f){
      if(f.productName.contains(text)) _search.add(f);
    });

    setState(() {});
  }

  scanBarcode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState((){
        this.barcode = barcode;
        searchProduct(this.barcode);
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _showAlertBarcode();
        print('Camera permission was denied');
      } else {
        print('Unknow Error $e');
      }
    } on FormatException {
      print('User returned using the "back"-button before scanning anything.');
    } catch (e) {
      print('Unknown error.');
    }
  }

  void _showAlertBarcode() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('คุณไม่เปิดอนุญาตใช้กล้อง'),
        );
      },
    );
  }

  searchProduct(searchVal) async{

    barcodeProduct = TextEditingController(text: searchVal);


    setState(() {
      loading = true;
    });
    _product.clear();

    //productAll = [];

    final res = await http.get('http://wangpharma.com/API/receiveProduct.php?SearchVal=$searchVal&act=Search');

    if(res.statusCode == 200){

      setState(() {

        //loading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) =>_product.add(ProductScan.fromJson(products)));

        print(_product);
        return _product;

      });

    }else{
      throw Exception('Failed load Json');
    }

  }

  _getProductInfo(){

    if(!loading){
      return Text('....');
    }else{
      return Container(
        child: ListView.builder(
          shrinkWrap:true,
          itemCount: _product.length,
          itemBuilder: (context, i){
            final a = _product[i];
            return ListTile(
              contentPadding: EdgeInsets.fromLTRB(10, 1, 10, 1),
              onTap: (){

              },
              leading: Image.network('http://www.wangpharma.com/cms/product/${a.productPic}', fit: BoxFit.cover, width: 70, height: 70),
              title: Text('${a.productName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${a.productCode}'),
                  Text('หน่วยเล็กสุด : ${a.productUnit}', style: TextStyle(color: Colors.blue), overflow: TextOverflow.ellipsis),
                ],
              ),
              /*trailing: IconButton(
                  icon: Icon(Icons.view_list, color: Colors.teal, size: 40,),
                  onPressed: (){
                    //addToOrderFast(a);
                  }
              ),*/
            );
          },
        ),
      );
    }
  }

  @override
  void initState(){
    super.initState();
    _getUiitProduct();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                  child: IconButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      icon: Icon(Icons.settings_overscan, size: 50, color: Colors.red,),
                      onPressed: (){
                        scanBarcode();
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                      }
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(25, 0, 10, 0),
                    child: TextField (
                      controller: barcodeProduct,
                      onChanged: onSearch,
                      style: TextStyle (
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration (
                          labelText: 'Barcode / Code สินค้า',
                          labelStyle: TextStyle (
                            fontSize: (15),
                          )
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                  child: IconButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      icon: Icon(Icons.add_circle, size: 50, color: Colors.green,),
                      onPressed: (){
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                      }
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: TextFormField (
                      textAlign: TextAlign.center,
                      controller: boxAmount,
                      style: TextStyle (
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration (
                          labelText: 'จำนวนลัง',
                          labelStyle: TextStyle (
                            fontSize: (15),
                          )
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                Text(" / ลัง", style: TextStyle(fontSize: 18)),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: TextFormField (
                      textAlign: TextAlign.center,
                      controller: unitAmount,
                      style: TextStyle (
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration (
                          labelText: 'จำนวนหน่วย',
                          labelStyle: TextStyle (
                            fontSize: (15),
                          )
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                Text("/", style: TextStyle(fontSize: 18)),
                Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5, 0, 10, 0),
                      child: DropdownButton(
                        hint: Text("หน่วยสินค้า",style: TextStyle(fontSize: 16)),
                        items: units.map((dropDownStringItem){
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(dropDownStringItem, style: TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (newValueSelected){
                          _onDropDownItemSelected(newValueSelected);
                          print(this._currentUnit);
                        },
                        value: _currentUnit,
                      ),
                    )
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  //flex: 2,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextFormField (
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlign: TextAlign.start,
                      controller: receiveDetail,
                      style: TextStyle (
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration (
                          labelText: 'เพิ่มเติม*',
                          labelStyle: TextStyle (
                            fontSize: (15),
                          )
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Text("รูปวันหมดอายุ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      _decideImageView(1),
                      IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: Icon(Icons.camera_alt, size: 50,),
                          onPressed: (){
                            _openCamera(1);
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                          }
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Text("รูปราคาป้าย", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      _decideImageView(2),
                      IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: Icon(Icons.camera_alt, size: 50,),
                          onPressed: (){
                            _openCamera(2);
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                          }
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Text("รูป LOT สินค้า", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      _decideImageView(3),
                      IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: Icon(Icons.camera_alt, size: 50,),
                          onPressed: (){
                            _openCamera(3);
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                          }
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.lightBlue,
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text('รายละเอียดสินค้า', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,),
                  )
                )
              ],
            ),
            _getProductInfo(),
          ],
        ),
      ),
    );
  }
}
