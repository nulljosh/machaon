# Machaon Money

How Machaon makes money. The company plan is `REVENUE.md` in the Code root; the ledger is `GTM.md`.

## Price and rail

Free on the App Store (ASC 6785764864) and free on the web. The CSV export is a $1 one-time unlock on the web through Stripe Checkout (`functions/api/stripe.js`; the webhook writes `pro:<userId>`). A $1 Stripe sale pays about $0.67 after fees.

## What is actually sold

The CSV export of the dose log. Tracking itself is free. The log is the person's own data, and the export is theirs to take out of the app as a file.

## Who pays and why

A person who tracks substances and medicines for harm reduction and wants their log as a file. Tracking is free so the habit forms. The export is what a serious user pays for.

## Cost to serve

No paid AI. Stripe takes its fee per sale and nothing else is billed per use. Sync data sits in Cloudflare KV on Pages. Accounts run on Supabase (the shared spark project), which the code does not cap.

## Where we are

- 2026-06-28: Terms checkbox and GitHub sign-in added (repo notes).
- 2026-08-06: Stripe secrets were deliberately left unset on Cloudflare, so the $1 unlock does not work until they are set. Not rechecked since.
- 2026-09-20: both store builds sat in the 4.3(a) wave.
- 2026-10-21: renamed to Machaon, because the store name Intake belongs to another developer.
- Revenue: no verified number (the App Store Connect key cannot read sales yet).

## Role in the company plan

Catalogue. GTM.md lists it as free, with a $1 web unlock. It serves Stage 0 as one more Stripe sale that proves the web checkout works, and under Stage 2 it earns its place or is retired.

## Next

Set the Stripe secrets on Cloudflare (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PRICE_ID`), then test one checkout from start to finish.

## Million, billion, trillion

**A million.** Machaon is the habit log people keep for years, and the export is the one dollar that matters.

**A billion.** Machaon is the harm reduction log on every Jaybulb device, with the export free for anyone who asks for it.

**A trillion.** Machaon is a personal health record people own and carry, with the export as the standard and nobody selling it.

## Change it

Web: the `STRIPE_PRICE_ID` secret on the Cloudflare Pages project, then redeploy. Store, if the app ever goes paid: `asc pricing schedule create --app 6785764864 --price 0.99 --base-territory USA --start-date YYYY-MM-DD`. Only with Joshua's yes in chat.

Anyone who got Machaon while it was free keeps it free.

*ASC 6785764864. Verified 2026-11-02.*
