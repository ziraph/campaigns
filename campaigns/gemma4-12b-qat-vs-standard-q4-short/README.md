# gemma-4 12B: QAT Q4 vs standard Q4 - short prompt (matched UD-Q4_K_XL)

Does **quantization-aware training (QAT)** actually beat ordinary **post-training quantization (PTQ)** at the same Q4 size - and what does it cost in energy? This replicates a widely-shared AMD RX 7800 XT / ROCm comparison of Gemma 4 12B (standard `UD-Q4_K_XL` vs its `QAT UD-Q4_K_XL` sibling) on Apple Silicon, and adds the dimension that comparison did not have: **energy per token, memory-bandwidth %, and thermals**.

Both sides are the **same model** at the **same quant format** (Unsloth Dynamic Q4_K_XL) through the **same engine** (llama.cpp / Metal). The only variable is whether the weights were quantization-aware trained or post-training quantized.

This is the **short / one-shot regime** (one coding prompt, 512 tokens). Run the sustained-decode sibling too - **[`gemma4-12b-qat-vs-standard-q4-long`](../gemma4-12b-qat-vs-standard-q4-long/)**.

## Why this is interesting on Apple Silicon

The QAT file is ~9% smaller (~6.24 GiB vs ~6.85 GiB). On Apple Silicon, LLM **decode is memory-bound** - each token drags the weights across the memory bus, so throughput tracks bytes-moved more than raw FLOPs (the [apples-to-apples write-up](https://ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4) found two different engines *tie* on decode because both hit the same memory wall). The prediction: the smaller QAT weights should decode **faster and at lower energy per token**, and ziraph's bandwidth-% metric should show *why*. The original comparison framed QAT's speed win as a quantization-quality effect; this campaign tests how much of it is simply **fewer bytes per token**.

(ziraph measures the *cost* of inference - speed, energy, bandwidth, thermals - not output quality. The original comparison's HumanEval result is a separate quality eval; reproduce it with a coding-eval harness if you want the quality half.)

## Prerequisites

- **ziraph** - a recent release or dev build (see [`.ziraph-version`](../../.ziraph-version)). Verify: `ziraph --version`.
- **llama.cpp** - the `llama-cli` binary, **build b9330 or newer** (older builds print a summary line ziraph's parser will not recognise). Install with `brew install llama.cpp` or build from source. Verify: `llama-cli --version`.

## Models

Paths are relative to your current working directory, so put both GGUFs under `models/`:

```
huggingface-cli download unsloth/gemma-4-12b-it-GGUF gemma-4-12b-it-UD-Q4_K_XL.gguf --local-dir models/
huggingface-cli download unsloth/gemma-4-12B-it-qat-GGUF gemma-4-12B-it-qat-UD-Q4_K_XL.gguf --local-dir models/
```

1. **`models/gemma-4-12b-it-UD-Q4_K_XL.gguf`** - standard PTQ, ~6.85 GiB, from [`unsloth/gemma-4-12b-it-GGUF`](https://huggingface.co/unsloth/gemma-4-12b-it-GGUF).
2. **`models/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf`** - QAT, ~6.24 GiB, from [`unsloth/gemma-4-12B-it-qat-GGUF`](https://huggingface.co/unsloth/gemma-4-12B-it-qat-GGUF).

Both run **text-only** - the QAT repo also ships `mmproj-*` multimodal files, which this campaign does not use. gemma-4 is Apache-2.0 licensed.

**Sanity-check each file before you trust the numbers.** Some quantized Gemma 4 uploads have shipped broken (repeated `<unused…>` or junk tokens). Run each model once by hand first and confirm it produces coherent text:

```
llama-cli -m models/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf -p "In one sentence, what is an LRU cache?" -n 64 -st --jinja --reasoning off
```

If you get repeated special tokens instead of a real answer, re-download (or re-quantize) before running the campaign - a broken file will silently poison the comparison.

## Running

```
ziraph campaign remote gemma4-12b-qat-vs-standard-q4-short
```

ziraph fetches the TOML, shows the commands, and (after you confirm) runs them locally - so `models/` must sit under your current directory. After cloning the repo you can also pass a local path: `ziraph campaign campaigns/gemma4-12b-qat-vs-standard-q4-short/campaign.toml`.

Both runners load -> run -> free on exit (no daemon), one model resident at a time, so `schedule="interleaved"` is safe even on 16 GB. Thinking is off on both sides (answer-only). Run on a quiet machine with the external display asleep for clean thermals.

## How to read it

The compare table reports per-variant decode tok/s, energy per token, memory bandwidth, GPU power, and a winner per metric. Watch:

- **Decode throughput** - does QAT actually decode faster, and by how much on *this* chip versus the AMD figure (+25%)?
- **Energy per token** - the smaller model should move fewer weight bytes per token; does that show up as lower joules/token?
- **Memory bandwidth %** - if both pin the same DRAM ceiling, the decode gap is a bytes-per-token story, not a compute one.
- **Wall-clock + load time** - the smaller QAT file also loads faster.

## Reference results

Reference aggregates are pending a clean run on a current ziraph build; once captured, a `results/` folder lands here like the [Ollama campaigns](../gemma4-12b-ollama-gguf-vs-mlx-short/results/) have.

## Reference hardware

Tune expectations to your chip. The original comparison (AMD RX 7800 XT, ROCm, llama.cpp, 5-run average) reported: standard 42.3 gen tok/s, QAT 52.9 gen tok/s (+25%); QAT ~8.9% smaller. Apple Silicon decode rates and the QAT margin will differ - compare within the same chip class.
