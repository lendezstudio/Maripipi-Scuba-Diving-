# Maripipi Scuba Diving — website (concept)

Static one-page site: `index.html`, `css/styles.css`, `js/main.js`. No build step.

**Status: concept, not launch-ready.** No inquiry channel (WhatsApp, phone or email) is confirmed yet.

## Editing business details

All contact destinations and social links live in **`js/site-config.js`**.

- Leave a value empty until the owner confirms it. Never enter partial or guessed numbers.
- `mode: 'concept'` shows unconfirmed channels as subdued “to be added” icons, with one note in the contact area.
- `mode: 'production'` removes unconfirmed channels. Switch only once at least one inquiry channel is confirmed.
- When WhatsApp and/or email are set, the inquiry composer offers “Open in WhatsApp” / “Send by email” in addition to “Copy Inquiry”. Nothing is sent or stored by the site itself.

## Deployment URL

Social metadata, canonical and JSON-LD currently point to `https://lendezstudio.github.io/Maripipi-Scuba-Diving-/`.
If the address changes (e.g. a custom domain), run:

```
powershell -ExecutionPolicy Bypass -File tools\set-site-url.ps1 -Url https://new-domain/
```

## Tools

- `tools/serve.ps1` — local preview at http://localhost:8080/
- `tools/build-images.ps1` — regenerates optimized images, logo badge and favicons from `source-assets/` (kept locally, not committed)
- `tools/build-og.ps1` — renders `tools/og-template.html` to `assets/img/og/maripipi-scuba-diving-og.jpg` (1200×630)

## Imagery

| File | Source | Status |
| --- | --- | --- |
| `hero-diver-*` | Pexels (pspov) | Illustrative, labelled on page |
| `divers-reef-wall-*` | Pexels (Graham Henderson), cropped to exclude the sea snake | Illustrative, labelled on page |
| `island-ridge-peak-*`, `island-ridge-cottages-*`, `island-headland-*` | Supplied as Maripipi photos | Confirm ownership/permission with the owner |
| `logo-badge-*`, favicons | Owner’s logo | Business imagery |

Excluded on purpose: supplied stock photos showing visible equipment brands, identifiable boats with registration marks, or a diver touching the reef. `source-assets/Logo.png` (a dive-mask illustration) is not used; the circular badge is used as the business logo.

## Owner confirmations still needed

1. Full phone / WhatsApp number, email, Facebook, Instagram, TikTok URLs.
2. Exact meeting point (then replace the map search link in the config).
3. Actual services and rates.
4. Beginner participation options and requirements.
5. Instructor / operator credentials.
6. Equipment and boat inclusions, and a real photo of the dive boat.
7. Booking, payment, weather and cancellation arrangements.
8. Permission to use the supplied island photographs.
