-- Raw events (4,295,584) minus duplicate purchase events (335) must equal 4,295,249.
select count(*) as row_count
from {{ ref('stg_events') }}
having count(*) != 4295249
