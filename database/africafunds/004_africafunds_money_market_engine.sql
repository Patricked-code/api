begin;

create or replace function af_calc.calculate_money_market_index(p_index_code text, p_date_from date, p_date_to date)
returns integer
language plpgsql
set search_path = af_calc, af_market, af_ops, af_method, af_ref, pg_catalog
as $$
declare
  v_idx af_calc.index_definitions%rowtype;
  v_run uuid;
  v_date date;
  v_prev_level numeric;
  v_daily_rate numeric;
  v_daily_return numeric;
  v_level numeric;
  v_count integer;
  v_inserted integer := 0;
begin
  select * into v_idx from af_calc.index_definitions where code=p_index_code;
  if not found or v_idx.index_type <> 'MARKET_INDEX' then
    raise exception 'Index % introuvable ou non MARKET_INDEX', p_index_code;
  end if;

  insert into af_ops.calculation_runs(calculation_type,methodology_version_id,date_from,date_to,status,started_at,input_snapshot)
  values('MONEY_MARKET_INDEX',v_idx.methodology_version_id,p_date_from,p_date_to,'RUNNING',now(),jsonb_build_object('index_code',p_index_code))
  returning id into v_run;

  select level into v_prev_level
  from af_calc.index_daily_values
  where index_definition_id=v_idx.id and valuation_date<p_date_from and is_current
  order by valuation_date desc limit 1;
  v_prev_level := coalesce(v_prev_level,v_idx.base_value);

  for v_date in select generate_series(p_date_from,p_date_to,interval '1 day')::date loop
    select avg(r.rate_value),count(*) into v_daily_rate,v_count
    from af_calc.index_components c
    join af_market.official_rate_observations r on r.rate_series_id=c.rate_series_id and r.is_current
    where c.index_definition_id=v_idx.id
      and (c.valid_from is null or c.valid_from<=v_date)
      and (c.valid_to is null or c.valid_to>=v_date)
      and r.observation_date=(select max(r2.observation_date)
                              from af_market.official_rate_observations r2
                              where r2.rate_series_id=r.rate_series_id
                                and r2.is_current and r2.observation_date<=v_date);

    if v_count>0 and v_daily_rate is not null then
      v_daily_return := (v_daily_rate/100.0)/365.0;
      v_level := v_prev_level*(1+v_daily_return);
      update af_calc.index_daily_values set is_current=false
      where index_definition_id=v_idx.id and valuation_date=v_date and is_current;
      insert into af_calc.index_daily_values(
        index_definition_id,valuation_date,level,daily_return,currency_id,
        constituent_count,eligible_count,coverage_ratio,quality_score,
        calculation_run_id,methodology_version_id,is_current,revision_number,metadata)
      values(
        v_idx.id,v_date,v_level,v_daily_return,v_idx.currency_id,
        v_count,v_count,1,case when v_count>=2 then 1 else 0.75 end,
        v_run,v_idx.methodology_version_id,true,
        coalesce((select max(revision_number)+1 from af_calc.index_daily_values
                  where index_definition_id=v_idx.id and valuation_date=v_date),1),
        jsonb_build_object('annual_rate_percent',v_daily_rate,'day_count',365));
      v_prev_level:=v_level;
      v_inserted:=v_inserted+1;
    end if;
  end loop;

  update af_ops.calculation_runs
  set status='COMPLETED',completed_at=now(),output_metrics=jsonb_build_object('rows',v_inserted)
  where id=v_run;
  return v_inserted;
exception when others then
  if v_run is not null then
    update af_ops.calculation_runs set status='FAILED',completed_at=now(),error_message=sqlerrm where id=v_run;
  end if;
  raise;
end;
$$;

commit;
