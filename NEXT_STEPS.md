# Next steps

Read `DEVELOPER_HANDOFF.md` and `IMPLEMENTATION_STATUS.md` before starting.

## P0 — required for real comparisons

1. Select a lawful retailer or grocery-data provider.
2. Implement its adapter using `lib/pricing/provider.ts`.
3. Add scheduled sync workers and idempotent writes to `Store`, `Product`,
   `StorePrice` and `Promotion`.
4. Add sync monitoring and automatic freshness downgrades.
5. Connect the signed-in planner flow to persisted menu and shopping-plan data.

## P1 — product quality

1. Add GTIN/SKU product matching and a manual-review queue.
2. Use a real route matrix in the optimiser, not a Haversine road factor.
3. Add loyalty-card and multi-buy conditions.
4. Add pantry inventory and “already at home” subtraction.
5. Add dietitian-reviewed nutrition rules and an authoritative nutrition source.

## P2 — launch readiness

1. PostgreSQL integration tests and external-provider contract tests.
2. GDPR consent, data export, deletion and retention implementation.
3. Production tile provider, routing quotas and caching.
4. Billing, webhook and rate-limit load tests.
5. Observability for price coverage, freshness, failed syncs and optimiser gaps.

