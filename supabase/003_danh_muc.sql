-- Danh mục dòng máy và hãng, tạo riêng; khi nhập model chỉ chọn từ danh mục.
-- Chỉ tạo mới bảng quote_taxonomy; không đụng bảng của GOR.

create table if not exists public.quote_taxonomy (
  id          text primary key default gen_random_uuid()::text,
  kind        text not null check (kind in ('category','brand')),   -- category = dòng máy, brand = hãng
  name        text not null check (length(btrim(name)) > 0),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create unique index if not exists quote_taxonomy_kind_name on public.quote_taxonomy (kind, lower(name));

alter table public.quote_taxonomy enable row level security;
drop policy if exists quote_taxonomy_all on public.quote_taxonomy;
create policy quote_taxonomy_all on public.quote_taxonomy for all to authenticated
  using (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())))
  with check (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));
grant select, insert, update, delete on public.quote_taxonomy to authenticated;

drop trigger if exists quote_taxonomy_touch on public.quote_taxonomy;
create trigger quote_taxonomy_touch before update on public.quote_taxonomy for each row execute function public.quote_touch_updated_at();

do $$ begin
  begin alter publication supabase_realtime add table public.quote_taxonomy; exception when others then null; end;
end $$;

-- Đưa sẵn các dòng máy và hãng đang dùng trong thư viện
insert into public.quote_taxonomy (kind, name)
select distinct 'category', btrim(name) from public.quote_products where btrim(coalesce(name, '')) <> ''
on conflict (kind, lower(name)) do nothing;
insert into public.quote_taxonomy (kind, name)
select distinct 'brand', btrim(maker) from public.quote_products where btrim(coalesce(maker, '')) <> ''
on conflict (kind, lower(name)) do nothing;
