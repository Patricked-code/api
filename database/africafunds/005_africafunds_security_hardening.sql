begin;

create or replace function af_ops.set_updated_at()
returns trigger
language plpgsql
set search_path = af_ops, pg_catalog
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

revoke all on function af_calc.calculate_money_market_index(text,date,date) from public, anon, authenticated;
revoke all on function af_calc.fx_rate_on(uuid,uuid,date) from public, anon, authenticated;
revoke all on function af_calc.safe_return(numeric,numeric) from public, anon;
grant execute on function af_calc.safe_return(numeric,numeric) to authenticated;

commit;
