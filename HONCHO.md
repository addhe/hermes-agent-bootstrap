# Self-Hosted Honcho untuk Hermes (Memory Lokal)

Resep untuk menjalankan **Honcho** (Plastic Labs — https://github.com/plastic-labs/honcho) secara **lokal/self-host** sebagai backend memory eksternal Hermes. Data percakapan & profil user tetap di mesin Anda — bukan di cloud Plastic Labs.

> **Keamanan:** dokumen ini + template-nya aman untuk repo publik. API key/rahasia diisi **lokal** (`.env`, `~/.honcho`, `~/.hermes/.env`) — jangan commit.

## Kenapa Honcho

Hermes punya memory 4 lapis. Lapisan cross-session (user modeling) bisa ditenagai Honcho, yang:
- mengekstrak observasi dari percakapan (Deriver),
- menjawab pertanyaan tentang user secara dialectic (Dialectic),
- merangkum sesi, dan mengonsolidasi memory (Dream).

Default Hermes mengarah ke cloud honcho.dev. Self-host memberi kedaulatan data; kekurangannya hanya sedikit menurunnya kualitas reasoning deduktif dibanding model khusus Neuromancer.

## Pilihan deployment

| Opsi | Privasi | LLM untuk memory | Setup | Cost |
|------|---------|------------------|-------|------|
| Managed cloud (default) | Rendah | Neuromancer (Plastic Labs) | Tidak ada | free/paid |
| **Self-host + API** (direkomendasikan) | Sedang — data di mesin Anda | API OpenAI-compatible (OpenRouter, dll.) | ~3 menit | pemakaian API |
| Self-host + model lokal | Tinggi — tidak ada yang keluar | Ollama/vLLM lokal | lebih lama | hardware |

## Arsitektur (self-host + API)

```
Hermes Agent ──► localhost:8000 (self-hosted Honcho API)
                  │
                  ├── PostgreSQL + pgvector (mesin Anda)
                  ├── Redis cache
                  └── Deriver/Dialectic/Dream workers
                          │
                          ├── Primary LLM (OpenAI-compatible)
                          └── Backup LLM (opsional)
```

## Setup cepat (satu perintah)

Repo `elkimek/honcho-self-hosted` menyediakan `setup.sh` yang meng-install Docker, clone Honcho upstream, menyalin config, meminta API key, menjalankan stack, **dan menkonfigurasi Hermes**:

```bash
curl -sL https://raw.githubusercontent.com/elkimek/honcho-self-hosted/main/setup.sh -o /tmp/setup.sh
bash /tmp/setup.sh
```

## Setup manual (ringkas)

1. Install Docker + Compose (Linux: `sudo apt-get install -y docker-ce docker-compose-plugin`, lalu log out/in).
2. Clone config repo + upstream Honcho, salin config:
   ```bash
   git clone https://github.com/elkimek/honcho-self-hosted.git ~/honcho-self-hosted
   git clone --depth 1 https://github.com/plastic-labs/honcho.git ~/honcho
   cp ~/honcho-self-hosted/{docker-compose.yml,config.toml} ~/honcho/
   cp ~/honcho-self-hosted/env.example ~/honcho/.env
   ```
3. Isi `~/honcho/.env` (key local; jangan commit): `LLM_VLLM_API_KEY`, `LLM_VLLM_BASE_URL`, `LLM_EMBEDDING_API_KEY`, `LLM_EMBEDDING_BASE_URL`, `LLM_EMBEDDING_MODEL`, `LLM_OPENAI_COMPATIBLE_API_KEY`, `LLM_OPENAI_API_KEY`.
4. Jalankan:
   ```bash
   cd ~/honcho && docker compose up -d
   curl -s http://localhost:8000/openapi.json | head -1   # verifikasi
   ```
5. Wire ke Hermes (lihat di bawah).

Untuk model lokal: jalankan Ollama/vLLM, lalu ikuti bagian "Local / LAN Inference" di README repo elkimek (set `LLM_VLLM_BASE_URL` ke server lokal).

## Wire ke Hermes

Install plugin Honcho + aktifkan sebagai memory provider:

```bash
hermes plugins install honcho
hermes memory setup        # pilih "honcho" dari daftar provider
```

Config Honcho berada di `~/.honcho/config.json` (global) atau `$HERMES_HOME/honcho.json` (profile-local). Untuk self-host, wizard `hermes honcho setup` / `hermes memory setup` akan menanyakan **base URL** (`http://localhost:8000`) dan opsional JWT local (signed dengan `AUTH_JWT_SECRET` server; kosongkan bila `AUTH_USE_AUTH=false`).

Contoh template profile-local: lihat [`honcho.json.example`](honcho.json.example) di repo ini. Setelah set, restart gateway/sesi:

```bash
hermes gateway restart
```

## Tombol konfigurasi (di honcho.json)

| Key | Default | Fungsi |
|-----|---------|--------|
| `contextTokens` | null (uncapped) | Budget token context auto-inject per turn (mis. 1200) |
| `contextCadence` | 1 | Turn minimum antar refresh context base |
| `dialecticCadence` | 2 | Turn minimum antar pemanggilan dialectic (1–5) |
| `dialecticDepth` | 1 | Jumlah pass `.chat()` per invokasi dialectic (1–3) |
| `dialecticReasoningLevel` | medium | Level reasoning tiap call |
| `reasoningHeuristic` | true | Skala level otomatis berdasarkan panjang query |
| `reasoningLevelCap` | high | Batas level maksimum heuristic |

## Verifikasi & troubleshooting

- API hidup: `curl -s http://localhost:8000/openapi.json | head -1`
- Status queue: `curl -s http://localhost:8000/v3/workspaces/hermes/queue/status | python3 -m json.tool`
- Log: `docker compose logs -f api deriver` (di `~/honcho`)
- Backup: `docker compose exec database pg_dump -U honcho honcho > backup.sql`
- `hermes memory status` untuk memastikan provider aktif.
- Catatan: embedding butuh cloud API (server lokal umumnya tidak menyediakan embedding); bila tom embedding diisi, Honcho fallback ke backup provider.
