// Guarda la app y las fotos en el dispositivo para poder abrirla sin internet.
const CACHE = 'trending-v1';
const APP = ['./', './index.html', './config.js', './manifest.webmanifest', './icon-192.png', './icon-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(APP)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
const put = (req, res) => { if (res && (res.ok || res.type === 'opaque')) { const cp = res.clone(); caches.open(CACHE).then(c => c.put(req, cp)); } return res; };

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const u = new URL(req.url);
  // Fotos de Supabase: primero la copia guardada (no cambian nunca)
  if (u.pathname.includes('/storage/v1/object/public/')) {
    e.respondWith(caches.match(req).then(r => r || fetch(req).then(res => put(req, res))));
    return;
  }
  // Datos de Supabase: siempre en vivo
  if (u.hostname.endsWith('supabase.co')) return;
  // La app: primero internet (para tener la última versión), si no hay, la copia
  if (u.origin === location.origin) {
    e.respondWith(fetch(req).then(res => put(req, res)).catch(() => caches.match(req).then(r => r || caches.match('./index.html'))));
    return;
  }
  // Librerías y fuentes: primero la copia guardada
  if (/cdn\.jsdelivr\.net|cdnjs\.cloudflare\.com|fonts\.(googleapis|gstatic)\.com/.test(u.hostname)) {
    e.respondWith(caches.match(req).then(r => r || fetch(req).then(res => put(req, res))));
  }
});
