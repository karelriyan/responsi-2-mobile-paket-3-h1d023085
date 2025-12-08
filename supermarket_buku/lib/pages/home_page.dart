import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'book_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<List<Map<String, dynamic>>> _booksStream;

  @override
  void initState() {
    super.initState();
    _booksStream = _createStream();
  }

  Stream<List<Map<String, dynamic>>> _createStream() {
    return Supabase.instance.client.from('books').stream(primaryKey: ['id']).order('id');
  }

  void _refreshList() {
    setState(() {
      _booksStream = _createStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaris Buku Karel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
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
                        onPressed: () async {
                          final changed = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BookFormPage(bookData: book)),
                          );
                          if (changed == true) _refreshList();
                        },
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
        onPressed: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookFormPage()),
          );
          if (changed == true) _refreshList();
        },
      ),
    );
  }

  Future<void> _deleteBook(int id) async {
    try {
      await Supabase.instance.client.from('books').delete().eq('id', id);
      if (mounted) {
        _refreshList();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buku dihapus')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
    }
  }
}
