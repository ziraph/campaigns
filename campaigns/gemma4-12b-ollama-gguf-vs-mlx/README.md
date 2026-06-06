# gemma-4 12B in Ollama: GGUF vs MLX (as shipped)

The real-world "what you get from the two official tags" comparison. Both variants are `ollama run`; the difference is the engine Ollama picks for each tag.

- **A** - `gemma4:12b` - GGUF **Q4_K_M** (~4.96 bpw, ~7.6 GB), llama.cpp engine.
- **B** - `gemma4:12b-mlx` - **nvfp4** (~4-bit FP, ~10 GB), Ollama's MLX engine.

> **Not matched-quant.** Q4_K_M and nvfp4 are different formats, and on the long prompt the two tags are even different model scopes (11.9B text vs a 13.0B unified text+vision+audio build). A delta here blends engine + quant (+ scope). Read it as "GGUF-as-shipped vs MLX-as-shipped," **not** "same weights." For the controlled engine verdict, use the sibling [`gemma4-12b-mlx-vs-llamacpp`](../gemma4-12b-mlx-vs-llamacpp/) campaign.

## What it answers

1. **Is the old ">=32 GB to use MLX" floor still there?** `gemma4:12b-mlx` is nvfp4, a format only the MLX engine runs. If its variant produces real tokens on a 16 GB machine, the MLX engine ran and the floor is gone.
2. **GGUF vs MLX as people actually run them** - decode tok/s, energy per token, memory bandwidth, GPU power, from the compare table.

## The two regimes

| File | Prompt | Why |
|---|---|---|
| `campaign-short.toml` | one paragraph | one-shot regime (not MLX's strength) |
| `campaign-long.toml` | full tutorial | sustained-decode regime - run before any sustained claim |

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
ziraph campaign campaigns/gemma4-12b-ollama-gguf-vs-mlx/campaign-short.toml
ziraph campaign campaigns/gemma4-12b-ollama-gguf-vs-mlx/campaign-long.toml
```

Both variants pass `--keepalive=0` so the daemon drops each model the instant a run ends - only one model is resident at a time (~10 GB peak on 16 GB), and each run reloads symmetrically, so model-load time is counted on both sides. `schedule="interleaved"` (A,B,A,B…) is therefore safe and thermally fair.

Use the `--keepalive=0` **flag**, not the `OLLAMA_KEEP_ALIVE=0` env var: the env var only reaches the `ollama run` client, while an already-running `ollama serve` daemon keeps the model resident anyway. The flag is what reaches the request. Verify with `ollama ps` (it should be empty between runs).

## Reference

The real-world half of the Ziraph apples-to-apples write-up covers this: **[ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4](https://ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4)**. Reference figures are from a MacBook Air M1 (16 GB); compare within the same chip class. The aggregate summaries and σ-aware compare tables for both regimes are in [`results/`](results/) - diff your own run against them with `ziraph compare`.
