-- CTO/COO có quyền như Admin trong thư viện báo giá (chỉ các bảng quote_*, không đổi quyền trong GOR).
alter policy quote_products_insert on public.quote_products
  with check (public.get_my_role()::text in ('super_admin', 'admin', 'cto_coo', 'manager'));
alter policy quote_products_update on public.quote_products
  using (public.get_my_role()::text in ('super_admin', 'admin', 'cto_coo', 'manager'))
  with check (public.get_my_role()::text in ('super_admin', 'admin', 'cto_coo', 'manager'));
alter policy quote_products_delete on public.quote_products
  using (public.get_my_role()::text in ('super_admin', 'admin', 'cto_coo'));
alter policy quote_taxonomy_write on public.quote_taxonomy
  using (public.get_my_role()::text in ('super_admin', 'admin', 'cto_coo'))
  with check (public.get_my_role()::text in ('super_admin', 'admin', 'cto_coo'));
alter policy quote_snippets_write on public.quote_snippets
  using (public.get_my_role()::text in ('super_admin', 'admin', 'cto_coo', 'manager'))
  with check (public.get_my_role()::text in ('super_admin', 'admin', 'cto_coo', 'manager'));
alter policy quote_settings_insert on public.quote_settings
  with check (public.get_my_role()::text in ('super_admin', 'admin', 'cto_coo'));
alter policy quote_settings_update on public.quote_settings
  using (public.get_my_role()::text in ('super_admin', 'admin', 'cto_coo'))
  with check (public.get_my_role()::text in ('super_admin', 'admin', 'cto_coo'));
