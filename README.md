# Ziraph Campaigns

Reproducible local AI measurement protocols for Apple Silicon, published by the [Ziraph](https://ziraph.com) project.

## What is a campaign?

A **campaign** is a TOML file that defines a controlled, repeatable measurement. It lists the workloads to compare (the **variants**), how many timed runs to take of each, the warmup/cooldown protocol, the schedule (interleaved, sequential, or randomized), and how to aggregate and compare the results. Ziraph executes it, wrapping each subprocess and writing a trace per run: a plain ndjson file that records 26 telemetry signals every tick - ANE/GPU/CPU power and energy, DRAM bandwidth, GPU die temperature, DVFM clock-residency histograms, a per-PID GPU-energy split, token counts, and more - under a 55-field header carrying the chip, build, quant, baselines, and method. Call it ~80 fields a run, not a single tok/s number. It then folds those runs into a σ-aware cross-variant comparison table.

The point is reproducibility: a campaign is the recipe, a trace is the result. Publish the TOML and anyone can re-run the exact protocol on their own hardware and compare. A campaign can also sweep a matrix (N models × M runners), so one file expands into every variant combination.

**Docs:**
- Guide: [Running an N×M multi-variant campaign](https://ziraph.com/docs/guides/nxm-multi-variant-campaign)
- Reference: [`campaign.toml` schema](https://ziraph.com/docs/reference/campaign)

**See it in action:** the write-up [Apples to apples: MLX vs llama.cpp on gemma-4](https://ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4) is built entirely from the two campaigns in this repo - a good read for what these protocols produce and how to interpret the result.

This repo is the official, curated set. Clone it, fetch the models a campaign needs, and run:

```
ziraph campaign campaigns/<name>/campaign-short.toml
```

Each campaign folder carries its TOML(s) plus a README explaining what it measures, **what software it requires** (each README opens with a Prerequisites section - e.g. llama.cpp, Ollama, mlx_lm), how to obtain the models, and how to read the result.

## What's here

| Campaign | What it measures |
|---|---|
| [`gemma4-12b-mlx-vs-llamacpp`](campaigns/gemma4-12b-mlx-vs-llamacpp/) | Engine-isolated: Apple MLX (`mlx_lm`) vs llama.cpp's Metal backend (`llama-cli`), matched quant (Q4_K_M vs mixed_4_6), short + long regimes. The "apples to apples" test. |
| [`gemma4-12b-ollama-gguf-vs-mlx`](campaigns/gemma4-12b-ollama-gguf-vs-mlx/) | Real-world: the two official Ollama tags (GGUF Q4_K_M vs MLX nvfp4) as shipped. Not matched-quant - see its README. |

## Models are not included

Campaigns reference models by a relative `models/<file>` path or by Ollama tag. The model files are large and are not in this repo; each campaign's README documents exactly how to obtain or build them. Put GGUF/MLX files under `models/` in your clone (gitignored) or edit the paths.

## Results are hardware-specific

Power, energy, and bandwidth depend on the chip. A number from an M1 is not comparable to an M4 Max. When comparing your run to a published reference, compare within the same chip class; the reference figures in each README state the hardware they came from.

## Running a campaign from a URL

Direct remote execution (`ziraph campaign <url>`) is on the roadmap ([ziraph#1212](https://github.com/mabis/ziraph/issues/1212)). For now, clone this repo and pass a local path. When remote-pull ships, Phase 1 restricts the source to `github.com/ziraph/*` and prints every command a campaign would run for your review before anything executes.

## Scope

These are engineering field-report protocols, not a certified benchmark suite. Each README states its caveats (matched-quant vs as-shipped, single-machine, thermal conditions) plainly. See [CONTRIBUTING.md](CONTRIBUTING.md) to add your own.

---

Part of [Ziraph](https://ziraph.com) - honest local AI profiling for Apple Silicon.
