# Reference results

Published reference figures for this campaign, from the M1 run behind the [apples-to-apples write-up](https://ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4).

- **Hardware:** MacBook Air M1 (8-core GPU, 16 GB)
- **ziraph:** v0.1.0-dev.20260605191643
- **Runs:** 3 measured per variant (2 warmup discarded), interleaved schedule

`short/` and `long/` each hold the σ-aware comparison table (`compare.md`) and the per-variant aggregate summaries (`ollama-gguf-summary.json`, `ollama-mlx-summary.json`).

## Compare your run to the reference

Run the campaign, then diff your own aggregate against the reference summary for the same variant:

```
ziraph campaign campaigns/gemma4-12b-ollama-gguf-vs-mlx/campaign-long.toml
ziraph compare results/long/ollama-gguf-summary.json campaign-out/ollama-gguf-vs-mlx-long/ollama-gguf-summary.json
```

Decode rate and energy per token are meaningful to compare across chips; absolute power and bandwidth are chip-specific, so only read those against the reference if you are also on an M1. The `mean_gpu` / `mean_cpu` energy rows are whole-SoC upper bounds - both tags run through the Ollama daemon, so the GPU work is attributed to the `llama-server` worker Ollama spawns, not the wrapped `ollama run` client.
