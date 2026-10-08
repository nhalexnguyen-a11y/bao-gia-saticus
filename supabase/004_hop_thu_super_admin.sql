-- Hộp thư nhập liệu chỉ dành cho Super Admin: xem, gửi, sửa, xóa.
drop policy if exists quote_inbox_select on public.quote_inbox;
drop policy if exists quote_inbox_insert on public.quote_inbox;
drop policy if exists quote_inbox_update on public.quote_inbox;
drop policy if exists quote_inbox_delete on public.quote_inbox;
create policy quote_inbox_select on public.quote_inbox for select to authenticated
  using (public.get_my_role() = 'super_admin'::user_role);
create policy quote_inbox_insert on public.quote_inbox for insert to authenticated
  with check (public.get_my_role() = 'super_admin'::user_role);
create policy quote_inbox_update on public.quote_inbox for update to authenticated
  using (public.get_my_role() = 'super_admin'::user_role)
  with check (public.get_my_role() = 'super_admin'::user_role);
create policy quote_inbox_delete on public.quote_inbox for delete to authenticated
  using (public.get_my_role() = 'super_admin'::user_role);
