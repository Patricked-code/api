begin;

insert into af_ref.currencies(code,name,symbol,minor_unit,is_active) values
('EUR','Euro','€',2,true),
('MAD','Dirham marocain','د.م.',2,true),
('USD','Dollar américain','$',2,true),
('XOF','Franc CFA BCEAO','F CFA',0,true)
on conflict (code) do update set name=excluded.name,symbol=excluded.symbol,minor_unit=excluded.minor_unit,is_active=excluded.is_active;

insert into af_ref.geographies(code,name,geography_type,parent_id,iso2,iso3,default_currency_id,metadata)
values ('AFRICA','Afrique','CONTINENT',null,null,null,null,'{}'::jsonb)
on conflict (code) do update set name=excluded.name,geography_type=excluded.geography_type;

insert into af_ref.geographies(code,name,geography_type,parent_id,metadata)
select v.code,v.name,'REGION',a.id,'{}'::jsonb
from (values
 ('NORTH_AFRICA','Afrique du Nord'),
 ('WEST_AFRICA','Afrique de l’Ouest'),
 ('EAST_AFRICA','Afrique de l’Est'),
 ('CENTRAL_AFRICA','Afrique centrale'),
 ('SOUTHERN_AFRICA','Afrique australe')
) v(code,name)
join af_ref.geographies a on a.code='AFRICA'
on conflict (code) do update set name=excluded.name,parent_id=excluded.parent_id;

insert into af_ref.geographies(code,name,geography_type,parent_id,iso2,iso3,default_currency_id,metadata)
select 'MAR','Maroc','COUNTRY',r.id,'MA','MAR',c.id,'{}'::jsonb
from af_ref.geographies r join af_ref.currencies c on c.code='MAD'
where r.code='NORTH_AFRICA'
on conflict (code) do update set name=excluded.name,parent_id=excluded.parent_id,iso2=excluded.iso2,iso3=excluded.iso3,default_currency_id=excluded.default_currency_id;

insert into af_ref.geographies(code,name,geography_type,parent_id,default_currency_id,metadata)
select 'UEMOA','UEMOA','MONETARY_ZONE',r.id,c.id,
       '{"member_countries":["BEN","BFA","CIV","GNB","MLI","NER","SEN","TGO"]}'::jsonb
from af_ref.geographies r join af_ref.currencies c on c.code='XOF'
where r.code='WEST_AFRICA'
on conflict (code) do update set name=excluded.name,parent_id=excluded.parent_id,default_currency_id=excluded.default_currency_id,metadata=excluded.metadata;

insert into af_ref.geography_memberships(child_geography_id,parent_geography_id,membership_type,valid_from)
select c.id,p.id,'GEOGRAPHIC','1900-01-01'::date
from (values
 ('NORTH_AFRICA','AFRICA'),('WEST_AFRICA','AFRICA'),('EAST_AFRICA','AFRICA'),
 ('CENTRAL_AFRICA','AFRICA'),('SOUTHERN_AFRICA','AFRICA'),
 ('MAR','NORTH_AFRICA'),('UEMOA','WEST_AFRICA')
) v(child_code,parent_code)
join af_ref.geographies c on c.code=v.child_code
join af_ref.geographies p on p.code=v.parent_code
on conflict do nothing;

insert into af_ref.asset_classes(code,name,sort_order) values
('EQUITY','Actions',10),('BOND','Obligations',20),('MONEY_MARKET','Monétaire',30),('BALANCED','Diversifiés',40)
on conflict (code) do update set name=excluded.name,sort_order=excluded.sort_order;

