// Library utama Flutter
import 'package:flutter/material.dart';

// Untuk menggunakan fitur HTTP request (API)
import 'package:http/http.dart' as http;

// Untuk menggunakan fitur Timer
import 'dart:async';

// Untuk decoding data JSON dari API
import 'dart:convert';

// Fungsi utama untuk menjalankan aplikasi
void main() {
  runApp(const SushiApp());
}

// Widget utama aplikasi
class SushiApp extends StatelessWidget {
  const SushiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aneska Sushi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Gunakan skema warna berbasis seedColor
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}

// Kelas model data untuk item sushi
class SushiItem {
  final String name;
  final String description;
  final int price;
  final String imageAsset;
  int quantity;
  String status;

  // Konstruktor utama dengan nilai default
  SushiItem(this.name, this.description, this.price, this.imageAsset,
      {this.quantity = 0, this.status = 'Sedang diproses'});

  // Konstruktor cloning untuk membuat salinan item
  SushiItem.clone(SushiItem item)
      : this(item.name, item.description, item.price, item.imageAsset,
            quantity: item.quantity, status: item.status);
}

// Model data untuk resep dari API
class Recipe {
  final String id;
  final String title;
  final String thumbnail;

  Recipe({required this.id, required this.title, required this.thumbnail});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal'],
      title: json['strMeal'],
      thumbnail: json['strMealThumb'],
    );
  }
}

// Fungsi untuk mengambil data resep dari API
Future<List<Recipe>> fetchSushiRecipes() async {
  final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final meals = data['meals'] as List;
    return meals.map((json) => Recipe.fromJson(json)).toList();
  } else {
    throw Exception('Gagal mengambil data resep');
  }
}

// Widget untuk splash screen (layar awal saat aplikasi dibuka)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// State dari splash screen
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigasi ke halaman menu setelah 2 detik
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
// Halaman Menu utama aplikasi sushi
// Menggunakan StatefulWidget karena ada data dinamis seperti kategori yang dipilih dan isi keranjang
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

// State dari halaman Menu, berisi logika utama untuk pengelolaan kategori, item, dan keranjang
class _MenuPageState extends State<MenuPage> {
  // List item sushi untuk kategori Sushi Roll
  final List<SushiItem> sushiRoll = [
    SushiItem('Beef Cheese Roll', 'Beef Sushi & Cheese', 21000, 'assets/sushiroll/sushi1.png'),
    SushiItem('Salmon Cheese Roll', 'Salmon & Cheese', 21000, 'assets/sushiroll/sushi2.png'),
    SushiItem('Dragon Roll', 'Beef Slice & Avocado', 21000, 'assets/sushiroll/sushi3.png'),
    SushiItem('Cruncy Nori Roll', 'Cruncy Salmon Maki', 21000, 'assets/sushiroll/sushi4.png'),
  ];

  // List item sushi untuk kategori Sashimi
  final List<SushiItem> sashimi = [
    SushiItem('Salmon Sashimi', 'Irisan salmon segar', 32000, 'assets/sashimi/sushi5.png'),
    SushiItem('Tuna Sashimi', 'Irisan tuna premium', 30000, 'assets/sashimi/sushi6.png'),
    SushiItem('Mix Sashimi', 'Salmon, tuna & cumi', 35000, 'assets/sashimi/sushi7.png'),
    SushiItem('Octopus Sashimi', 'Sashimi gurita segar', 33000, 'assets/sashimi/sushi8.png'),
  ];

  // List item sushi untuk kategori Nigiri
  final List<SushiItem> nigiri = [
    SushiItem('Salmon Nigiri', 'Nasi & irisan salmon', 25000, 'assets/nigiri/sushi9.png'),
    SushiItem('Ebi Nigiri', 'Nasi & udang', 24000, 'assets/nigiri/sushi10.png'),
    SushiItem('Tamago Nigiri', 'Nasi & telur manis', 22000, 'assets/nigiri/sushi11.png'),
    SushiItem('Unagi Nigiri', 'Nasi & belut bakar', 28000, 'assets/nigiri/sushi12.png'),
  ];

  // Keranjang belanja pengguna
  final List<SushiItem> cart = [];

  // Kategori yang sedang dipilih
  String selectedCategory = 'Sushi Roll';

  // Map untuk menyimpan semua kategori dan daftar itemnya
  final Map<String, List<SushiItem>> allCategories = {};

  // Warna pink lembut yang digunakan untuk tema
  final Color softPink = const Color(0xFFFF8A8A);

  // Inisialisasi data kategori
  @override
  void initState() {
    allCategories['Sushi Roll'] = sushiRoll;
    allCategories['Sashimi'] = sashimi;
    allCategories['Nigiri'] = nigiri;
    super.initState();
  }

  // Menambahkan item ke keranjang
  void addToCart(SushiItem item) {
    setState(() {
      var found = cart.firstWhere((e) => e.name == item.name, orElse: () => SushiItem('', '', 0, ''));
      if (found.name == '') {
        cart.add(SushiItem.clone(item)..quantity = 1);
      } else {
        found.quantity++;
      }
    });
  }

