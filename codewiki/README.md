# CodeWiki — Dokumentasi SmartAI Chat

Dokumentasi teknis aplikasi **SmartAI Chat** (Flutter + Forui + Riverpod) yang dibangun dengan [VitePress](https://vitepress.dev/) dan [Mermaid](https://mermaid.js.org/) untuk diagram.

🔗 **Live**: [codewiki-smartai.pages.dev](https://codewiki-smartai.pages.dev/)

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

---

## Deploy ke Cloudflare Pages

Situs ini sudah dipublikasikan di [codewiki-smartai.pages.dev](https://codewiki-smartai.pages.dev/). Berikut langkah untuk deploy ulang jika ada perubahan:

### Cara 1: Deploy manual via Wrangler CLI

```bash
# 1. Build dulu
npm run docs:build

# 2. Deploy ke Cloudflare Pages
npx wrangler pages deploy .vitepress/dist --project-name codewiki-smartai
```

### Cara 2: Deploy via Cloudflare Dashboard

1. Buka [Cloudflare Dashboard](https://dash.cloudflare.com/) > **Workers & Pages**
2. Pilih project `codewiki-smartai`
3. Upload folder `.vitepress/dist/` secara manual melalui tab **Assets**

---

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
