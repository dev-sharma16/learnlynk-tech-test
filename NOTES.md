## Notes & Assumptions

- The edge function uses the Supabase service role key, assuming it is stored securely in the environment and never exposed to the client.
- The `tenant_id` inserted inside the edge function is placeholder logic; in a real system it would come from the authenticated user or application context.
- Date filtering for “tasks due today” is done client-side using ISO date ranges, which works consistently across time zones.
- RLS policies assume that the JWT contains `user_id`, `role`, and `tenant_id`, as described in the test instructions.
- Team-based access uses a `user_teams` table with the assumption that it is already created and populated.
- Schema constraints (task type, due_at >= created_at) enforce business rules at the database layer, preventing bad data.
- Stripe written answer assumes a standard Checkout Session flow with webhooks enabled in LIVE or TEST mode.