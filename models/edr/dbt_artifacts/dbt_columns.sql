{{
  config(
    materialized = 'view' if not var('sync', false) else 'table',
  )
}}

with dbt_models_data as (
    select
        database_name,
        schema_name,
        alias as table_name
    from {{ ref('dbt_models') }}
),

dbt_snapshots_data as (
    select
        database_name,
        schema_name,
        alias as table_name
    from {{ ref('dbt_snapshots') }}
),

dbt_sources_data as (
    select
        database_name,
        schema_name,
        name as table_name
    from {{ ref('dbt_sources') }}
),

dbt_seeds_data as (
    select
        database_name,
        schema_name,
        name as table_name
    from {{ ref('dbt_seeds') }}
),

tables_information as (
    select * from dbt_models_data
    union all
    select * from dbt_sources_data
    union all
    select * from dbt_snapshots_data
    union all
    select * from dbt_seeds_data
),

columns_information as (
    {{ elementary.get_columns_in_project() }}
),

dbt_columns as (
    select col_info.*
    from tables_information tbl_info
    join columns_information col_info
        on (lower(tbl_info.database_name) = lower(col_info.database_name) and
            lower(tbl_info.schema_name) = lower(col_info.schema_name) and
            lower(tbl_info.table_name) = lower(col_info.table_name)
        )
)

select *
from dbt_columns