insert into af_org.organizations(organization_type,legal_name,display_name,country_id,website_url,status)
select v.organization_type,v.legal_name,v.display_name,g.id,v.website_url,'ACTIVE'
from (values
 ('REGULATOR','Autorité Marocaine du Marché des Capitaux','AMMC','MAR','https://www.ammc.ma'),
 ('CENTRAL_BANK','Bank Al-Maghrib','Bank Al-Maghrib','MAR','https://www.bkam.ma'),
 ('EXCHANGE','Bourse de Casablanca','Bourse de Casablanca','MAR','https://www.casablanca-bourse.com'),
 ('STATISTICS_INSTITUTE','Haut-Commissariat au Plan','HCP','MAR','https://www.hcp.ma'),
 ('DEBT_AGENCY','Direction du Trésor et des Finances Extérieures','DTFE','MAR','https://www.finances.gov.ma'),
 ('REGULATOR','Autorité des Marchés Financiers de l’UMOA','AMF-UMOA','UEMOA','https://www.amf-umoa.org'),
 ('CENTRAL_BANK','Banque Centrale des États de l’Afrique de l’Ouest','BCEAO','UEMOA','https://www.bceao.int'),
 ('EXCHANGE','Bourse Régionale des Valeurs Mobilières','BRVM','UEMOA','https://www.brvm.org'),
 ('DEBT_AGENCY','UMOA-Titres','UMOA-Titres','UEMOA','https://www.umoatitres.org')
) v(organization_type,legal_name,display_name,geo_code,website_url)
join af_ref.geographies g on g.code=v.geo_code
on conflict do nothing;

insert into af_org.organization_geography_roles(organization_id,geography_id,role_code,valid_from,is_primary)
select o.id,g.id,v.role_code,'1900-01-01'::date,true
from (values
 ('AMMC','MAR','REGULATOR'),('Bank Al-Maghrib','MAR','CENTRAL_BANK'),
 ('Bourse de Casablanca','MAR','EXCHANGE'),('HCP','MAR','STATISTICS_INSTITUTE'),
 ('DTFE','MAR','DEBT_AGENCY'),('AMF-UMOA','UEMOA','REGULATOR'),
 ('BCEAO','UEMOA','CENTRAL_BANK'),('BRVM','UEMOA','EXCHANGE'),
 ('UMOA-Titres','UEMOA','DEBT_AGENCY')
) v(org_name,geo_code,role_code)
join af_org.organizations o on o.display_name=v.org_name
join af_ref.geographies g on g.code=v.geo_code
on conflict do nothing;

insert into af_source.source_endpoints(organization_id,geography_id,source_code,source_name,data_domain,url,access_method,format_hint,frequency,parser_key,is_active,priority)
select o.id,g.id,v.source_code,v.source_name,v.data_domain,v.url,'HTTP',v.format_hint,v.frequency,v.parser_key,true,v.priority
from (values
 ('Bank Al-Maghrib','MAR','MAR_MONIA','MONIA','RATE','https://www.bkam.ma/en/Markets/Key-indicators/Money-market/Monia-index-moroccan-overnight-index-average','HTML','DAILY','bam_monia',10),
 ('DTFE','MAR','MAR_TREASURY_RATES','Bons du Trésor Maroc','RATE','https://www.finances.gov.ma','HTML_PDF_XLSX','WEEKLY','maroc_treasury_rates',20),
 ('Bourse de Casablanca','MAR','MAR_MASI','MASI et indices officiels','INDEX','https://www.casablanca-bourse.com','HTML_CSV_XLSX','DAILY','casablanca_indices',10),
 ('HCP','MAR','MAR_CPI','IPC Maroc','INFLATION','https://www.hcp.ma','HTML_XLSX_PDF','MONTHLY','hcp_cpi',20),
 ('BCEAO','UEMOA','UEMOA_BCEAO_RATES','Taux BCEAO et interbancaire','RATE','https://www.bceao.int','HTML_XLSX_PDF','DAILY_WEEKLY','bceao_rates',10),
 ('UMOA-Titres','UEMOA','UEMOA_TITRES','Adjudications BAT/OAT','AUCTION','https://www.umoatitres.org','HTML_PDF_XLSX','WEEKLY','umoatitres_auctions',10),
 ('BRVM','UEMOA','UEMOA_BRVM_INDICES','Indices BRVM','INDEX','https://www.brvm.org','HTML_CSV_XLSX','DAILY','brvm_indices',10)
) v(org_name,geo_code,source_code,source_name,data_domain,url,format_hint,frequency,parser_key,priority)
join af_org.organizations o on o.display_name=v.org_name
join af_ref.geographies g on g.code=v.geo_code
on conflict (source_code) do update set source_name=excluded.source_name,url=excluded.url,format_hint=excluded.format_hint,frequency=excluded.frequency,parser_key=excluded.parser_key,is_active=true,priority=excluded.priority;

