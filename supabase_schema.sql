-- 링크 테트리스: Supabase SQL Editor에서 전체 실행
-- Auth 사용자 생성 시 profiles 행을 자동 생성합니다.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null check (char_length(nickname) between 2 and 16),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists profiles_nickname_lower_uq
  on public.profiles (lower(nickname));

create table if not exists public.game_scores (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  score integer not null check (score >= 0),
  result text not null check (result in ('win', 'loss')),
  created_at timestamptz not null default now()
);

create index if not exists game_scores_created_score_idx
  on public.game_scores (created_at desc, score desc);
create index if not exists game_scores_user_created_idx
  on public.game_scores (user_id, created_at desc);

-- 신규 Auth 계정에 기본 닉네임을 생성합니다. 이메일 가입은 입력한 닉네임을 사용합니다.
create or replace function public.handle_new_tetris_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  chosen_nickname text;
begin
  chosen_nickname := coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'nickname'), ''),
    'user_' || substr(replace(new.id::text, '-', ''), 1, 7)
  );

  insert into public.profiles (id, nickname)
  values (new.id, chosen_nickname);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_tetris on auth.users;
create trigger on_auth_user_created_tetris
after insert on auth.users
for each row execute function public.handle_new_tetris_user();

create or replace function public.set_tetris_profile_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists tetris_profiles_updated_at on public.profiles;
create trigger tetris_profiles_updated_at
before update on public.profiles
for each row execute function public.set_tetris_profile_updated_at();

alter table public.profiles enable row level security;
alter table public.game_scores enable row level security;

-- 프로필은 랭킹 화면에서 닉네임을 표시하므로 공개 조회를 허용합니다.
drop policy if exists "Public can read tetris profiles" on public.profiles;
create policy "Public can read tetris profiles"
on public.profiles for select
to anon, authenticated
using (true);

drop policy if exists "Users can create own tetris profile" on public.profiles;
create policy "Users can create own tetris profile"
on public.profiles for insert
to authenticated
with check ((select auth.uid()) = id);

drop policy if exists "Users can update own tetris profile" on public.profiles;
create policy "Users can update own tetris profile"
on public.profiles for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

-- 랭킹 점수는 모두 조회 가능하지만, 로그인한 본인 점수만 추가할 수 있습니다.
drop policy if exists "Public can read tetris scores" on public.game_scores;
create policy "Public can read tetris scores"
on public.game_scores for select
to anon, authenticated
using (true);

drop policy if exists "Users can insert own tetris scores" on public.game_scores;
create policy "Users can insert own tetris scores"
on public.game_scores for insert
to authenticated
with check ((select auth.uid()) = user_id);

grant select on public.profiles to anon, authenticated;
grant insert, update on public.profiles to authenticated;
grant select on public.game_scores to anon, authenticated;
grant insert on public.game_scores to authenticated;
