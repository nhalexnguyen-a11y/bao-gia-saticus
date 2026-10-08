-- Chỉ Super Admin được duyệt model (chuyển status từ 'draft' sang 'approved').
create or replace function public.quote_guard_approve() returns trigger
language plpgsql set search_path = public as $$
begin
  if old.status = 'draft' and new.status = 'approved'
     and coalesce(public.get_my_role()::text, '') <> 'super_admin' then
    raise exception 'Chỉ Super Admin duyệt được model.';
  end if;
  return new;
end $$;
drop trigger if exists quote_products_guard_approve on public.quote_products;
create trigger quote_products_guard_approve before update on public.quote_products
  for each row execute function public.quote_guard_approve();