insert into af_market.official_indices(code,name,provider_organization_id,geography_id,asset_class_id,currency_id,return_type,status)
select v.code,v.name,o.id,g.id,a.id,c.id,v.return_type,'ACTIVE'
from (values
 ('MASI','MASI','Bourse de Casablanca','MAR','MAD','PRICE'),
 ('MASI_GTR','MASI Return Gross','Bourse de Casablanca','MAR','MAD','GROSS_TOTAL_RETURN'),
 ('BRVM_COMPOSITE','BRVM Composite','BRVM','UEMOA','XOF','PRICE'),
 ('BRVM_COMPOSITE_TR','BRVM Composite Total Return','BRVM','UEMOA','XOF','GROSS_TOTAL_RETURN')
) v(code,name,provider_name,geo_code,currency_code,return_type)
join af_org.organizations o on o.display_name=v.provider_name
join af_ref.geographies g on g.code=v.geo_code
join af_ref.asset_classes a on a.code='EQUITY'
join af_ref.currencies c on c.code=v.currency_code
on conflict (code) do update set name=excluded.name,return_type=excluded.return_type,status='ACTIVE';

insert into af_market.official_rate_series(code,name,provider_organization_id,geography_id,currency_id,rate_type,tenor_label,tenor_days,day_count_convention,compounding_convention,unit,frequency,is_reference_index,status)
select v.code,v.name,o.id,g.id,c.id,v.rate_type,v.tenor_label,v.tenor_days,v.day_count,v.compounding,'PERCENT',v.frequency,v.is_reference,'ACTIVE'
from (values
 ('MAR_MONIA_ON','MONIA Overnight','Bank Al-Maghrib','MAR','MAD','OVERNIGHT','ON',1,'ACT/365','SIMPLE','DAILY',true),
 ('MAR_TBILL_13W','Maroc Bon du Trésor 13 semaines','DTFE','MAR','MAD','TREASURY_BILL','13W',91,'ACT/365','SIMPLE','WEEKLY',false),
 ('MAR_TBILL_26W','Maroc Bon du Trésor 26 semaines','DTFE','MAR','MAD','TREASURY_BILL','26W',182,'ACT/365','SIMPLE','WEEKLY',false),
 ('MAR_TBILL_52W','Maroc Bon du Trésor 52 semaines','DTFE','MAR','MAD','TREASURY_BILL','52W',364,'ACT/365','SIMPLE','WEEKLY',false),
 ('UEMOA_BCEAO_1W','BCEAO Refinancement 1 semaine','BCEAO','UEMOA','XOF','REFINANCING','1W',7,'ACT/360','SIMPLE','WEEKLY',false),
 ('UEMOA_BAT_3M','UEMOA BAT 3 mois','UMOA-Titres','UEMOA','XOF','TREASURY_BILL','3M',91,'ACT/360','SIMPLE','WEEKLY',false),
 ('UEMOA_BAT_6M','UEMOA BAT 6 mois','UMOA-Titres','UEMOA','XOF','TREASURY_BILL','6M',182,'ACT/360','SIMPLE','WEEKLY',false),
 ('UEMOA_BAT_12M','UEMOA BAT 12 mois','UMOA-Titres','UEMOA','XOF','TREASURY_BILL','12M',364,'ACT/360','SIMPLE','WEEKLY',false)
) v(code,name,provider_name,geo_code,currency_code,rate_type,tenor_label,tenor_days,day_count,compounding,frequency,is_reference)
join af_org.organizations o on o.display_name=v.provider_name
join af_ref.geographies g on g.code=v.geo_code
join af_ref.currencies c on c.code=v.currency_code
on conflict (code) do update set name=excluded.name,tenor_label=excluded.tenor_label,tenor_days=excluded.tenor_days,status='ACTIVE';

