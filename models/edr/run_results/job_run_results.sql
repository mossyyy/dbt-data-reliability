{{
  config(
    materialized = 'view',
    bind=False
  )
}}
with jobs as (
  select
    job_name,
    job_id,
    job_run_id,
    min({{ elementary.cast_as_timestamp(run_started_at) }}) as job_run_started_at,
    max({{ elementary.cast_as_timestamp(run_completed_at) }}) as job_run_completed_at,
    {{ elementary.timediff("second", "job_run_started_at", "job_run_completed_at") }} as job_run_execution_time
  from {{ ref('dbt_invocations') }}
  group by name, id, run_id
)

select
  job_name as name,
  job_id as id,
  job_run_id as run_id,
  job_run_started_at as run_started_at,
  job_run_completed_at as run_completed_at,
  job_run_execution_time as run_execution_time
from jobs
