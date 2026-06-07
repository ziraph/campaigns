# gemma-4 12B: QAT Q4 vs standard Q4 - long prompt (matched UD-Q4_K_XL)

The **sustained-decode** sibling of **[`gemma4-12b-qat-vs-standard-q4-short`](../gemma4-12b-qat-vs-standard-q4-short/)**. Same two models - Gemma 4 12B in Unsloth Dynamic `Q4_K_XL`, **QAT vs standard PTQ** - same engine (llama.cpp / Metal), but a longer coding prompt and a **1024-token** cap so decode settles into a steady state.

On Apple Silicon LLM **decode is memory-bound**, so this longer run is where a smaller (QAT) model's lower bytes-per-token should show its clearest decode-speed and energy/token edge. The short/one-shot run is dominated more by model-load and startup; this one is the cleaner read on sustained generation.

See the **[short campaign's README](../gemma4-12b-qat-vs-standard-q4-short/)** for the full rationale, the Apple-Silicon-vs-AMD framing, and the energy/bandwidth angle.

## Prerequisites

- **ziraph** - recent release or dev build (see [`.ziraph-version`](../../.ziraph-version)). Verify: `ziraph --version`.
- **llama.cpp** - `llama-cli`, **build b9330 or newer**. `brew install llama.cpp`. Verify: `llama-cli --version`.

## Models

Same two GGUFs as the short campaign, under `models/`:

```
huggingface-cli download unsloth/gemma-4-12b-it-GGUF gemma-4-12b-it-UD-Q4_K_XL.gguf --local-dir models/
huggingface-cli download unsloth/gemma-4-12B-it-qat-GGUF gemma-4-12B-it-qat-UD-Q4_K_XL.gguf --local-dir models/
```

- **`models/gemma-4-12b-it-UD-Q4_K_XL.gguf`** - standard PTQ, ~6.85 GiB, [`unsloth/gemma-4-12b-it-GGUF`](https://huggingface.co/unsloth/gemma-4-12b-it-GGUF).
- **`models/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf`** - QAT, ~6.24 GiB, [`unsloth/gemma-4-12B-it-qat-GGUF`](https://huggingface.co/unsloth/gemma-4-12B-it-qat-GGUF).

Text-only (the QAT repo's `mmproj-*` files are not used). gemma-4 is Apache-2.0. **Sanity-check both files generate coherent text before trusting the run** - some quantized Gemma 4 uploads have shipped broken (repeated `<unused…>` tokens); see the short campaign's README for the one-line check.

## Running

```
ziraph campaign remote gemma4-12b-qat-vs-standard-q4-long
```

Or local: `ziraph campaign campaigns/gemma4-12b-qat-vs-standard-q4-long/campaign.toml`. Both runners load -> run -> free on exit, `schedule="interleaved"` is safe on 16 GB. Run on a quiet machine with the external display asleep.

## How to read it

Same compare table as the short campaign, but the sustained 1024-token decode makes the steady-state numbers the ones to trust:

- **Decode tok/s** - the steady-state generation rate, with load/startup amortised away.
- **Energy per token** - the headline efficiency number; the smaller QAT file should win if decode is bytes-bound.
- **Memory bandwidth %** - whether both variants sit at the same DRAM ceiling (the memory-bound signature).

## Reference results

Pending a clean run on a current ziraph build; a `results/` folder lands here once captured.

## Reference hardware

The original comparison (AMD RX 7800 XT, ROCm, 5-run average) reported standard 42.3 / QAT 52.9 gen tok/s (+25%), QAT ~8.9% smaller. Apple Silicon rates and margins differ - compare within the same chip class.