insert into af_method.methodologies(code,name,methodology_type,description,status) values
('AF_BOND_BUCKETS','AfricaFunds Bond Maturity Buckets','MATURITY_BUCKETS','Règles d’affectation par maturité résiduelle.','ACTIVE'),
('AF_CATEGORY_INDEX','AfricaFunds Category Index','CATEGORY_INDEX','Indice de catégorie construit à partir des rendements des fonds éligibles.','ACTIVE'),
('AF_GEOGRAPHIC_AGGREGATION','AfricaFunds Geographic Aggregation','REGIONAL_AGGREGATION','Agrégation nationale, régionale et Afrique en EUR/USD.','ACTIVE'),
('AF_MONEY_MARKET_INDEX','AfricaFunds Money Market Index','MARKET_INDEX','Indice monétaire capitalisé à partir de taux officiels.','ACTIVE'),
('AF_PLATFORM_BENCHMARK','AfricaFunds Platform Benchmark','PLATFORM_BENCHMARK','Benchmark combinant référence de marché et indice réel de catégorie.','ACTIVE'),
('AF_REAL_INDEX','AfricaFunds Real Category Index','REAL_CATEGORY_INDEX','Indice de catégorie corrigé de l’inflation.','ACTIVE')
on conflict (code) do update set name=excluded.name,methodology_type=excluded.methodology_type,description=excluded.description,status=excluded.status;

insert into af_method.methodology_versions(methodology_id,version,valid_from,status,parameters)
select m.id,'1.0.0','2026-01-01'::date,'ACTIVE',v.parameters::jsonb
from (values
 ('AF_BOND_BUCKETS','{"basis":"RESIDUAL_MATURITY_DAYS"}'),
 ('AF_CATEGORY_INDEX','{"weighting":"EQUAL_PORTFOLIO","stale_nav_days":7,"min_coverage_ratio":0.6,"deduplicate_share_classes":true}'),
 ('AF_GEOGRAPHIC_AGGREGATION','{"weighting":"HYBRID","aum_weight":0.6,"country_cap":0.4,"equal_weight":0.1,"market_weight":0.3}'),
 ('AF_MONEY_MARKET_INDEX','{"base_value":1000,"rate_selection":"REFERENCE_THEN_SHORT_TREASURY","day_count_default":"ACT/365"}'),
 ('AF_PLATFORM_BENCHMARK','{"rebalance":"MONTHLY","real_category_weight":0.5,"official_component_weight":0.5}'),
 ('AF_REAL_INDEX','{"fallback":"LAST_AVAILABLE_CPI","inflation_method":"DAILY_INTERPOLATED_CPI"}')
) v(code,parameters)
join af_method.methodologies m on m.code=v.code
on conflict (methodology_id,version) do update set parameters=excluded.parameters,status='ACTIVE';

insert into af_method.maturity_bucket_rules(methodology_version_id,bucket_code,min_days_exclusive,max_days_inclusive,priority)
select mv.id,v.bucket_code,v.min_days_exclusive,v.max_days_inclusive,v.priority
from (values
 ('MONEY_MARKET',-1,365,10),('BOND_CT',365,1095,20),('BOND_MT',1095,2555,30),('BOND_LT',2555,null::integer,40)
) v(bucket_code,min_days_exclusive,max_days_inclusive,priority)
join af_method.methodologies m on m.code='AF_BOND_BUCKETS'
join af_method.methodology_versions mv on mv.methodology_id=m.id and mv.version='1.0.0'
on conflict do nothing;

