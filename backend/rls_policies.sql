-- LearnLynk Tech Test - Task 2: RLS Policies on leads

alter table public.leads enable row level security;

-- Example helper: assume JWT has tenant_id, user_id, role.
-- You can use: current_setting('request.jwt.claims', true)::jsonb

-- TODO: write a policy so:
-- - counselors see leads where they are owner_id OR in one of their teams
-- - admins can see all leads of their tenant

-- SELECT POLICY
-- Rules:
-- - Admins can read all leads of their tenant
-- - Counselors see:
--       • leads whe re they are owner_id
--       • leads owned by users in their teams


-- Example skeleton for SELECT (replace with your own logic):

create policy "leads_select_policy"
on public.leads
for select
using (
  -- TODO: add real RLS logic here, refer to README instructions

  -- Extract fields from JWT
    (current_setting('request.jwt.claims', true)::jsonb)->>'role' = 'admin'
    AND
    -- Tenant isolation (Admin sees all leads in his tenant)
    tenant_id = (current_setting('request.jwt.claims', true)::jsonb)->>'tenant_id'
  )
  OR
  (
    -- Counselor sees leads they own
    (current_setting('request.jwt.claims', true)::jsonb)->>'role' = 'counselor'
    AND
    owner_id = (current_setting('request.jwt.claims', true)::jsonb)->>'user_id'
  )
  OR
  (
    -- Counselor sees leads from any user in their team
    (current_setting('request.jwt.claims', true)::jsonb)->>'role' = 'counselor'
    AND
    exists (
      select 1
      from user_teams ut
      join user_teams ut2 on ut.team_id = ut2.team_id
      where
        ut.user_id = (current_setting('request.jwt.claims', true)::jsonb)->>'user_id'
        and ut2.user_id = leads.owner_id
    )
  )
)


-- TODO: add INSERT policy that:
-- - allows counselors/admins to insert leads for their tenant
-- - ensures tenant_id is correctly set/validated

-- INSERT POLICY
-- Rules:
-- - Admins and counselors can INSERT
-- - But only into their tenant
-- - Validates tenant_id from JWT to avoid cross-tenant insert

create policy "leads_insert_policy"
on public.leads
for insert
with check (
  (
    -- allow admin/counselor only
    (current_setting('request.jwt.claims', true)::jsonb)->>'role'
    in ('admin', 'counselor')
  )
  AND
  (
    -- enforce tenant isolation
    tenant_id = (current_setting('request.jwt.claims', true)::jsonb)->>'tenant_id'
  )
);
