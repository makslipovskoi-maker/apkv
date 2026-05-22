import 'package:flutter/material.dart';

import 'app.dart';
import 'services/offline_queue.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await OfflineQueue.instance.init();
  await SupabaseService.instance.initIfConfigured();

  runApp(const SanatoriumTripsApp());
}
