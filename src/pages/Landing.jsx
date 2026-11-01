import { useEffect, useRef } from 'react';
import InstallAnywhere from '../components/InstallAnywhere';
import FooterBand from '../components/FooterBand';
import { SUBSTANCES } from '../data/substances';
import { findInteractions, severityLabel } from '../components/InteractionChecker';
import './landing.css';
import './hero.css';

const APP_STORE = 'https://apps.apple.com/app/id6785764864';

const ROWS = [
  { shot: 'home', label: 'Home', title: 'Your day on one screen', body: 'A health score, anything your labs flagged, your active stack and what you took today.' },
  { shot: 'library', label: 'Library', title: '200 substances, explained', body: 'Dosing ranges, timing and harm reduction notes for every entry, sorted by kind.' },
  { shot: 'insights', label: 'Insights', title: 'See what actually works', body: 'A heatmap of when you dose, what you use most, and a tolerance tracker for anything you take often.' },
];

const CELLS = [
  { label: 'Log', title: 'Log doses as you go', body: 'Record what you take as you take it and keep a running stack of everything active.' },
  { label: 'Interactions', title: 'Check before you take it', body: 'Pick two or more substances and see how they mix, before the dose, not after.' },
  { label: 'Labs', title: 'Your bloodwork, flagged', body: 'Add a lab panel and anything out of range shows up on your home screen.' },
];

// Adds .js to the page, then fades each .reveal in as it scrolls into view (Hermes' landing.js, in React).
function useReveal(rootRef) {
  useEffect(() => {
    const root = rootRef.current;
    if (!root) return;
    root.classList.add('js');
    const items = root.querySelectorAll('.reveal');
    if (!('IntersectionObserver' in window)) { items.forEach(el => el.classList.add('in')); return; }
    const io = new IntersectionObserver(entries => entries.forEach(e => {
      if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); }
    }), { threshold: 0.15 });
    items.forEach(el => io.observe(el));
    return () => io.disconnect();
  }, [rootRef]);
}

// Hero wall: the real interaction checker, run on a loop. Each card picks two substances, checks them with the
// same findInteractions the app uses, shows the verdict, logs the dose, then moves on. Decoration only.
const PAIRS = [['Sertraline', 'Alcohol'], ['Caffeine', 'L-Theanine'], ['Ibuprofen', 'Aspirin'], ['Melatonin', 'Alcohol'],
  ['Vitamin D3', 'Magnesium'], ['Diphenhydramine', 'Alcohol'], ['Zinc', 'Vitamin C'], ['Acetaminophen', 'Alcohol'],
  ['Omega-3 (EPA/DHA)', 'Aspirin'], ['Metformin', 'Alcohol'], ['CBD', 'Sertraline'], ['Vitamin B12', 'Omeprazole']];
function useHeroWall(wallRef) {
  useEffect(() => {
    const wall = wallRef.current;
    if (!wall) return;
    const by = n => SUBSTANCES.find(s => s.name === n);
    const pairs = PAIRS.map(([a, b]) => [by(a), by(b)]).filter(([a, b]) => a && b);
    const mq = q => matchMedia(q).matches;
    const n = mq('(max-width: 560px)') ? 3 : mq('(max-width: 900px)') ? 6 : 9;
    const still = mq('(prefers-reduced-motion: reduce)');
    const timers = [];
    const later = (f, ms) => timers.push(setTimeout(f, ms));
    wall.textContent = '';
    for (let i = 0; i < n; i++) {
      const el = document.createElement('div');
      el.className = 'mc';
      el.innerHTML = '<p class="mc-k">Interaction check</p><div class="mc-pair"><span></span><b>+</b><span></span></div><div class="mc-res"><i></i><p></p></div>';
      wall.appendChild(el);
      const [a, b] = el.querySelectorAll('.mc-pair span'), res = el.querySelector('.mc-res'), dot = res.querySelector('i'), txt = res.querySelector('p');
      let k = i;
      const play = () => {
        const [A, B] = pairs[k % pairs.length]; k += n;
        const hit = findInteractions(A, B)[0];
        a.textContent = A.name; b.textContent = ''; res.className = 'mc-res'; txt.textContent = 'Checking\u2026';
        const verdict = () => {
          res.className = 'mc-res on ' + (hit ? hit.severity : 'none');
          txt.textContent = hit ? `${severityLabel(hit.severity)}: ${hit.text}` : 'No known interactions';
        };
        if (still) { b.textContent = B.name; verdict(); return; }
        later(() => { b.textContent = B.name; }, 900 + Math.random() * 600);
        later(verdict, 2200 + Math.random() * 700);
        later(play, 6200 + Math.random() * 1800);
      };
      later(play, i * 500);
    }
    return () => timers.forEach(clearTimeout);
  }, [wallRef]);
}

