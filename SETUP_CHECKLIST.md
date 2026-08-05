# Setup checklist

## Local development

- [ ] Node 20.9 or newer installed.
- [ ] `.env.example` copied to `.env.local`.
- [ ] `DATABASE_URL`, `NEXTAUTH_SECRET` and app URLs filled in.
- [ ] `npm install` completed.
- [ ] `npm run db:generate` completed.
- [ ] `npm run db:migrate -- --name initial` completed.
- [ ] `/demo` opens without credentials.
- [ ] `npm run type-check`, `npm run lint`, `npm test` and `npm run build` pass.

## Accounts and AI

- [ ] Google OAuth client created with local and production callback URLs.
- [ ] `ANTHROPIC_API_KEY` and an available `ANTHROPIC_MODEL` configured.
- [ ] Menu responses are schema-validated before persistence.

## Maps and routes

- [ ] `OPENROUTESERVICE_API_KEY` configured.
- [ ] Production tile provider selected; URL and attribution configured.
- [ ] Store discovery is cached/persisted instead of repeatedly querying Overpass.

## Retail data

- [ ] Data rights and retailer coverage confirmed.
- [ ] Provider adapter implemented server-side.
- [ ] Scheduled sync and monitoring running.
- [ ] Price freshness rules configured.
- [ ] Product matching and uncertain-match review tested.
- [ ] Expired promotions are removed even after a failed import.

## Optional services

- [ ] Pusher for real-time shared lists.
- [ ] Upstash for production rate limiting.
- [ ] Resend for invitation email.
- [ ] Stripe products, prices, portal and signed webhook.

## Production

- [ ] Fresh secrets generated; no development key reused.
- [ ] `HSTS_ENABLED=true` only after HTTPS is verified.
- [ ] Database migrations deployed before traffic.
- [ ] GDPR/privacy work signed off.
- [ ] Backups, logging, alerting and rollback tested.

