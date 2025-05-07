import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const SushiApp());
}

class SushiApp extends StatelessWidget {
  const SushiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aneska Sushi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}

class SushiItem {
  final String name;
  final String description;
  final int price;
  final String imageAsset;
  int quantity;
  String status;

  SushiItem(this.name, this.description, this.price, this.imageAsset,
      {this.quantity = 0, this.status = 'Sedang diproses'});

  SushiItem.clone(SushiItem item)
      : this(item.name, item.description, item.price, item.imageAsset,
            quantity: item.quantity, status: item.status);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MenuPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rice_bowl, size: 100, color: Colors.redAccent),
            SizedBox(height: 16),
            Text('Aneska Sushi',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<SushiItem> sushiRoll = [
    SushiItem('Beef Cheese Roll', 'Sushi daging sapi & keju.', 21000, 'assets/sushiroll/sushi1.png'),
    SushiItem('Crispy Tuna', 'Tuna pedas & salad.', 21000, 'assets/sushiroll/sushi2.png'),
    SushiItem('Dragon Roll', 'Udang tempura & alpukat.', 29000, 'assets/sushiroll/sushi3.png'),
    SushiItem('Garlic Salmon', 'Salmon & saus bawang.', 29000, 'assets/sushiroll/sushi4.png'),
  ];

  final List<SushiItem> sashimi = [
    SushiItem('Salmon Sashimi', 'Irisan salmon segar.', 32000, 'assets/sashimi/sushi5.png'),
    SushiItem('Tuna Sashimi', 'Irisan tuna premium.', 30000, 'assets/sashimi/sushi6.png'),
    SushiItem('Mix Sashimi', 'Salmon, tuna & cumi.', 35000, 'assets/sashimi/sushi7.png'),
    SushiItem('Octopus Sashimi', 'Sashimi gurita segar.', 33000, 'assets/sashimi/sushi8.png'),
  ];

  final List<SushiItem> nigiri = [
    SushiItem('Salmon Nigiri', 'Nasi & irisan salmon.', 25000, 'assets/nigiri/sushi9.png'),
    SushiItem('Ebi Nigiri', 'Nasi & udang.', 24000, 'assets/nigiri/sushi10.png'),
    SushiItem('Tamago Nigiri', 'Nasi & telur manis.', 22000, 'assets/nigiri/sushi11.png'),
    SushiItem('Unagi Nigiri', 'Nasi & belut bakar.', 28000, 'assets/nigiri/sushi12.png'),
  ];

  String selectedCategory = 'Sushi Roll';
  final List<SushiItem> cart = [];

  final Map<String, List<SushiItem>> allCategories = {};

  @override
  void initState() {
    allCategories['Sushi Roll'] = sushiRoll;
    allCategories['Sashimi'] = sashimi;
    allCategories['Nigiri'] = nigiri;
    super.initState();
  }

  void addToCart(SushiItem item) {
    setState(() {
      var existing = cart.where((e) => e.name == item.name).toList();
      if (existing.isEmpty) {
        cart.add(SushiItem.clone(item)..quantity = 1);
      } else {
        existing[0].quantity++;
      }
    });
  }

  void removeFromCart(SushiItem item) {
    setState(() {
      var found = cart.firstWhere((e) => e.name == item.name);
      found.quantity--;
      if (found.quantity <= 0) {
        cart.remove(found);
      }
    });
  }

  Widget buildCategoryButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: allCategories.keys.map((category) {
        final isSelected = selectedCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              selectedCategory = category;
            });
          },
          selectedColor: Colors.redAccent.shade100,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.grey.shade700),
        );
      }).toList(),
    );
  }

  Widget buildMenuCard(SushiItem item) {
    final inCart = cart.any((e) => e.name == item.name);
    final quantity = cart.firstWhere((e) => e.name == item.name, orElse: () => SushiItem('', '', 0, '')).quantity;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(item.imageAsset, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item.description, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text('Rp ${item.price}', style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 8),
                inCart
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            onPressed: () => removeFromCart(item),
                          ),
                          Text('$quantity'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            onPressed: () => addToCart(item),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => addToCart(item),
                          child: const Text('Tambah'),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartPage(cartItems: cart)),
    ).then((_) => setState(() {})); // refresh menu if needed
  }

  @override
  Widget build(BuildContext context) {
    final items = allCategories[selectedCategory]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aneska Sushi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: openCart),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Our Menu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
          ),
          const SizedBox(height: 16),
          buildCategoryButtons(),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (_, index) => buildMenuCard(items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Perbaikan utama ada di sini:
class CartPage extends StatefulWidget {
  final List<SushiItem> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void removeItem(SushiItem item) {
    setState(() {
      item.quantity--;
      if (item.quantity <= 0) {
        widget.cartItems.remove(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int total = widget.cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: widget.cartItems.isEmpty
            ? const Center(child: Text('Keranjang masih kosong'))
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.cartItems.length,
                      itemBuilder: (_, index) {
                        final item = widget.cartItems[index];
                        return ListTile(
                          leading: Image.asset(item.imageAsset, width: 40),
                          title: Text(item.name),
                          subtitle: Text('x${item.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Rp ${item.price * item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                onPressed: () => removeItem(item),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Text('Total: Rp $total', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CheckoutPage(orderItems: widget.cartItems)),
                      );
                    },
                    child: const Text('Checkout'),
                  ),
                ],
              ),
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final List<SushiItem> orderItems;
  const CheckoutPage({super.key, required this.orderItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool orderPlaced = false;
  String selectedPayment = 'Bayar di Tempat';

  final List<String> paymentMethods = ['Bayar di Tempat', 'QRIS', 'Kartu Debit/Kredit'];

  void placeOrder() {
    setState(() => orderPlaced = true);
    updateStatusLater();
  }

  void updateStatusLater() async {
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      for (var item in widget.orderItems) {
        item.status = 'Selesai';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int total = widget.orderItems.fold(0, (sum, item) => sum + item.price * item.quantity);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: orderPlaced
            ? Column(
                children: [
                  const Text('Pesanan Anda',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.orderItems.length,
                      itemBuilder: (_, index) {
                        final item = widget.orderItems[index];
                        return ListTile(
                          leading: Image.asset(item.imageAsset, width: 40),
                          title: Text('${item.name} x${item.quantity}'),
                          subtitle: Text(item.status),
                        );
                      },
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Metode Pembayaran',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedPayment,
                    isExpanded: true,
                    items: paymentMethods
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedPayment = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Total yang harus dibayar: Rp $total',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: placeOrder,
                    child: const Text('Pesan'),
                  ),
                ],
              ),
      ),
    );
  }
}
