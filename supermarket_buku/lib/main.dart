import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qoglgacnosbvsergulgn.supabase.co',
    anonKey: 'sb_secret_oIF-O-cGclr7FCcHlyBTVw_x9Y8p3g-',
  );

  runApp(const MyApp());
}