insert into af_ref.category_nodes(code,name,level,asset_class_id,geography_id,currency_id,currency_context,parent_category_id,is_active,valid_from)
select v.code,v.name,v.level,a.id,g.id,c.id,v.currency_context,null,true,'2026-01-01'::date
from (values
 ('BOND_MAR_LOCAL','Obligations Maroc',4,'BOND','MAR','MAD','LOCAL'),
 ('BOND_UEMOA_LOCAL','Obligations UEMOA',4,'BOND','UEMOA','XOF','LOCAL'),
 ('EQUITY_AFRICA_EUR','Actions Afrique EUR',2,'EQUITY','AFRICA','EUR','EUR'),
 ('EQUITY_AFRICA_USD','Actions Afrique USD',2,'EQUITY','AFRICA','USD','USD'),
 ('EQUITY_MAR_LOCAL','Actions Maroc',4,'EQUITY','MAR','MAD','LOCAL'),
 ('EQUITY_NORTH_AFRICA_EUR','Actions Afrique du Nord EUR',3,'EQUITY','NORTH_AFRICA','EUR','EUR'),
 ('EQUITY_NORTH_AFRICA_USD','Actions Afrique du Nord USD',3,'EQUITY','NORTH_AFRICA','USD','USD'),
 ('EQUITY_UEMOA_LOCAL','Actions UEMOA',4,'EQUITY','UEMOA','XOF','LOCAL'),
 ('EQUITY_WEST_AFRICA_EUR','Actions Afrique de l’Ouest EUR',3,'EQUITY','WEST_AFRICA','EUR','EUR'),
 ('EQUITY_WEST_AFRICA_USD','Actions Afrique de l’Ouest USD',3,'EQUITY','WEST_AFRICA','USD','USD'),
 ('MM_AFRICA_EUR','Monétaire Afrique EUR',2,'MONEY_MARKET','AFRICA','EUR','EUR'),
 ('MM_AFRICA_USD','Monétaire Afrique USD',2,'MONEY_MARKET','AFRICA','USD','USD'),
 ('MM_MAR_LOCAL','Monétaire Maroc',4,'MONEY_MARKET','MAR','MAD','LOCAL'),
 ('MM_NORTH_AFRICA_EUR','Monétaire Afrique du Nord EUR',3,'MONEY_MARKET','NORTH_AFRICA','EUR','EUR'),
 ('MM_NORTH_AFRICA_USD','Monétaire Afrique du Nord USD',3,'MONEY_MARKET','NORTH_AFRICA','USD','USD'),
 ('MM_UEMOA_LOCAL','Monétaire UEMOA',4,'MONEY_MARKET','UEMOA','XOF','LOCAL'),
 ('MM_WEST_AFRICA_EUR','Monétaire Afrique de l’Ouest EUR',3,'MONEY_MARKET','WEST_AFRICA','EUR','EUR'),
 ('MM_WEST_AFRICA_USD','Monétaire Afrique de l’Ouest USD',3,'MONEY_MARKET','WEST_AFRICA','USD','USD')
) v(code,name,level,asset_code,geo_code,currency_code,currency_context)
join af_ref.asset_classes a on a.code=v.asset_code
join af_ref.geographies g on g.code=v.geo_code
join af_ref.currencies c on c.code=v.currency_code
on conflict (code) do update set name=excluded.name,level=excluded.level,asset_class_id=excluded.asset_class_id,geography_id=excluded.geography_id,currency_id=excluded.currency_id,currency_context=excluded.currency_context,is_active=true;

update af_ref.category_nodes c set parent_category_id=p.id
from (values
 ('EQUITY_MAR_LOCAL','EQUITY_NORTH_AFRICA_EUR'),('EQUITY_UEMOA_LOCAL','EQUITY_WEST_AFRICA_EUR'),
 ('MM_MAR_LOCAL','MM_NORTH_AFRICA_EUR'),('MM_UEMOA_LOCAL','MM_WEST_AFRICA_EUR')
) v(child_code,parent_code)
join af_ref.category_nodes p on p.code=v.parent_code
where c.code=v.child_code;

