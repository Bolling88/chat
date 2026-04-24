import 'package:supabase_flutter/supabase_flutter.dart';

String getUserId() => Supabase.instance.client.auth.currentUser!.id;
