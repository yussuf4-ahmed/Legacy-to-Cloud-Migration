{% snapshot snsh_patients %}

{{
    config(
      target_schema='snapshots',
      unique_key='patient_id',
      strategy='check',
      check_cols=['insurance'],
    )
}}

select * from {{ source('bronze', 'patients') }}

{% endsnapshot %}