// Hero parallax: the wall drifts at 0.45, the copy lifts at 0.2 and fades. Off under reduced motion.
function useParallax(heroRef) {
  useEffect(() => {
    const hero = heroRef.current;
    if (!hero || matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    const bg = hero.querySelector('.hero-bg'), copy = hero.querySelector('.hero-copy');
    let t = 0, y = 0;
    const on = e => {
      y = e.target === document || !e.target.scrollTop ? window.scrollY : e.target.scrollTop;
      if (t) return;
      t = requestAnimationFrame(() => {
        t = 0; const h = innerHeight; if (y > h * 1.2) return;
        bg.style.setProperty('--py', `${y * 0.45}px`);
        copy.style.transform = `translate3d(0, ${y * 0.2}px, 0)`; copy.style.opacity = String(Math.max(0, 1 - y / (h * 0.7)));
      });
    };
    document.addEventListener('scroll', on, { passive: true, capture: true });
    return () => { document.removeEventListener('scroll', on, { capture: true }); cancelAnimationFrame(t); };
  }, [heroRef]);
}

// Art, dithered to halftone: Sebastiano Ricci, The Dream of Aesculapius (public domain); a Rijksmuseum engraving of
// Aesculapius reviving Hippolytus (CC0); the Sosias cup, Achilles bandaging Patroclus at Troy, the war Machaon served
// as healer (CC0); Hygieia of Rhodes, Machaon's sister (CC0); a Rijksmuseum bust of Asklepios, his father (CC0).
// All via Wikimedia Commons. Every image is used once.
export default function Landing({ onGetStarted, toggle }) {
  const root = useRef(null), hero = useRef(null), wall = useRef(null);
  useReveal(root);
  useHeroWall(wall);
  useParallax(hero);

  return (
    <div className="hl" ref={root}>
      <header className="nav" aria-label="Site">
        <nav className="nav-links" aria-label="Main">
          <a href="#features">Features</a>
          <a href="#get">Platforms</a>
        </nav>
        <a className="nav-brand" href="#top" aria-label="Machaon home"><img src="/icon.svg" alt="" width="32" height="32" /></a>
        <div className="nav-end">
          {toggle}
          <button className="btn btn-solid" onClick={onGetStarted}>Get started</button>
        </div>
      </header>

      <main id="top">
        <section className="hero" ref={hero}>
          <div className="hero-bg" aria-hidden="true" inert><div className="mwall" ref={wall} /></div>
          <div className="wrap center hero-copy">
            <p className="label">Supplements, medications and symptoms</p>
            <h1 className="hero-h1">Know what you take.</h1>
            <p className="lead">A private dose log that checks every interaction first.</p>
            <div className="cta">
              <button className="btn btn-solid" onClick={onGetStarted}>Start tracking</button>
              <a className="btn btn-ghost" href="#features">See what it does</a>
            </div>
            <p className="fine">Free on the web. iPhone and iPad on the App Store.</p>
          </div>
        </section>

        <section className="band" id="features">
          <div className="band-head">
            <div className="art band-art" style={{ '--img': 'url(/art/ricci.png)' }} aria-hidden="true" />
            <div className="band-copy reveal">
              <p className="label">Named for the healer at Troy</p>
              <h2>See what works</h2>
              <p>Most trackers stop at a list. Machaon shows what each dose did.</p>
            </div>
          </div>
          <div className="frows">
            {ROWS.map(r => (
              <article className="frow reveal" key={r.shot}>
                <div className="art"><img className="shot" src={`/screenshots/ios-${r.shot}.png`} alt={`${r.title} screen`} /></div>
                <div><p className="label">{r.label}</p><h3>{r.title}</h3><p>{r.body}</p></div>
              </article>
            ))}
          </div>
          <div className="cells">
            {CELLS.map(c => (
              <article className="cell reveal" key={c.label}><p className="label">{c.label}</p><h3>{c.title}</h3><p>{c.body}</p></article>
            ))}
          </div>
        </section>

        <section className="sec plats" id="get">
          <div className="wrap center">
            <img className="mascot reveal" src="/brand/mascot.svg" width="96" height="96" alt="Aski, the Machaon mascot" />
            <p className="label reveal">Available now</p>
            <h2 className="reveal">Everywhere</h2>
            <p className="body reveal">One account. Your log follows you between the web and your phone.</p>
            <div className="prods">
              <article className="prod reveal">
                <div className="art prod-art" style={{ '--img': 'url(/art/sosias.png)' }} aria-hidden="true" />
                <p className="label">Web</p><h3>machaon.jaybulb.com</h3><p>Runs in any browser. Installs like an app.</p>
                <button className="btn btn-solid" onClick={onGetStarted}>Open the web app</button>
              </article>
              <article className="prod reveal">
                <div className="art prod-art" style={{ '--img': 'url(/art/hygieia.png)' }} aria-hidden="true" />
                <p className="label">iOS 17 and up</p><h3>iPhone and iPad</h3><p>A native app with Health, widgets and Face ID.</p>
                <a href={APP_STORE}>App Store &rarr;</a>
              </article>
              <article className="prod reveal">
                <div className="art prod-art" style={{ '--img': 'url(/art/bust.png)' }} aria-hidden="true" />
                <p className="label">Open source</p><h3>Apache 2.0</h3><p>Read every line, or run your own copy.</p>
                <a href="https://github.com/nulljosh/machaon">GitHub &rarr;</a>
              </article>
            </div>
          </div>
        </section>

        <InstallAnywhere name="Machaon" appUrl="https://machaon.jaybulb.com" appStoreUrl={APP_STORE} />
      </main>

      <footer className="foot">
        <div className="foot-top">
          <div className="foot-brand"><img src="/icon.svg" alt="" width="40" height="40" /><b>Machaon</b><p>Track what you take, and what it does.</p></div>
          <nav className="foot-cols" aria-label="Footer">
            <div><p className="label">Machaon</p><a href={APP_STORE}>App Store</a><a href="#features">Features</a><a href="#install-anywhere">Install anywhere</a><a href="/brand/">Brand kit</a><a href="https://github.com/nulljosh/machaon/blob/main/docs/WHITEPAPER.md">Whitepaper</a></div>
            <div><p className="label">Source</p><a href="https://github.com/nulljosh/machaon">GitHub</a><a href="https://github.com/nulljosh/machaon/blob/main/docs/API.md">API</a><a href="https://github.com/nulljosh/machaon/blob/main/docs/ARCHITECTURE.md">Architecture</a><a href="https://github.com/nulljosh/machaon/blob/main/docs/SECURITY.md">Security</a></div>
            <div><p className="label">More</p><a href="/privacy.html">Privacy</a><a href="/tos.html">Terms</a><a href="https://jaybulb.com">More apps</a><a href="#top">Back to top</a></div>
          </nav>
        </div>
        <FooterBand />
        <p className="legal">&copy; 2026 Joshua Trommel &middot; Apache 2.0{typeof __APP_VERSION__ !== 'undefined' ? ` · v${__APP_VERSION__}` : ''} &middot; <a href="/privacy.html">Privacy</a></p>
      </footer>
    </div>
  );
}
