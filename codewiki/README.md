# CodeWiki — Dokumentasi SmartAI Chat

Dokumentasi teknis aplikasi **SmartAI Chat** (Flutter + Forui + Riverpod) yang dibangun dengan [VitePress](https://vitepress.dev/) dan [Mermaid](https://mermaid.js.org/) untuk diagram.

---

## Prasyarat

- [Node.js](https://nodejs.org/) versi 18+
- npm (bawaan Node.js)

---

## Menjalankan Secara Lokal

```bash
# 1. Masuk ke direktori codewiki
cd codewiki

# 2. Install dependensi
npm install

# 3. Jalankan development server (hot reload)
npm run docs:dev
```

Development server akan berjalan di `http://localhost:5173`.

### Perintah Lainnya

| Perintah              | Keterangan                                   |
|-----------------------|----------------------------------------------|
| `npm run docs:dev`    | Menjalankan dev server dengan hot reload     |
| `npm run docs:build`  | Build static site ke `.vitepress/dist/`      |
| `npm run docs:preview`| Pratinjau hasil build production secara lokal|

## Struktur Proyek

```
codewiki/
├── .vitepress/
│   ├── config.mjs          # Konfigurasi VitePress
│   └── sidebar.mjs         # Navigasi sidebar
├── getting-started/        # Panduan memulai
├── architecture/           # Arsitektur aplikasi
├── core-components/        # Komponen inti
├── data/                   # Model data
├── user-inference/         # UX & persona
├── application-lifecycle/  # Siklus hidup aplikasi
├── development/            # Panduan development
├── index.md                # Halaman utama
├── overview.md             # Ringkasan proyek
└── package.json
```
