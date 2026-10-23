(function () {
  'use strict';

  var root = document.documentElement;
  root.classList.add('js');
  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (!reduceMotion && 'IntersectionObserver' in window) root.classList.add('js-motion');

  var config = window.SITE_CONFIG || {};
  var contact = config.contact || {};
  var social = config.social || {};
  var isProduction = config.mode === 'production';

  /* ---------- Channels ---------- */

  var digits = function (value) { return String(value || '').replace(/[^\d]/g, ''); };

  var CHANNELS = {
    facebook:  { label: 'Facebook',  value: social.facebook,  href: function (v) { return v; }, external: true },
    instagram: { label: 'Instagram', value: social.instagram, href: function (v) { return v; }, external: true },
    tiktok:    { label: 'TikTok',    value: social.tiktok,    href: function (v) { return v; }, external: true },
    whatsapp:  { label: 'WhatsApp',  value: contact.whatsapp, href: function (v) { return 'https://wa.me/' + digits(v); }, external: true },
    phone:     { label: 'Phone',     value: contact.phone,    href: function (v) { return 'tel:+' + digits(v); } },
    email:     { label: 'Email',     value: contact.email,    href: function (v) { return 'mailto:' + v; } }
  };
  var GROUPS = {
    social: ['facebook', 'instagram', 'tiktok'],
    all: ['whatsapp', 'phone', 'email', 'facebook', 'instagram', 'tiktok']
  };

  function icon(name) {
    var ns = 'http://www.w3.org/2000/svg';
    var svg = document.createElementNS(ns, 'svg');
    svg.setAttribute('aria-hidden', 'true');
    svg.setAttribute('focusable', 'false');
    var use = document.createElementNS(ns, 'use');
    use.setAttribute('href', '#i-' + name);
    svg.appendChild(use);
    return svg;
  }

  function isConfigured(key) {
    var v = String(CHANNELS[key].value || '').trim();
    if (!v) return false;
    if (key === 'whatsapp' || key === 'phone') return digits(v).length >= 10;
    if (key === 'email') return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v);
    return /^https:\/\//.test(v);
  }

  var anyPending = false;
  document.querySelectorAll('[data-channels]').forEach(function (holder) {
    var keys = GROUPS[holder.getAttribute('data-channels')] || [];
    var list = document.createElement('ul');
    list.className = 'channels';
    list.style.display = 'contents';
    keys.forEach(function (key) {
      var c = CHANNELS[key];
      var el;
      if (isConfigured(key)) {
        el = document.createElement('a');
        el.href = c.href(String(c.value).trim());
        if (c.external) { el.target = '_blank'; el.rel = 'noopener'; }
        var extra = key === 'phone' ? ': ' + c.value : key === 'email' ? ': ' + c.value : '';
        el.setAttribute('aria-label', c.label + extra + (c.external ? ' (opens in a new tab)' : ''));
      } else {
        anyPending = true;
        if (isProduction) return;
        el = document.createElement('span');
        el.setAttribute('role', 'img');
        el.setAttribute('aria-label', c.label + ' link to be added');
        el.title = c.label + ' link to be added';
        el.classList.add('is-pending');
      }
      el.classList.add('channel');
      el.appendChild(icon(key));
      var li = document.createElement('li');
      li.style.display = 'contents';
      li.appendChild(el);
      list.appendChild(li);
    });
    holder.appendChild(list);
    if (!list.children.length) holder.hidden = true;
  });

  var pendingNote = document.querySelector('[data-pending-note]');
  if (pendingNote && anyPending && !isProduction) pendingNote.hidden = false;

  var mapLink = document.querySelector('[data-map-link]');
  if (mapLink && config.mapSearchUrl) mapLink.href = config.mapSearchUrl;

  var year = document.querySelector('[data-year]');
  if (year) year.textContent = new Date().getFullYear();

  /* ---------- Header & menu ---------- */

  var header = document.querySelector('[data-header]');
  var toggle = document.querySelector('[data-menu-toggle]');
  var nav = document.getElementById('site-nav');
  var stickyCta = document.querySelector('[data-sticky-cta]');
  var hero = document.querySelector('.hero');
  var contactSection = document.getElementById('contact');

  function setMenu(open) {
    toggle.setAttribute('aria-expanded', String(open));
    toggle.querySelector('.menu-toggle__label').textContent = open ? 'Close' : 'Menu';
    nav.classList.toggle('is-open', open);
    document.body.classList.toggle('menu-open', open);
    header.classList.toggle('is-scrolled', open || window.scrollY > 24);
    updateSticky();
    if (open) {
      var first = nav.querySelector('a');
      if (first) setTimeout(function () { first.focus(); }, 60);
    }
  }

  if (toggle && nav) {
    toggle.addEventListener('click', function () {
      setMenu(toggle.getAttribute('aria-expanded') !== 'true');
    });
    nav.addEventListener('click', function (e) {
      if (e.target.closest('a') && toggle.getAttribute('aria-expanded') === 'true') setMenu(false);
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && toggle.getAttribute('aria-expanded') === 'true') {
        setMenu(false);
        toggle.focus();
      }
    });
    // Keep keyboard focus inside the open mobile menu.
    document.addEventListener('focusin', function (e) {
      if (toggle.getAttribute('aria-expanded') !== 'true') return;
      if (!nav.contains(e.target) && e.target !== toggle && !e.target.closest('.brand')) toggle.focus();
    });
    window.matchMedia('(min-width: 1081px)').addEventListener('change', function (mq) {
      if (mq.matches) setMenu(false);
    });
  }

  var contactInView = false;
  function updateSticky() {
    if (!stickyCta || !hero) return;
    var pastHero = hero.getBoundingClientRect().bottom < 0;
    var menuOpen = toggle && toggle.getAttribute('aria-expanded') === 'true';
    stickyCta.classList.toggle('is-visible', pastHero && !contactInView && !menuOpen);
  }

  function onScroll() {
    if (!document.body.classList.contains('menu-open')) {
      header.classList.toggle('is-scrolled', window.scrollY > 24);
    }
    updateSticky();
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  /* ---------- Section observers ---------- */

  if ('IntersectionObserver' in window) {
    if (contactSection) {
      new IntersectionObserver(function (entries) {
        contactInView = entries[0].isIntersecting;
        updateSticky();
      }, { rootMargin: '0px 0px -10% 0px' }).observe(contactSection);
    }

    var navLinks = Array.prototype.slice.call(document.querySelectorAll('.site-nav__list a'));
    var spy = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        navLinks.forEach(function (a) {
          if (a.getAttribute('href') === '#' + entry.target.id) a.setAttribute('aria-current', 'true');
          else a.removeAttribute('aria-current');
        });
      });
    }, { rootMargin: '-45% 0px -50% 0px' });
    navLinks.forEach(function (a) {
      var target = document.querySelector(a.getAttribute('href'));
      if (target) spy.observe(target);
    });
  }

  var reveals = document.querySelectorAll('.reveal');
  if (root.classList.contains('js-motion')) {
    var revealer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-in');
          revealer.unobserve(entry.target);
        }
      });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.08 });
    reveals.forEach(function (el) { revealer.observe(el); });
  }

  /* ---------- Inquiry composer ---------- */

  var form = document.querySelector('[data-composer]');
  if (!form) return;

  var messageField = form.elements.message;
  var PROMPTS = {
    'New to scuba': 'I have never tried scuba diving. Is an introductory experience available, and what are the requirements?',
    'Certified diver': 'My certification level and last dive: \nWhat diving options might suit my visit?',
    'Mixed group': 'Our group and everyone’s experience level: \nWhat might be possible for us?'
  };

  // Pathway CTAs preselect the matching experience option.
  document.querySelectorAll('[data-interest]').forEach(function (link) {
    link.addEventListener('click', function () {
      var value = link.getAttribute('data-interest');
      var radio = form.querySelector('input[name="experience"][value="' + value + '"]');
      if (radio) radio.checked = true;
      if (!messageField.value.trim() && PROMPTS[value]) messageField.value = PROMPTS[value];
      setTimeout(function () {
        form.elements.name.focus({ preventScroll: true });
      }, reduceMotion ? 0 : 650);
    });
  });

  var errorBox = form.querySelector('[data-form-error]');
  var result = form.querySelector('[data-result]');
  var preview = form.querySelector('[data-preview]');
  var actions = form.querySelector('[data-actions]');
  var hint = form.querySelector('[data-hint]');
  var status = form.querySelector('[data-status]');

  function buildMessage() {
    var f = form.elements;
    var lines = ['Hello Maripipi Scuba Diving,', '', 'I would like to ask about diving in Maripipi.', ''];
    lines.push('Name: ' + f.name.value.trim());
    if (f.dates.value.trim()) lines.push('Preferred dates: ' + f.dates.value.trim());
    if (f.people.value.trim()) lines.push('Number of people: ' + f.people.value.trim());
    var exp = form.querySelector('input[name="experience"]:checked');
    lines.push('Diving experience: ' + (exp ? exp.value : ''));
    lines.push('', f.message.value.trim());
    return lines.join('\n');
  }

  function validate() {
    var problems = [];
    var name = form.elements.name;
    var message = form.elements.message;
    var exp = form.querySelector('input[name="experience"]:checked');
    name.setAttribute('aria-invalid', String(!name.value.trim()));
    message.setAttribute('aria-invalid', String(!message.value.trim()));
    if (!name.value.trim()) problems.push('your name');
    if (!exp) problems.push('your diving experience');
    if (!message.value.trim()) problems.push('a message');
    if (problems.length) {
      errorBox.textContent = 'Please add ' + problems.join(', ').replace(/, ([^,]*)$/, ' and $1') + '.';
      errorBox.hidden = false;
      var firstBad = !name.value.trim() ? name : !exp ? form.querySelector('input[name="experience"]') : message;
      firstBad.focus();
      return false;
    }
    errorBox.hidden = true;
    return true;
  }

  function actionLink(label, href, iconName, external) {
    var a = document.createElement('a');
    a.className = 'btn btn--solid';
    a.href = href;
    if (external) { a.target = '_blank'; a.rel = 'noopener'; }
    a.appendChild(icon(iconName));
    a.appendChild(document.createTextNode(label));
    if (external) {
      var sr = document.createElement('span');
      sr.className = 'visually-hidden';
      sr.textContent = ' (opens in a new tab)';
      a.appendChild(sr);
    }
    return a;
  }

  function copyText(text) {
    if (navigator.clipboard && window.isSecureContext) return navigator.clipboard.writeText(text);
    return new Promise(function (resolve, reject) {
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.setAttribute('readonly', '');
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      var ok = false;
      try { ok = document.execCommand('copy'); } catch (err) { ok = false; }
      document.body.removeChild(ta);
      ok ? resolve() : reject();
    });
  }

  form.addEventListener('input', function () { result.hidden = true; });

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    if (!validate()) return;

    var text = buildMessage();
    preview.textContent = text;
    actions.textContent = '';
    status.textContent = '';
    var hints = [];

    if (isConfigured('whatsapp')) {
      actions.appendChild(actionLink('Open in WhatsApp', 'https://wa.me/' + digits(contact.whatsapp) + '?text=' + encodeURIComponent(text), 'whatsapp', true));
      hints.push('WhatsApp opens with your message filled in. Review it there and tap send to deliver it.');
    }
    if (isConfigured('email')) {
      var subject = 'Diving inquiry from ' + form.elements.name.value.trim();
      var mail = actionLink('Send by email', 'mailto:' + contact.email + '?subject=' + encodeURIComponent(subject) + '&body=' + encodeURIComponent(text), 'email', false);
      if (actions.children.length) mail.className = 'btn btn--outline';
      actions.appendChild(mail);
      hints.push('Email opens a draft in your mail app; it is sent only when you send it.');
    }

    var copyBtn = document.createElement('button');
    copyBtn.type = 'button';
    copyBtn.className = actions.children.length ? 'btn btn--outline' : 'btn btn--solid';
    copyBtn.appendChild(icon('copy'));
    copyBtn.appendChild(document.createTextNode('Copy Inquiry'));
    copyBtn.addEventListener('click', function () {
      copyText(text).then(function () {
        status.textContent = 'Copied to your clipboard. Paste it into your message to the team.';
      }, function () {
        status.textContent = 'Copy didn’t work in this browser. Select the text above and copy it manually.';
      });
    });
    actions.appendChild(copyBtn);

    if (!isConfigured('whatsapp') && !isConfigured('email')) {
      hints.push('Copy your message to send through your usual contact with the team.');
    }
    hint.textContent = hints.join(' ');

    result.hidden = false;
    result.focus({ preventScroll: true });
    result.scrollIntoView({ behavior: reduceMotion ? 'auto' : 'smooth', block: 'nearest' });
  });
})();
