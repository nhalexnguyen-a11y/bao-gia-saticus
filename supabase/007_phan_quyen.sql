-- Phân quyền theo cấp của GOR (bảng profiles.role):
--   Mọi tài khoản GOR: xem thư viện, tạo và xuất báo giá.
--   Super Admin, Admin, Manager: thêm/sửa model, mục mẫu và đoạn mẫu.
--   Super Admin, Admin: xóa model, quản lý dòng máy & hãng, cài đặt (cài đặt đã giới hạn từ trước).
--   Chỉ Super Admin duyệt model. Manager thêm hoặc sửa model thì model về trạng thái chờ duyệt.
--   CTO/COO và User: chỉ xem và báo giá.

-- quote_products
drop policy if exists quote_products_insert on public.quote_products;
drop policy if exists quote_products_update on public.quote_products;
drop policy if exists quote_products_delete on public.quote_products;
create policy quote_products_insert on public.quote_products for insert
  with check (public.get_my_role()::text in ('super_admin', 'admin', 'manager'));
create policy quote_products_update on public.quote_products for update
  using (public.get_my_role()::text in ('super_admin', 'admin', 'manager'))
  with check (public.get_my_role()::text in ('super_admin', 'admin', 'manager'));
create policy quote_products_delete on public.quote_products for delete
  using (public.get_my_role()::text in ('super_admin', 'admin'));

-- quote_taxonomy: ai cũng xem, Super Admin/Admin sửa
drop policy if exists quote_taxonomy_all on public.quote_taxonomy;
drop policy if exists quote_taxonomy_select on public.quote_taxonomy;
drop policy if exists quote_taxonomy_write on public.quote_taxonomy;
create policy quote_taxonomy_select on public.quote_taxonomy for select
  using (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));
create policy quote_taxonomy_write on public.quote_taxonomy for all
  using (public.get_my_role()::text in ('super_admin', 'admin'))
  with check (public.get_my_role()::text in ('super_admin', 'admin'));

-- quote_snippets: ai cũng xem, Super Admin/Admin/Manager sửa
drop policy if exists quote_snippets_all on public.quote_snippets;
drop policy if exists quote_snippets_select on public.quote_snippets;
drop policy if exists quote_snippets_write on public.quote_snippets;
create policy quote_snippets_select on public.quote_snippets for select
  using (exists (select 1 from public.profiles pr where pr.id = (select auth.uid())));
create policy quote_snippets_write on public.quote_snippets for all
  using (public.get_my_role()::text in ('super_admin', 'admin', 'manager'))
  with check (public.get_my_role()::text in ('super_admin', 'admin', 'manager'));

-- Duyệt: chỉ Super Admin; Manager lưu thì về chờ duyệt
create or replace function public.quote_guard_approve() returns trigger
language plpgsql set search_path = public as $$
declare r text := coalesce(public.get_my_role()::text, '');
begin
  if r = 'manager' then new.status := 'draft'; end if;
  if tg_op = 'UPDATE' and old.status = 'draft' and new.status = 'approved' and r <> 'super_admin' then
    raise exception 'Chỉ Super Admin duyệt được model.';
  end if;
  return new;
end $$;
drop trigger if exists quote_products_guard_approve on public.quote_products;
create trigger quote_products_guard_approve before insert or update on public.quote_products
  for each row execute function public.quote_guard_approve();
