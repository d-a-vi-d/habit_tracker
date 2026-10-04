-- ============================================================
-- RLS-Muster für Supabase (Referenz, wird NICHT automatisch ausgeführt)
-- Tabellen- und Spaltennamen sind Beispiele: durch die eigenen ersetzen.
--
-- Beispiel-Schema:
--   notes(id, user_id, group_id, ...)
--   groups(id, ...)
--   group_members(group_id, user_id, role)   -- role: 'admin' | 'member'
--   chats(id, ...)
--   chat_participants(chat_id, user_id)
-- ============================================================

-- Immer zuerst: RLS einschalten (ohne Policy darf dann niemand etwas)
alter table public.notes enable row level security;

-- Tipp 1: auth.uid() immer als (select auth.uid()) schreiben.
--         So wird es pro Abfrage einmal ausgewertet statt pro Zeile.
-- Tipp 2: Alle Spalten, die in Policies vorkommen, indizieren.
create index if not exists group_members_user_idx
  on public.group_members (user_id, group_id);


-- ------------------------------------------------------------
-- 1) Nur die eigenen Zeilen
-- ------------------------------------------------------------
create policy "own_rows" on public.notes
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
-- using      = welche Zeilen darf ich sehen/ändern/löschen
-- with check = welche Zeilen darf ich anlegen/so ändern


-- ------------------------------------------------------------
-- 2) Hilfsfunktionen statt wiederholtem EXISTS
--    security definer: läuft ohne RLS auf group_members.
--    Das verhindert Endlosrekursion, wenn eine Policy auf die
--    Mitgliedertabelle selbst zugreift. Funktion klein halten!
-- ------------------------------------------------------------
create or replace function public.is_group_member(gid uuid)
returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1
    from public.group_members gm
    where gm.group_id = gid
      and gm.user_id = (select auth.uid())
  );
$$;

create or replace function public.is_group_admin(gid uuid)
returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1
    from public.group_members gm
    where gm.group_id = gid
      and gm.user_id = (select auth.uid())
      and gm.role = 'admin'
  );
$$;

create or replace function public.is_chat_participant(cid uuid)
returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1
    from public.chat_participants cp
    where cp.chat_id = cid
      and cp.user_id = (select auth.uid())
  );
$$;


-- ------------------------------------------------------------
-- 3) Mitglieder der Gruppe dürfen lesen
-- ------------------------------------------------------------
create policy "members_read" on public.notes
  for select to authenticated
  using (public.is_group_member(group_id));


-- ------------------------------------------------------------
-- 4) Nur Admins der Gruppe dürfen schreiben
-- ------------------------------------------------------------
create policy "admins_write" on public.notes
  for all to authenticated
  using (public.is_group_admin(group_id))
  with check (public.is_group_admin(group_id));


-- ------------------------------------------------------------
-- 5) Admins der Gruppe ODER die Person selbst
-- ------------------------------------------------------------
create policy "admin_or_self" on public.notes
  for select to authenticated
  using (
    public.is_group_admin(group_id)
    or user_id = (select auth.uid())
  );


-- ------------------------------------------------------------
-- 6) Teilnehmer eines Chats sehen dessen Nachrichten
--    (messages(id, chat_id, user_id, text, ...))
-- ------------------------------------------------------------
-- create policy "participants_read" on public.messages
--   for select to authenticated
--   using (public.is_chat_participant(chat_id));
