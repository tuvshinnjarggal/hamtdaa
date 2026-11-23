-- Хамтдаа: хэрэглэгчдийн санал болгосон асуулт / шийтгэл
-- Supabase → SQL Editor дээр нэг удаа хуулж "Run" дарна.

create table if not exists public.community_prompts (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  category    text not null check (category in ('Найзууд','Хосууд','Шивнээ','Хэн нь вэ?','Шийтгэл')),
  text        text not null check (char_length(btrim(text)) between 5 and 220),
  game        text check (game is null or char_length(game) <= 40),
  mood        text check (mood is null or char_length(mood) <= 40),
  user_id     uuid default auth.uid(),          -- нэвтэрсэн бол автоматаар, үгүй бол null
  status      text not null default 'new' check (status in ('new','approved','rejected'))
);

alter table public.community_prompts enable row level security;

-- Хэн ч (нэвтрээгүй ч) зөвхөн шинэ мөр нэмж чадна. status-ийг өөрөө 'approved' болгож чадахгүй.
drop policy if exists "anyone can suggest" on public.community_prompts;
create policy "anyone can suggest"
  on public.community_prompts
  for insert
  to anon, authenticated
  with check (status = 'new' and (user_id is null or user_id = auth.uid()));

-- SELECT / UPDATE / DELETE policy байхгүй = сайтаас хэн ч уншиж, засаж чадахгүй.
-- Та Supabase Dashboard → Table Editor-оос (админ эрхээр) бүгдийг харж, status-ийг өөрчилнө.

grant insert on public.community_prompts to anon, authenticated;
