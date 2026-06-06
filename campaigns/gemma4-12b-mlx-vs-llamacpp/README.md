# gemma-4 12B: MLX vs llama.cpp (matched quant)

The engine-isolated "apples to apples" comparison. Both sides run the same gemma-4 12B weights at a matched ~4.9 bpw quant; the only variable is the inference engine.

- **non-MLX** - llama.cpp's GGML/Metal backend via `llama-cli`, on a **Q4_K_M** GGUF (~4.96 bpw).
- **MLX** - Apple's MLX framework via `mlx_lm.generate`, on a **mixed_4_6** build (4-bit base + 6-bit on embeddings / `v_proj` / `down_proj`, ~4.94 bpw).

llama.cpp has no MLX backend and MLX is a separate framework, so an MLX-vs-not test is inherently the two runtimes side by side. That cross-runtime difference is the experiment, not a confound.

## The two regimes

| File | Prompt | Output | Why |
|---|---|---|---|
| `campaign-short.toml` | one paragraph | 512 tok | one-shot regime - MLX's per-invocation startup cost weighs on wall-clock |
| `campaign-long.toml` | full tutorial | 2048 tok | sustained-decode regime - the startup cost amortizes; the wall-clock verdict can flip |

Run both: the short/long flip is the finding, not a footnote.

## Prerequisites

This campaign runs **both** engines, so you need both installed and on your `PATH` before running:

- **ziraph** - a recent release or dev build; this repo's campaigns use features that landed through early June 2026 (see [`.ziraph-version`](../../.ziraph-version)). Verify: `ziraph --version`.
- **llama.cpp** - the `llama-cli` binary, **build b9330 or newer** (older builds print a summary line ziraph's parser will not recognise). Install with `brew install llama.cpp` or build from source. Verify: `llama-cli --version`.
- **mlx_lm** - Apple's MLX language-model tools, which provide the `mlx_lm.generate` command. Install with `pip install mlx-lm`. Verify: `which mlx_lm.generate`.

Both engines load, run, and free in-process - there is no daemon to start. Then fetch the models below.

## Models

You need two local model directories under `models/` (relative to where you run `ziraph campaign`):

1. **`models/gemma4-12b.gguf`** - a Q4_K_M GGUF of gemma-4 12B. Obtain a Q4_K_M GGUF build from Hugging Face. (Needs `llama-cli` b9330+ - see Prerequisites.)
2. **`models/gemma-4-12B-text-mlxlm`** - a **mixed_4_6** `mlx_lm` conversion of gemma-4 12B (text-only). This is a custom conversion (4-bit base with 6-bit on the embedding / `v_proj` / `down_proj` tensors) to match the GGUF's mixed 4/6 scheme. The exact conversion is documented in the Ziraph blog post below.

gemma-4 is Apache-2.0 licensed.

## Running

Run it straight from its URL - ziraph fetches the TOML, shows the commands, and (after you confirm) runs them locally. You still need the models and runners from Prerequisites above:

```
ziraph campaign https://github.com/ziraph/campaigns/blob/main/campaigns/gemma4-12b-mlx-vs-llamacpp/campaign-short.toml
ziraph campaign https://github.com/ziraph/campaigns/blob/main/campaigns/gemma4-12b-mlx-vs-llamacpp/campaign-long.toml
```

After cloning, pass a local path instead - e.g. `ziraph campaign campaigns/gemma4-12b-mlx-vs-llamacpp/campaign-short.toml`.

Both runners load -> run -> free on exit (no daemon), so ziraph attributes GPU work to each process directly and only one model is resident at a time - `schedule="interleaved"` is safe even on 16 GB. Thinking is off on both sides (answer-only). Run on a quiet machine with the external display asleep for clean thermals.

## How to read it

The compare table at the end of each run reports per-variant decode tok/s, energy per token, memory bandwidth, GPU power, and a winner per metric. The headline questions:

- **Decode throughput** - is one engine actually faster at generating tokens, or is the difference elsewhere?
- **Energy** - CPU vs GPU energy split per engine (MLX and llama.cpp drive the CPU differently).
- **Wall-clock** - dominated by model-load + startup on short runs, by decode on long runs.

The published result and the full numbers are in the Ziraph apples-to-apples write-up: **[ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4](https://ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4)** (it walks through both this engine-isolated comparison and the real-world Ollama-tags one). Summary finding on an M1: decode is close to a tie; the real differences are MLX's per-invocation startup tax (visible on short runs) and a higher CPU-energy share, not raw throughput.

## Reference results

Reference aggregates for this campaign are pending a clean re-run on a current ziraph build; once captured, a `results/` folder lands here like the sibling [Ollama campaign](../gemma4-12b-ollama-gguf-vs-mlx/results/) has. The headline finding - decode close to a tie - is in the [write-up](https://ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4).

## Reference hardware

The published figures are from a MacBook Air M1 (8-core GPU, 16 GB). Your numbers will differ by chip; compare within the same chip class.
