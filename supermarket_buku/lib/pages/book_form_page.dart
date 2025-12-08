import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookFormPage extends StatefulWidget {
  final Map<String, dynamic>? bookData;
  const BookFormPage({super.key, this.bookData});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
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
        await Supabase.instance.client.from('books').insert(data);
      } else {
        await Supabase.instance.client.from('books').update(data).eq('id', widget.bookData!['id']);
      }

      if (mounted) {
        Navigator.pop(context, true);
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
      appBar: AppBar(title: Text(widget.bookData == null ? 'Tambah Inventaris Karel' : 'Edit Inventaris Karel')),
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
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN DATA KAREL'),
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
