# Implementation status

This file prevents demo behaviour from being mistaken for production data.

## Ready and validated

- Next.js 16 + TypeScript production build.
- Mobile-first `/demo` experience.
- Interactive Leaflet map with route and numbered store stops.
- Deterministic store-subset and travel-cost optimiser.
- Car and bike profiles, maximum stores/radius and bike capacity constraints.
- Expired-promotion filtering and price-confidence warnings.
- Unit tests for core optimiser decisions.
- Structured menu-planning endpoint.
- Normalised Prisma models for profiles, menus, products, prices, promotions,
  shopping plans and store visits.
- Existing accounts, shared lists, invitation, QR, Pusher and Stripe code.
- Lazy rate-limit initialisation so builds/local demo work without Upstash.
- Zero known production dependency vulnerabilities at handoff audit.

## Working with configuration

- Google sign-in.
- PostgreSQL persistence.
- Anthropic menu generation.
- Nearby store discovery through Overpass.
- openrouteservice road geometry.
- Database-backed price comparison.
- Pusher, Resend, Upstash and Stripe.

## Demonstration only

- Prices, promotions and three named stores shown on `/demo`.
- The demo menu is deterministic reference content.
- The demo route connects stops visually; the signed-in route endpoint supplies
  road-following geometry when its key is configured.

## Not implemented yet

- Live retailer-specific API/feed adapters.
- Scheduled import workers and retailer monitoring.
- Persistent planner flow from AI menu through final shopping plan.
- Production-grade GTIN/SKU/fuzzy product matching.
- Loyalty-card and multi-buy eligibility handling.
- Real route matrix inside the combinatorial optimiser.
- Pantry inventory UI.
- Dietitian-reviewed nutrition policy and nutrition database integration.
- GDPR product work: consent copy, retention/deletion screens and DPA review.
- End-to-end tests with PostgreSQL and external-service mocks.

## Known architectural boundary

“All nearby stores” means all nearby branches for which SmartCart has lawful,
usable and sufficiently fresh product data. Store locations alone do not imply
price coverage. The UI must show coverage and missing data rather than claim a
universal comparison.

