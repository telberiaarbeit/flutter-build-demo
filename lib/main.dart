import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const CryptoDashboardApp());
}

class CryptoDashboardApp extends StatelessWidget {
  const CryptoDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Dashboard',
      home: const CryptoDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CryptoDashboard extends StatefulWidget {
  const CryptoDashboard({super.key});

  @override
  State<CryptoDashboard> createState() => _CryptoDashboardState();
}

class _CryptoDashboardState extends State<CryptoDashboard> {
  double btcPrice = 0.0;
  double ethPrice = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchPrices());
  }

  Future<void> _fetchPrices() async {
    final url = Uri.parse(
        'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=eur');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        btcPrice = data['bitcoin']['eur']?.toDouble() ?? 0.0;
        ethPrice = data['ethereum']['eur']?.toDouble() ?? 0.0;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BTC vs ETH in EUR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPriceCard('Bitcoin (BTC)', btcPrice),
            const SizedBox(height: 20),
            _buildPriceCard('Ethereum (ETH)', ethPrice),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(String label, double price) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('€${price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// vercel.json
// {
//   "rewrites": [
//     { "source": "/(.*)", "destination": "/index.html" }
//   ]
// }