  // Mengurangi item dari keranjang
  void removeFromCart(SushiItem item) {
    setState(() {
      var found = cart.firstWhere((e) => e.name == item.name);
      found.quantity--;
      if (found.quantity <= 0) {
        cart.remove(found);
      }
    });
  }

  // Membuka halaman keranjang
  void openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartPage(cartItems: cart)),
    ).then((_) => setState(() {}));
  }

  // Membuat tombol kategori yang dapat digeser secara horizontal
  Widget buildCategoryButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: allCategories.keys.map((category) {
          final bool isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? softPink : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: softPink),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : softPink,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Membuat tampilan kartu menu sushi
  Widget buildMenuCard(SushiItem item) {
    final quantity = cart.firstWhere((e) => e.name == item.name, orElse: () => SushiItem('', '', 0, '')).quantity;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar sushi
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.imageAsset,
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Nama sushi
            Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            // Deskripsi sushi
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            // Harga dan tombol tambah/kurang jumlah item
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp ${item.price}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: softPink,
                  ),
                ),
                quantity > 0
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          children: [
                            _squareButton(Icons.remove, () => removeFromCart(item)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text('$quantity'),
                            ),
                            _squareButton(Icons.add, () => addToCart(item), color: softPink),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () => addToCart(item),
                        child: Container(
                          decoration: BoxDecoration(
                            color: softPink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Membuat tombol persegi kecil (untuk + dan - pada item)
  Widget _squareButton(IconData icon, VoidCallback onTap, {Color color = Colors.black54}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  // UI utama halaman Menu
  @override
  Widget build(BuildContext context) {
    final items = allCategories[selectedCategory]!;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama pengguna dan ikon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome, Aneska', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Let’s order and enjoy your sushi!',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.receipt_long, color: Color(0xFFFFB0B0)),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipePage())),
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFFFFB0B0)),
                            onPressed: openCart,
                          ),
                          if (cart.isNotEmpty)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                child: Text('${cart.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Kolom pencarian sushi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search sushi...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tombol kategori sushi (Sushi Roll, Sashimi, Nigiri)
            buildCategoryButtons(),
            const SizedBox(height: 16),

            // Grid menu sushi berdasarkan kategori yang dipilih
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) => buildMenuCard(items[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget halaman keranjang belanja
class CartPage extends StatefulWidget {
  // Menerima daftar item dari keranjang
  final List<SushiItem> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

// State dari halaman CartPage
class _CartPageState extends State<CartPage> {
  // Warna tema pink lembut
  final Color softPink = const Color(0xFFFF8A8A);

  // Mengurangi jumlah item dalam keranjang
  void removeItem(SushiItem item) {
    setState(() {
      item.quantity--;
      if (item.quantity <= 0) {
        widget.cartItems.remove(item);
      }
    });
  }

  // Menambah jumlah item dalam keranjang
  void addItem(SushiItem item) {
    setState(() {
      item.quantity++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hitung total harga semua item dalam keranjang
    int total = widget.cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,

      // Tampilkan pesan jika keranjang kosong
      body: widget.cartItems.isEmpty
          ? const Center(child: Text('Keranjang masih kosong'))

          // Tampilkan daftar item keranjang jika ada
          : Column(
              children: [
                // Daftar item keranjang
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (_, index) {
                      final item = widget.cartItems[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar item
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      item.imageAsset,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Nama dan harga item
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text('Rp ${item.price}',
                                            style: TextStyle(
                                                color: softPink,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Tombol jumlah item di pojok kanan bawah
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Row(
                                  children: [
                                    _minimalButton(Icons.remove, () => removeItem(item)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: Text('${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.w500)),
                                    ),
                                    _minimalButton(Icons.add, () => addItem(item), isAdd: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bagian bawah: total dan tombol checkout
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      )
                    ],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Teks total harga
                      RichText(
                        text: TextSpan(
                          text: 'Total\n',
                          style: const TextStyle(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: 'Rp $total',
                              style: TextStyle(
                                color: softPink,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                      // Tombol checkout
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutPage(orderItems: widget.cartItems),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: softPink,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text('Checkout', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Tombol kecil untuk menambah/mengurangi jumlah item
  Widget _minimalButton(IconData icon, VoidCallback onTap, {bool isAdd = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isAdd ? softPink : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isAdd ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

// Widget halaman checkout pesanan
class CheckoutPage extends StatefulWidget {
  // Menerima daftar item yang dipesan dari CartPage
  final List<SushiItem> orderItems;

  const CheckoutPage({super.key, required this.orderItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

// Future function untuk mengambil detail resep dari API berdasarkan idMeal
Future<Map<String, dynamic>> fetchRecipeDetail(String idMeal) async {
  final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$idMeal');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['meals'][0];
  } else {
    throw Exception('Gagal mengambil detail resep');
  }
}

// HALAMAN RESEP

// Widget halaman daftar resep sushi
class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

// State dari halaman RecipePage
class _RecipePageState extends State<RecipePage> {
  // Semua resep dan hasil filter resep
  List<Recipe> allRecipes = [];
  List<Recipe> filteredRecipes = [];

  // Controller untuk input pencarian
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ambil data resep dari API saat halaman dibuka
    fetchSushiRecipes().then((data) {
      setState(() {
        allRecipes = data;
        filteredRecipes = data;
      });
    });
  }

  // Fungsi untuk memfilter resep berdasarkan query pencarian
  void searchRecipe(String query) {
    setState(() {
      filteredRecipes = allRecipes
          .where((recipe) =>
              recipe.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul halaman
              const Text('Recipe',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Find your favorite sushi roll recipe.',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),

              // Kolom pencarian
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: searchRecipe,
                  decoration: const InputDecoration(
                    hintText: 'Type something...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grid resep sushi
              Expanded(
                child: filteredRecipes.isEmpty
                    ? const Center(child: Text('No recipes found'))

                    // Menampilkan grid resep
                    : GridView.builder(
                        itemCount: filteredRecipes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (_, index) {
                          final recipe = filteredRecipes[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigasi ke halaman detail resep saat diklik
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RecipeDetailPage(idMeal: recipe.id),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar resep
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16)),
                                    child: Image.network(
                                      recipe.thumbnail,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Judul dan deskripsi singkat
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Click for Detail',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Halaman Detail Resep
class RecipeDetailPage extends StatelessWidget {
  // ID resep yang dikirim saat navigasi
  final String idMeal;

  const RecipeDetailPage({super.key, required this.idMeal});

  // Warna tema pink lembut
  final Color softPink = const Color(0xFFFF8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Recipe Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      // Menggunakan FutureBuilder untuk mengambil detail resep dari API
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchRecipeDetail(idMeal),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat detail: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar makanan
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    data['strMealThumb'],
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),

                // Nama makanan
                Text(
                  data['strMeal'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Judul dan deskripsi instruksi memasak
                const Text(
                  'Cooking Instructions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['strInstructions'] ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ======================================================
// HALAMAN CHECKOUT PESANAN
class _CheckoutPageState extends State<CheckoutPage> {
  // Warna tema pink
  final Color softPink = const Color(0xFFFF8A8A);

  // Default metode pembayaran
  String selectedPayment = 'Tunai';

  // Total harga dari semua pesanan
  int get totalPrice => widget.orderItems.fold(
      0, (sum, item) => sum + item.price * item.quantity);

  // Navigasi ke halaman status pesanan
  void navigateToStatusPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderStatusPage(
          orders: widget.orderItems,
          paymentMethod: selectedPayment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Daftar item yang dipesan
            Expanded(
              child: ListView.builder(
                itemCount: widget.orderItems.length,
                itemBuilder: (context, index) {
                  final item = widget.orderItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item.imageAsset,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${item.quantity} x Rp ${item.price}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: Text(
                        'Rp ${item.quantity * item.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: softPink,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Pilihan metode pembayaran
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Chip pilihan metode pembayaran
                  Wrap(
                    spacing: 12,
                    children: ['Tunai', 'QRIS', 'Debit'].map((method) {
                      return ChoiceChip(
                        label: Text(method),
                        selected: selectedPayment == method,
                        selectedColor: softPink.withOpacity(0.2),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: selectedPayment == method ? softPink : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: selectedPayment == method ? softPink : Colors.transparent,
                          ),
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedPayment = method;
                          });
                        },
                      );
                    }).toList(),
                  )
                ],
              ),
            ),

            // Total dan tombol konfirmasi
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Teks total harga
                  RichText(
                    text: TextSpan(
                      text: 'Total:\n',
                      style: const TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Rp $totalPrice',
                          style: TextStyle(
                            fontSize: 16,
                            color: softPink,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  // Tombol konfirmasi pesanan
                  ElevatedButton(
                    onPressed: navigateToStatusPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softPink,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Konfirmasi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Status Pesanan
class OrderStatusPage extends StatefulWidget {
  // Menerima daftar pesanan dan metode pembayaran dari halaman checkout
  final List<SushiItem> orders;
  final String paymentMethod;

  const OrderStatusPage({
    super.key,
    required this.orders,
    required this.paymentMethod,
  });

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  // Warna tema utama
  final Color softPink = const Color(0xFFFF8A8A);

  @override
  void initState() {
    super.initState();
    // Simulasi update status pesanan menjadi "Selesai" setelah 5 detik
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        for (var item in widget.orders) {
          item.status = 'Selesai';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // AppBar halaman status
      appBar: AppBar(
        title: const Text('Status Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      // Konten utama halaman status
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan metode pembayaran yang dipilih
            Text('Metode Pembayaran: ${widget.paymentMethod}',
                style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 16),

            // Menampilkan daftar item pesanan beserta statusnya
            Expanded(
              child: ListView.builder(
                itemCount: widget.orders.length,
                itemBuilder: (_, index) {
                  final item = widget.orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(item.imageAsset,
                            width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      title: Text(item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Jumlah: ${item.quantity} | Status: ${item.status}',
                        style: TextStyle(
                          // Warna status akan berubah menjadi pink jika selesai, atau oranye jika belum
                          color: item.status == 'Selesai' ? softPink : Colors.orangeAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}