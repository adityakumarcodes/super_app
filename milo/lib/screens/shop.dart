import 'package:flutter/material.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
        centerTitle: true,
        elevation: 2,
        shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: Center(
        child: Text('Shop'),
      ),
    );
  }
}