insert into af_calc.index_definitions(code,name,index_type,asset_class_id,category_id,geography_id,currency_id,geography_level,base_date,base_value,methodology_version_id,status,is_published,metadata)
select v.code,v.name,v.index_type,a.id,cat.id,g.id,c.id,v.geo_level,'2026-01-01'::date,1000,mv.id,'ACTIVE',false,v.metadata::jsonb
from (values
 ('AF_MM_AFRICA_CATEGORY_EUR','AfricaFunds Africa Money Market Funds Category Index EUR','CATEGORY_INDEX','MM_AFRICA_EUR','AFRICA','EUR','AFRICA','AF_GEOGRAPHIC_AGGREGATION','{}'),
 ('AF_MM_AFRICA_CATEGORY_USD','AfricaFunds Africa Money Market Funds Category Index USD','CATEGORY_INDEX','MM_AFRICA_USD','AFRICA','USD','AFRICA','AF_GEOGRAPHIC_AGGREGATION','{}'),
 ('AF_MM_MAR_CATEGORY_MAD','AfricaFunds Morocco Money Market Funds Category Index MAD','CATEGORY_INDEX','MM_MAR_LOCAL','MAR','MAD','NATIONAL','AF_CATEGORY_INDEX','{}'),
 ('AF_MM_MAR_MARKET_MAD','AfricaFunds Morocco Money Market Index MAD','MARKET_INDEX','MM_MAR_LOCAL','MAR','MAD','NATIONAL','AF_MONEY_MARKET_INDEX','{"source_rate_codes":["MAR_MONIA_ON","MAR_TBILL_13W","MAR_TBILL_26W","MAR_TBILL_52W"]}'),
 ('AF_MM_MAR_PLATFORM_MAD','AfricaFunds Morocco Money Market Platform Benchmark MAD','PLATFORM_BENCHMARK','MM_MAR_LOCAL','MAR','MAD','NATIONAL','AF_PLATFORM_BENCHMARK','{}'),
 ('AF_MM_MAR_REAL_MAD','AfricaFunds Morocco Money Market Real Category Index MAD','REAL_CATEGORY_INDEX','MM_MAR_LOCAL','MAR','MAD','NATIONAL','AF_REAL_INDEX','{}'),
 ('AF_MM_NORTH_AFRICA_CATEGORY_EUR','AfricaFunds North Africa Money Market Funds Category Index EUR','CATEGORY_INDEX','MM_NORTH_AFRICA_EUR','NORTH_AFRICA','EUR','REGIONAL','AF_GEOGRAPHIC_AGGREGATION','{}'),
 ('AF_MM_NORTH_AFRICA_CATEGORY_USD','AfricaFunds North Africa Money Market Funds Category Index USD','CATEGORY_INDEX','MM_NORTH_AFRICA_USD','NORTH_AFRICA','USD','REGIONAL','AF_GEOGRAPHIC_AGGREGATION','{}'),
 ('AF_MM_UEMOA_CATEGORY_XOF','AfricaFunds UEMOA Money Market Funds Category Index XOF','CATEGORY_INDEX','MM_UEMOA_LOCAL','UEMOA','XOF','ZONE','AF_CATEGORY_INDEX','{}'),
 ('AF_MM_UEMOA_MARKET_XOF','AfricaFunds UEMOA Money Market Index XOF','MARKET_INDEX','MM_UEMOA_LOCAL','UEMOA','XOF','ZONE','AF_MONEY_MARKET_INDEX','{"source_rate_codes":["UEMOA_BCEAO_1W","UEMOA_BAT_3M","UEMOA_BAT_6M","UEMOA_BAT_12M"]}'),
 ('AF_MM_UEMOA_PLATFORM_XOF','AfricaFunds UEMOA Money Market Platform Benchmark XOF','PLATFORM_BENCHMARK','MM_UEMOA_LOCAL','UEMOA','XOF','ZONE','AF_PLATFORM_BENCHMARK','{}'),
 ('AF_MM_UEMOA_REAL_XOF','AfricaFunds UEMOA Money Market Real Category Index XOF','REAL_CATEGORY_INDEX','MM_UEMOA_LOCAL','UEMOA','XOF','ZONE','AF_REAL_INDEX','{}'),
 ('AF_MM_WEST_AFRICA_CATEGORY_EUR','AfricaFunds West Africa Money Market Funds Category Index EUR','CATEGORY_INDEX','MM_WEST_AFRICA_EUR','WEST_AFRICA','EUR','REGIONAL','AF_GEOGRAPHIC_AGGREGATION','{}'),
 ('AF_MM_WEST_AFRICA_CATEGORY_USD','AfricaFunds West Africa Money Market Funds Category Index USD','CATEGORY_INDEX','MM_WEST_AFRICA_USD','WEST_AFRICA','USD','REGIONAL','AF_GEOGRAPHIC_AGGREGATION','{}')
) v(code,name,index_type,category_code,geo_code,currency_code,geo_level,methodology_code,metadata)
join af_ref.asset_classes a on a.code='MONEY_MARKET'
join af_ref.category_nodes cat on cat.code=v.category_code
join af_ref.geographies g on g.code=v.geo_code
join af_ref.currencies c on c.code=v.currency_code
join af_method.methodologies m on m.code=v.methodology_code
join af_method.methodology_versions mv on mv.methodology_id=m.id and mv.version='1.0.0'
on conflict (code) do update set name=excluded.name,index_type=excluded.index_type,category_id=excluded.category_id,geography_id=excluded.geography_id,currency_id=excluded.currency_id,geography_level=excluded.geography_level,methodology_version_id=excluded.methodology_version_id,status='ACTIVE',metadata=excluded.metadata;

