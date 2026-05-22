import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  SupabaseClient? _client;

  SupabaseClient get client {
    final current = _client;
    if (current == null) {
      throw StateError(
        'Supabase не настроен. Укажите SUPABASE_URL и SUPABASE_ANON_KEY.',
      );
    }
    return current;
  }

  bool get isConfigured => _client != null;

  Future<void> initIfConfigured() async {
    if (!AppConfig.isConfigured) return;

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }
}
