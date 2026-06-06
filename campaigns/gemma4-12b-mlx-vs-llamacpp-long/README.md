# gemma-4 12B: MLX vs llama.cpp - long prompt (matched quant)

The engine-isolated "apples to apples" comparison, **long / sustained-decode regime**. Both sides run the same gemma-4 12B weights at a matched ~4.9 bpw quant; the only variable is the inference engine.

- **non-MLX** - llama.cpp's GGML/Metal backend via `llama-cli`, on a **Q4_K_M** GGUF (~4.96 bpw).
- **MLX** - Apple's MLX framework via `mlx_lm.generate`, on a **mixed_4_6** build (4-bit base + 6-bit on embeddings / `v_proj` / `down_proj`, ~4.94 bpw).

llama.cpp has no MLX backend and MLX is a separate framework, so an MLX-vs-not test is inherently the two runtimes side by side. That cross-runtime difference is the experiment, not a confound.

This is the **full-tutorial prompt, 2048-token** regime, where MLX's per-invocation startup cost amortizes over ~2,000 decode tokens and the wall-clock verdict can flip. Run the one-shot sibling too - **[`gemma4-12b-mlx-vs-llamacpp-short`](../gemma4-12b-mlx-vs-llamacpp-short/)** - the short/long flip is the finding, not a footnote.

## Prerequisites

This campaign runs **both** engines, so you need both installed and on your `PATH` before running:

- **ziraph** - a recent release or dev build; this repo's campaigns use features that landed through early June 2026 (see [`.ziraph-version`](../../.ziraph-version)). Verify: `ziraph --version`.
- **llama.cpp** - the `llama-cli` binary, **build b9330 or newer** (older builds print a summary line ziraph's parser will not recognise). Install with `brew install llama.cpp` or build from source. Verify: `llama-cli --version`.
- **mlx_lm** - Apple's MLX language-model tools, which provide the `mlx_lm.generate` command. Install with `pip install mlx-lm`. Verify: `which mlx_lm.generate`.

Both engines load, run, and free in-process - there is no daemon to start. Then fetch the models below.

## Models

Paths in the campaign are relative to **your current working directory** (where you run `ziraph campaign`), so put both models under `models/`:

1. **`models/gemma4-12b.gguf`** - a Q4_K_M GGUF of gemma-4 12B, from Hugging Face. (Needs `llama-cli` b9330+ - see Prerequisites.)
2. **`models/gemma-4-12B-text-mlxlm`** - a **mixed_4_6** `mlx_lm` conversion of gemma-4 12B (text-only): 4-bit base with 6-bit on the embedding / `v_proj` / `down_proj` tensors, to match the GGUF's mixed 4/6 scheme. The exact conversion is documented in the Ziraph blog post below.

gemma-4 is Apache-2.0 licensed.

## Running

```
ziraph campaign remote gemma4-12b-mlx-vs-llamacpp-long
```

ziraph fetches the TOML, shows the commands, and (after you confirm) runs them locally - so `models/` must sit under your current directory. After cloning the repo you can also pass a local path: `ziraph campaign campaigns/gemma4-12b-mlx-vs-llamacpp-long/campaign.toml`.

Each long run generates ~2,000 tokens (several minutes), so the full campaign (2 warmup + 3 measured, x2 variants, interleaved) is roughly 50 minutes - run it on a quiet machine with the external display asleep. Both runners load -> run -> free on exit, so attribution is symmetric and `schedule="interleaved"` is safe even on 16 GB. Thinking is off on both sides (answer-only).

## How to read it

The compare table at the end reports per-variant decode tok/s, energy per token, memory bandwidth, GPU power, and a winner per metric. On this sustained regime, watch:

- **Wall-clock** - now dominated by decode, so MLX's startup tax fades and sustained-decode behaviour dominates (this is where the short-run verdict can flip).
- **Decode throughput** - whether the engines converge to parity over a long generation.
- **Energy** - the CPU vs GPU energy split per engine.

Full numbers and the interpretation are in the Ziraph write-up: **[ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4](https://ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4)**. Summary on an M1: decode is close to a tie; the real differences are MLX's startup tax (visible on short runs) and a higher CPU-energy share, not raw throughput.

## Reference results

Reference aggregates for this campaign are pending a clean re-run on a current ziraph build; once captured, a `results/` folder lands here like the [Ollama campaigns](../gemma4-12b-ollama-gguf-vs-mlx-long/results/) have. The headline finding - decode close to a tie - is in the [write-up](https://ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4).

## Reference hardware

Published figures are from a MacBook Air M1 (8-core GPU, 16 GB). Your numbers will differ by chip; compare within the same chip class.
