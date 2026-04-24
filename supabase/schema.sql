-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  firebase_uid TEXT,
  email TEXT,
  display_name TEXT DEFAULT '',
  gender INT DEFAULT -1,
  birth_date TIMESTAMPTZ,
  show_age BOOLEAN DEFAULT TRUE,
  picture_data TEXT DEFAULT '',
  approved_image INT DEFAULT 3,
  city TEXT DEFAULT '',
  country_code TEXT DEFAULT '',
  country TEXT DEFAULT '',
  region_name TEXT DEFAULT '',
  presence BOOLEAN DEFAULT FALSE,
  last_active TIMESTAMPTZ DEFAULT now(),
  current_room_chat_id UUID,
  fcm_token TEXT DEFAULT '',
  blocked_by TEXT[] DEFAULT '{}',
  image_reports TEXT[] DEFAULT '{}',
  bot_reports TEXT[] DEFAULT '{}',
  language_reports TEXT[] DEFAULT '{}',
  kvitter_credits INT DEFAULT 0,
  is_premium_user BOOLEAN DEFAULT FALSE,
  onboarding_completed BOOLEAN DEFAULT FALSE,
  is_admin BOOLEAN DEFAULT FALSE,
  search_array TEXT[] DEFAULT '{}',
  created TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_name TEXT DEFAULT '',
  chat_color INT DEFAULT 3253186,
  image_url TEXT DEFAULT '',
  country_code TEXT DEFAULT 'all',
  enabled BOOLEAN DEFAULT TRUE,
  info_key TEXT DEFAULT '',
  image_overflow INT DEFAULT 80,
  image_translation_x INT DEFAULT 0,
  last_message TEXT DEFAULT '',
  last_message_is_giphy BOOLEAN DEFAULT FALSE,
  last_message_by_name TEXT DEFAULT '',
  last_message_timestamp TIMESTAMPTZ DEFAULT now(),
  last_message_user_id UUID
);

