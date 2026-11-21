# hermes-agent-bootstrap

Bootstrap prompt untuk **Hermes Agent** — self-contained, portabel, dan aman untuk repo publik.

Prompt ini dipakai untuk me-bootstrap sesi/agen Hermes di workstation atau cloud mana pun, dengan:
- identitas & kebutuhan user,
- cara kerja yang direkomendasikan,
- referensi inventory skill (per domain),
- aturan keamanan (tanpa credential).

## Isi

| File | Isi |
|------|-----|
| `BOOTSTRAP_AGENT.md` | Blok prompt utama (copy-paste sebagai pesan pertama sesi Hermes) + cara pakai |
| `PROMPT.md` | Blok prompt murni (tanpa bagian petunjuk) — sumber utama |
| `.hermes.md` | Salinan `PROMPT.md`; auto-load sebagai project context di setiap sesi Hermes di repo ini |
| `install.sh` | Install Hermes + seed `.hermes.md` + mulai sesi bootstrap |
| `HONCHO.md` | Resep self-hosted Honcho (memory lokal) + wiring ke Hermes |
| `honcho.json.example` | Template config Honcho profile-local (tanpa secret) |

## Mulai cepat (cloud/workstation baru)

```bash
git clone https://github.com/addhe/hermes-agent-bootstrap
cd hermes-agent-bootstrap
./install.sh               # install Hermes + buka sesi bootstrap
```

Atau install + seed tanpa langsung buka sesi:

```bash
./install.sh --no-launch
cd hermes-agent-bootstrap && hermes
```

`install.sh` akan: (1) install Hermes lewat installer resmi bila belum ada, (2) menyalin `PROMPT.md` → `.hermes.md` (auto-load di setiap sesi di direktori ini), (3) membuka sesi Hermes interaktif. Tanpa credentials, tanpa secret.

## Cara pakai

1. **Bootstrap sesi baru:** buka Hermes di mesin tujuan, tempel seluruh blok prompt dari `BOOTSTRAP_AGENT.md`.
2. **Ringkas:** cukup tempel bagian "Identitas user" + "Inventory skill (relevan)".
3. **Update:** tambahkan skill baru ke daftar inventory sesuai kategori.

## Keamanan (WAJIB untuk repo publik)

- **Jangan pernah commit credentials**: API key, token, `.env`, file konfigurasi yang berisi rahasia, kredensial akun, atau detail identitas pribadi.
- Rahasia diisi **lokal** di mesin tujuan (mis. lewat `.env` / konfigurasi Hermes) — bukan di repo ini.
- Jika menambahkan environment/konfigurasi, tuliskan **placeholder** saja (mis. `YOUR_API_KEY`), bukan nilai asli.
- Jangan sertakan path absolut, hostname, alamat IP, atau detail akun milik user di file prom.

## Disclaimer

Prompt ini adalah titik awal (bootstrap). Sesuaikan dengan kebutuhan dan skill aktual yang tersedia di mesin tujuan.