insert into af_calc.index_components(index_definition_id,component_type,rate_series_id,static_weight,valid_from)
select i.id,'RATE_SERIES',r.id,0.25,'2026-01-01'::date
from (values
 ('AF_MM_MAR_MARKET_MAD','MAR_MONIA_ON'),('AF_MM_MAR_MARKET_MAD','MAR_TBILL_13W'),
 ('AF_MM_MAR_MARKET_MAD','MAR_TBILL_26W'),('AF_MM_MAR_MARKET_MAD','MAR_TBILL_52W'),
 ('AF_MM_UEMOA_MARKET_XOF','UEMOA_BCEAO_1W'),('AF_MM_UEMOA_MARKET_XOF','UEMOA_BAT_3M'),
 ('AF_MM_UEMOA_MARKET_XOF','UEMOA_BAT_6M'),('AF_MM_UEMOA_MARKET_XOF','UEMOA_BAT_12M')
) v(index_code,rate_code)
join af_calc.index_definitions i on i.code=v.index_code
join af_market.official_rate_series r on r.code=v.rate_code
where not exists(select 1 from af_calc.index_components x where x.index_definition_id=i.id and x.rate_series_id=r.id and x.valid_from='2026-01-01');

insert into af_calc.index_components(index_definition_id,component_type,component_index_id,static_weight,valid_from)
select i.id,'CALCULATED_INDEX',ci.id,v.weight,'2026-01-01'::date
from (values
 ('AF_MM_MAR_PLATFORM_MAD','AF_MM_MAR_MARKET_MAD',0.5::numeric),
 ('AF_MM_MAR_PLATFORM_MAD','AF_MM_MAR_REAL_MAD',0.5::numeric),
 ('AF_MM_UEMOA_PLATFORM_XOF','AF_MM_UEMOA_MARKET_XOF',0.5::numeric),
 ('AF_MM_UEMOA_PLATFORM_XOF','AF_MM_UEMOA_REAL_XOF',0.5::numeric)
) v(index_code,component_code,weight)
join af_calc.index_definitions i on i.code=v.index_code
join af_calc.index_definitions ci on ci.code=v.component_code
where not exists(select 1 from af_calc.index_components x where x.index_definition_id=i.id and x.component_index_id=ci.id and x.valid_from='2026-01-01');

commit;