CREATE TABLE IF NOT EXISTS private_chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  users TEXT[] DEFAULT '{}',
  created TIMESTAMPTZ DEFAULT now(),
  initiated_by UUID,
  initiated_by_user_name TEXT DEFAULT '',
  initiated_by_user_gender INT DEFAULT 0,
  initiated_by_picture_data TEXT DEFAULT '',
  chat_name TEXT DEFAULT '',
  other_user_id UUID,
  other_user_name TEXT DEFAULT '',
  other_user_gender INT DEFAULT 0,
  other_user_picture_data TEXT DEFAULT '',
  last_message TEXT DEFAULT '',
  last_message_is_giphy BOOLEAN DEFAULT FALSE,
  last_message_by_name TEXT DEFAULT '',
  last_message_timestamp TIMESTAMPTZ DEFAULT now(),
  last_message_user_id UUID,
  last_message_read_by TEXT[] DEFAULT '{}',
  send_push_to_user_id UUID
);

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID NOT NULL,
  is_private BOOLEAN DEFAULT FALSE,
  text TEXT DEFAULT '',
  chat_type INT DEFAULT 0,
  created_by_id UUID,
  created_by_name TEXT DEFAULT '',
  created_by_gender INT DEFAULT 0,
  created_by_country_code TEXT DEFAULT '',
  created_by_image_url TEXT DEFAULT '',
  approved_image INT DEFAULT 3,
  created TIMESTAMPTZ DEFAULT now(),
  birth_date TIMESTAMPTZ,
  show_age BOOLEAN DEFAULT TRUE,
  image_reports TEXT[] DEFAULT '{}',
  reply_id UUID,
  reply_text TEXT DEFAULT '',
  reply_chat_type INT DEFAULT 0,
  reply_created_by_id UUID,
  reply_created_by_name TEXT DEFAULT '',
  reply_created_by_gender INT DEFAULT 0,
  reply_created_by_country_code TEXT DEFAULT '',
  reply_created_by_image_url TEXT DEFAULT '',
  reply_approved_image INT DEFAULT 3,
  reply_created TIMESTAMPTZ,
  reply_birth_date TIMESTAMPTZ,
  reply_show_age BOOLEAN DEFAULT TRUE,
  reply_image_reports TEXT[] DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  message_id UUID,
  message_text TEXT,
  message_created TIMESTAMPTZ,
  message_created_by UUID,
  message_created_by_gender INT,
  message_created_by_country_code TEXT,
  message_created_by_image_url TEXT,
  message_created_by_display_name TEXT,
  reported_by UUID,
  reported_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS feedback (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  feedback TEXT,
  created_by_id UUID,
  created_by_name TEXT,
  created_by_country_code TEXT,
  created_by_country_name TEXT,
  created TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_messages_chat_created ON messages (chat_id, created DESC);
CREATE INDEX idx_messages_created_by ON messages (created_by_id);
CREATE INDEX idx_users_last_active ON users (last_active);
CREATE INDEX idx_users_approved_image ON users (approved_image);
CREATE INDEX idx_users_display_name ON users (display_name);
CREATE INDEX idx_private_chats_users ON private_chats USING GIN (users);
CREATE INDEX idx_chats_country_enabled ON chats (country_code, enabled);

-- ============================================
-- RPC FUNCTIONS
-- ============================================

CREATE OR REPLACE FUNCTION increment_credits(target_user_id UUID, amount INT)
RETURNS VOID AS $$
  UPDATE users SET kvitter_credits = kvitter_credits + amount WHERE id = target_user_id;
$$ LANGUAGE SQL SECURITY DEFINER;

-- ============================================
-- TRIGGERS
-- ============================================

-- Auto-delete private chat when users array has fewer than 2 entries
CREATE OR REPLACE FUNCTION delete_empty_private_chat()
RETURNS TRIGGER AS $$
BEGIN
  IF array_length(NEW.users, 1) IS NULL OR array_length(NEW.users, 1) < 2 THEN
    DELETE FROM messages WHERE chat_id = NEW.id;
    DELETE FROM private_chats WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_delete_empty_private_chat
  AFTER UPDATE ON private_chats
  FOR EACH ROW
  EXECUTE FUNCTION delete_empty_private_chat();

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE private_chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

-- Users: anyone authenticated can read, update own row only
CREATE POLICY "Users are viewable by authenticated users"
  ON users FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Users can update own record"
  ON users FOR UPDATE TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own record"
  ON users FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

-- Chats: readable by authenticated, writable by admins
CREATE POLICY "Chats are viewable by authenticated users"
  ON chats FOR SELECT TO authenticated
  USING (true);

-- Private chats: only participants
CREATE POLICY "Private chats visible to participants"
  ON private_chats FOR SELECT TO authenticated
  USING (auth.uid()::text = ANY(users));

CREATE POLICY "Private chats insertable by authenticated"
  ON private_chats FOR INSERT TO authenticated
  WITH CHECK (auth.uid()::text = ANY(users));

CREATE POLICY "Private chats updatable by participants"
  ON private_chats FOR UPDATE TO authenticated
  USING (auth.uid()::text = ANY(users));

-- Messages: readable based on chat access, insertable by authenticated
CREATE POLICY "Public messages viewable by authenticated"
  ON messages FOR SELECT TO authenticated
  USING (
    NOT is_private
    OR EXISTS (
      SELECT 1 FROM private_chats
      WHERE private_chats.id = messages.chat_id
      AND auth.uid()::text = ANY(private_chats.users)
    )
  );

CREATE POLICY "Messages insertable by authenticated"
  ON messages FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = created_by_id);

-- Reports: insert by authenticated, read by admins
CREATE POLICY "Reports insertable by authenticated"
  ON reports FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "Reports viewable by admins"
  ON reports FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.is_admin = true));

-- Feedback: insert by authenticated, read by admins
CREATE POLICY "Feedback insertable by authenticated"
  ON feedback FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "Feedback viewable by admins"
  ON feedback FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.is_admin = true));

-- ============================================
-- STORAGE BUCKETS
-- ============================================

INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('avatars', 'avatars', true, 2097152)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('chat-images', 'chat-images', true, 2097152)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "Avatar images are publicly accessible"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Users can delete own avatar"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Chat images are publicly accessible"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'chat-images');

CREATE POLICY "Authenticated users can upload chat images"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'chat-images');

-- ============================================
-- REALTIME
-- ============================================

ALTER PUBLICATION supabase_realtime ADD TABLE users;
ALTER PUBLICATION supabase_realtime ADD TABLE chats;
ALTER PUBLICATION supabase_realtime ADD TABLE private_chats;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
