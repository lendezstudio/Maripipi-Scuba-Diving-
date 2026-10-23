/*
 * Maripipi Scuba Diving — site configuration.
 * Every business detail, contact destination and social link lives here.
 *
 * Leave a value as '' until the owner confirms it. Never enter a guessed,
 * partial or placeholder number/handle: an empty value is shown as
 * "to be added" in concept mode and removed entirely in production mode.
 */
window.SITE_CONFIG = {
  // 'concept'    → unconfirmed channels show as subdued "to be added" icons,
  //                plus one discreet note in the contact area.
  // 'production' → unconfirmed channels are removed from the page.
  // Do not switch to 'production' until at least one inquiry channel
  // (whatsapp, phone or email) is confirmed.
  mode: 'concept',

  business: {
    name: 'Maripipi Scuba Diving',
    locality: 'Maripipi',
    region: 'Biliran',
    country: 'Philippines',
  },

  // Map search for the municipality only. This is NOT the dive shop's
  // location. Replace with an exact place link once the meeting point is confirmed.
  mapSearchUrl: 'https://www.google.com/maps/search/?api=1&query=Maripipi%2C%20Biliran%2C%20Philippines',

  contact: {
    // International format, digits only, e.g. '639XXXXXXXXX'. Confirmed numbers only.
    whatsapp: '',
    // Display format is fine, e.g. '+63 9XX XXX XXXX'. Confirmed numbers only.
    phone: '',
    email: '',
  },

  social: {
    facebook: '',   // full URL, e.g. https://www.facebook.com/<page>
    instagram: '',  // full URL
    tiktok: '',     // full URL
  },
};
