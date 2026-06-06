# gemma-4 12B in Ollama: GGUF vs MLX - long prompt (as shipped)

The real-world "what you get from the two official tags" comparison, **long / sustained-decode regime**. Both variants are `ollama run`; the difference is the engine Ollama picks for each tag.

- **A** - `gemma4:12b` - GGUF **Q4_K_M** (~4.96 bpw, 11.9B text), llama.cpp engine.
- **B** - `gemma4:12b-mlx` - **nvfp4** (~4.5 bpw, a 13.0B unified text+vision+audio build), Ollama's MLX engine.

> **Not matched-quant or scope.** Q4_K_M and nvfp4 are different formats, and the tags are different model scopes (11.9B text vs 13.0B unified). A delta here blends engine + quant + scope. Read it as "GGUF-as-shipped vs MLX-as-shipped," **not** "same weights." For the controlled engine verdict, use the matched-quant sibling [`gemma4-12b-mlx-vs-llamacpp-long`](../gemma4-12b-mlx-vs-llamacpp-long/).

This is the **sustained-decode** regime - run it before any sustained claim. The one-shot sibling is **[`gemma4-12b-ollama-gguf-vs-mlx-short`](../gemma4-12b-ollama-gguf-vs-mlx-short/)**; the short run showed MLX slower and far more CPU-hungry, but short is not MLX's regime, so this long run is the one that tells you whether decode converges to parity.

## What it answers

1. **Does decode converge?** Both tags pin near the roofline on the short run; the question here is whether sustained-decode tok/s lands level or one engine pulls ahead.
2. **GGUF vs MLX as people actually run them** - decode tok/s, energy per token, memory bandwidth, GPU power, from the compare table.

## Prerequisites

Install and have **running** before the campaign:

- **ziraph** - a recent release or dev build (see [`.ziraph-version`](../../.ziraph-version)). Verify: `ziraph --version`.
- **Ollama** - version **0.30.5 or newer**, with its background service running (the macOS app, or `ollama serve` in a terminal). Both variants are `ollama run`, which talks to that daemon - if it is not running, nothing will execute. Verify: `ollama --version`, and `ollama ps` should respond (an empty table is fine).

No Python or `llama-cli` needed here - inside Ollama, both the GGUF and MLX engines are bundled.

## Models

```
ollama pull gemma4:12b
ollama pull gemma4:12b-mlx
```

No local files to manage - Ollama stores the models.

## Running

```
ziraph campaign remote gemma4-12b-ollama-gguf-vs-mlx-long
```

ziraph fetches the TOML, shows the commands, and (after you confirm) runs them locally. After cloning you can also pass a local path: `ziraph campaign campaigns/gemma4-12b-ollama-gguf-vs-mlx-long/campaign.toml`.

Each long run is several minutes, so the full campaign is roughly 50 minutes - run it on a quiet machine with the external display asleep. Both variants pass `--keepalive=0` so the daemon drops each model the instant a run ends - one model resident at a time (~10 GB peak on 16 GB), reloaded symmetrically, so `schedule="interleaved"` is safe and thermally fair.

Use the `--keepalive=0` **flag**, not the `OLLAMA_KEEP_ALIVE=0` env var: the env var only reaches the `ollama run` client, while an already-running `ollama serve` daemon keeps the model resident anyway. The flag is what reaches the request. Verify with `ollama ps` (it should be empty between runs).

## Reference results

`results/` holds the reference figures from the M1 run behind the [write-up](https://ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4): the per-variant aggregate summaries (`ollama-gguf-summary.json`, `ollama-mlx-summary.json`) and the σ-aware [`compare.md`](results/compare.md). Hardware: MacBook Air M1 (16 GB); ziraph v0.1.0-dev.20260605191643; 3 measured runs per variant. On the long run, decode lands a near-dead tie (GGUF 6.66 vs MLX 6.65 reported tok/s); the real gap is CPU energy. Diff your own run's `campaign-out/…` summary against the matching `results/` summary with `ziraph compare` - decode rate and energy per token compare across chips; absolute power and bandwidth only within the same chip class.
