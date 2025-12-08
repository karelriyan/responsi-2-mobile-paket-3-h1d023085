import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- BAGIAN 1: SETUP SUPABASE ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚠️ PENTING: Ganti URL dan KEY ini dengan punya kamu sendiri dari Dashboard Supabase!
  await Supabase.initialize(
    url: 'https://qoglgacnosbvsergulgn.supabase.co',
    anonKey: 'sb_secret_oIF-O-cGclr7FCcHlyBTVw_x9Y8p3g-',
  );

  runApp(const MyApp());
}

// --- BAGIAN 2: TEMA & NAVIGASI UTAMA ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsi 2 Mobile Paket 3 (NIM_KAMU)', // Ganti NIM-mu
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Wajib Warna Coklat 
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFEFEBE9), // Coklat muda banget biar manis
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      // Cek status login: Kalau belum login ke LoginPage, kalau sudah ke HomePage
      home: Supabase.instance.client.auth.currentUser == null
          ? const LoginPage()
          : const HomePage(),
    );
  }
}

// --- BAGIAN 3: HALAMAN LOGIN & REGISTER  ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false; // Toggle untuk mode Register/Login

  // Fungsi Auth (Login/Register jadi satu biar praktis)
  Future<void> _authenticate() async {
    setState(() => _isLoading = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_isRegistering) {
        // Register
        await auth.signUp(email: _emailCtrl.text, password: _passwordCtrl.text);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')));
        setState(() => _isRegistering = false); // Balik ke mode login
      } else {
        // Login
        await auth.signInWithPassword(email: _emailCtrl.text, password: _passwordCtrl.text);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book, size: 64, color: Colors.brown),
                  const SizedBox(height: 16),
                  Text(_isRegistering ? 'Daftar Akun' : 'Login Inventaris', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown)),
                  const SizedBox(height: 24),
                  TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
                  const SizedBox(height: 16),
                  TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _authenticate,
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isRegistering ? 'DAFTAR' : 'MASUK'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isRegistering = !_isRegistering),
                    child: Text(_isRegistering ? 'Sudah punya akun? Login' : 'Belum punya akun? Daftar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- BAGIAN 4: HOMEPAGE (LIST BUKU)  ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Stream untuk mendengarkan perubahan data secara real-time dari Supabase
  final _booksStream = Supabase.instance.client.from('books').stream(primaryKey: ['id']).order('id');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wajib menggunakan nama di Action Bar [cite: 6]
      appBar: AppBar(
        title: const Text('Inventaris Buku Abimart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _booksStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final books = snapshot.data!;
          if (books.isEmpty) return const Center(child: Text('Belum ada data buku.'));

          return ListView.builder(
            itemCount: books.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.brown,
                    child: Text(book['title'][0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(book['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rp ${book['price']} | Stok: ${book['amount']} | Penulis: ${book['author']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookFormPage(bookData: book))),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBook(book['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookFormPage())),
      ),
    );
  }

  Future<void> _deleteBook(int id) async {
    try {
      await Supabase.instance.client.from('books').delete().eq('id', id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buku dihapus')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
    }
  }
}

// --- BAGIAN 5: HALAMAN FORM (TAMBAH & EDIT) [cite: 10, 12-19] ---
class BookFormPage extends StatefulWidget {
  final Map<String, dynamic>? bookData; // Kalau null berarti mode Tambah, kalau ada isi berarti Edit
  const BookFormPage({super.key, this.bookData});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk semua field wajib 
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _volumeCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _publisherCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Jika mode edit, isi form dengan data lama
    if (widget.bookData != null) {
      final data = widget.bookData!;
      _titleCtrl.text = data['title'];
      _priceCtrl.text = data['price'].toString();
      _amountCtrl.text = data['amount'].toString();
      _dateCtrl.text = data['entry_date'];
      _volumeCtrl.text = data['volume'].toString();
      _authorCtrl.text = data['author'];
      _publisherCtrl.text = data['publisher'];
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Data yang akan dikirim ke Supabase
      final data = {
        'title': _titleCtrl.text,
        'price': int.parse(_priceCtrl.text),
        'amount': int.parse(_amountCtrl.text),
        'entry_date': _dateCtrl.text,
        'volume': int.parse(_volumeCtrl.text),
        'author': _authorCtrl.text,
        'publisher': _publisherCtrl.text,
      };

      if (widget.bookData == null) {
        // Create (Insert)
        await Supabase.instance.client.from('books').insert(data);
      } else {
        // Update
        await Supabase.instance.client.from('books').update(data).eq('id', widget.bookData!['id']);
      }

      if (mounted) {
        Navigator.pop(context); // Kembali ke halaman utama
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menyimpan data!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookData == null ? 'Tambah Inventaris' : 'Edit Inventaris')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField('Judul Buku', _titleCtrl),
              Row(
                children: [
                  Expanded(child: _buildField('Harga (Angka)', _priceCtrl, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Jumlah (Angka)', _amountCtrl, isNumber: true)),
                ],
              ),
              _buildField('Tanggal Masuk (YYYY-MM-DD)', _dateCtrl),
              _buildField('Volume (Angka)', _volumeCtrl, isNumber: true),
              _buildField('Penulis', _authorCtrl),
              _buildField('Penerbit', _publisherCtrl),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBook,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN DATA'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }
}