-- Báo giá SatiCus: thêm vào project Supabase của Alex workspace.
-- Chỉ TẠO MỚI 2 bảng quote_products, quote_settings; không sửa bảng hay chính sách có sẵn.
-- Chạy một lần trong Supabase > SQL Editor.

create table if not exists public.quote_products (
  id          text primary key default gen_random_uuid()::text,
  name        text not null,
  model       text default '',
  code        text default '',
  maker       text default '',
  origin      text default '',
  sections    jsonb not null default '[]'::jsonb,   -- [{title, lines[]}]
  scope       jsonb not null default '[]'::jsonb,   -- [{code, text, qty}]
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  updated_by  uuid default auth.uid() references auth.users(id) on delete set null
);

create table if not exists public.quote_settings (
  id          text primary key,                     -- một dòng: 'company'
  data        jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);

alter table public.quote_products enable row level security;
alter table public.quote_settings enable row level security;

-- Mọi tài khoản có hồ sơ trong Alex workspace: xem, thêm, sửa, xóa máy
create policy quote_products_select on public.quote_products for select to authenticated
  using (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));
create policy quote_products_insert on public.quote_products for insert to authenticated
  with check (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));
create policy quote_products_update on public.quote_products for update to authenticated
  using (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())))
  with check (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));
create policy quote_products_delete on public.quote_products for delete to authenticated
  using (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));

-- Cài đặt báo giá: ai đăng nhập cũng đọc; chỉ admin và super_admin được sửa
create policy quote_settings_select on public.quote_settings for select to authenticated
  using (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));
create policy quote_settings_insert on public.quote_settings for insert to authenticated
  with check (public.get_my_role() = any (array['super_admin','admin']::user_role[]));
create policy quote_settings_update on public.quote_settings for update to authenticated
  using (public.get_my_role() = any (array['super_admin','admin']::user_role[]))
  with check (public.get_my_role() = any (array['super_admin','admin']::user_role[]));

create or replace function public.quote_touch_updated_at() returns trigger
language plpgsql set search_path = public as $$
begin new.updated_at = now(); if tg_table_name = 'quote_products' then new.updated_by = auth.uid(); end if; return new; end $$;
create trigger quote_products_touch before update on public.quote_products for each row execute function public.quote_touch_updated_at();
create trigger quote_settings_touch before update on public.quote_settings for each row execute function public.quote_touch_updated_at();

-- Đồng bộ trực tiếp giữa các máy đang mở ứng dụng
do $$ begin
  begin alter publication supabase_realtime add table public.quote_products; exception when others then null; end;
  begin alter publication supabase_realtime add table public.quote_settings; exception when others then null; end;
end $$;
