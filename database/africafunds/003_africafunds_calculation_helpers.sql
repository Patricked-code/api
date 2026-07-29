begin;

create or replace function af_calc.safe_return(p_current numeric, p_previous numeric)
returns numeric
language sql
immutable
set search_path = af_calc, pg_catalog
as $$
  select case when p_current is null or p_previous is null or p_previous = 0 then null
              else (p_current / p_previous) - 1 end;
$$;

create or replace function af_calc.fx_rate_on(p_base_currency_id uuid, p_quote_currency_id uuid, p_date date)
returns numeric
language sql
stable
set search_path = af_calc, af_market, pg_catalog
as $$
  select case
    when p_base_currency_id = p_quote_currency_id then 1::numeric
    else coalesce(
      (select f.rate from af_market.fx_observations f
       where f.base_currency_id=p_base_currency_id and f.quote_currency_id=p_quote_currency_id
         and f.observation_date<=p_date and f.is_current
       order by f.observation_date desc limit 1),
      (select 1/f.rate from af_market.fx_observations f
       where f.base_currency_id=p_quote_currency_id and f.quote_currency_id=p_base_currency_id
         and f.observation_date<=p_date and f.is_current and f.rate<>0
       order by f.observation_date desc limit 1)
    )
  end;
$$;

commit;
