-- Nâng cấp phần nhập model: trạng thái duyệt, đoạn mẫu dùng chung, hộp thư nhập liệu.
-- Chỉ tạo mới / thêm cột cho các bảng quote_*; không đụng bảng của GOR.

-- 1. Trạng thái model: draft = chờ duyệt (chưa được đưa vào báo giá), approved = dùng được
alter table public.quote_products add column if not exists status text not null default 'approved';
alter table public.quote_products add column if not exists source text not null default '';
do $$ begin
  alter table public.quote_products add constraint quote_products_status_chk check (status in ('draft','approved'));
exception when duplicate_object then null; end $$;

-- 2. Đoạn mẫu dùng chung (mô tả kỹ thuật hoặc mục cấu hình)
create table if not exists public.quote_snippets (
  id          text primary key default gen_random_uuid()::text,
  kind        text not null check (kind in ('body','scope')),
  title       text not null,
  content     text not null default '',              -- kind = body: văn bản, dòng '#' là tiêu đề mục
  items       jsonb not null default '[]'::jsonb,    -- kind = scope: [{code, text, qty}]
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  updated_by  uuid default auth.uid() references auth.users(id) on delete set null
);
alter table public.quote_snippets enable row level security;
drop policy if exists quote_snippets_all on public.quote_snippets;
create policy quote_snippets_all on public.quote_snippets for all to authenticated
  using (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())))
  with check (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));
grant select, insert, update, delete on public.quote_snippets to authenticated;

-- 3. Hộp thư nhập liệu: chỉ lưu CHỮ trích từ catalog PDF (trích ngay trên trình duyệt), không lưu file gốc.
--    Claude đọc chữ, tạo model nháp, rồi xóa text_content để không tốn dung lượng.
create table if not exists public.quote_inbox (
  id            text primary key default gen_random_uuid()::text,
  file_name     text not null default '',
  note          text not null default '',            -- yêu cầu của người gửi
  hint_name     text not null default '',            -- dòng máy gợi ý
  hint_maker    text not null default '',            -- hãng gợi ý
  text_content  text not null default '' check (length(text_content) <= 400000),  -- chữ trích từ PDF, tối đa ~400 KB
  pages         int  not null default 0,
  status        text not null default 'new' check (status in ('new','done','failed')),
  result        text not null default '',            -- ghi chú kết quả xử lý
  product_ids   jsonb not null default '[]'::jsonb,
  created_by    uuid default auth.uid() references auth.users(id) on delete set null,
  created_by_name text not null default '',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
alter table public.quote_inbox enable row level security;
drop policy if exists quote_inbox_select on public.quote_inbox;
drop policy if exists quote_inbox_insert on public.quote_inbox;
drop policy if exists quote_inbox_update on public.quote_inbox;
drop policy if exists quote_inbox_delete on public.quote_inbox;
create policy quote_inbox_select on public.quote_inbox for select to authenticated
  using (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));
create policy quote_inbox_insert on public.quote_inbox for insert to authenticated
  with check (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));
create policy quote_inbox_update on public.quote_inbox for update to authenticated
  using (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())))
  with check (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));
-- Xóa: người gửi xóa được yêu cầu của mình; admin xóa được mọi yêu cầu
create policy quote_inbox_delete on public.quote_inbox for delete to authenticated
  using (created_by = (select auth.uid()) or public.get_my_role() = any (array['super_admin','admin']::user_role[]));
grant select, insert, update, delete on public.quote_inbox to authenticated;

create or replace function public.quote_touch_updated_at() returns trigger
language plpgsql set search_path = public as $$
begin
  new.updated_at = now();
  if tg_table_name in ('quote_products','quote_snippets') then new.updated_by = auth.uid(); end if;
  return new;
end $$;
drop trigger if exists quote_snippets_touch on public.quote_snippets;
create trigger quote_snippets_touch before update on public.quote_snippets for each row execute function public.quote_touch_updated_at();
drop trigger if exists quote_inbox_touch on public.quote_inbox;
create trigger quote_inbox_touch before update on public.quote_inbox for each row execute function public.quote_touch_updated_at();

do $$ begin
  begin alter publication supabase_realtime add table public.quote_snippets; exception when others then null; end;
  begin alter publication supabase_realtime add table public.quote_inbox; exception when others then null; end;
end $$;
