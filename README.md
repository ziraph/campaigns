# Ziraph Campaigns

Reproducible local AI measurement protocols for Apple Silicon, published by the [Ziraph](https://ziraph.com) project.

## What is a campaign?

A **campaign** is a TOML file that defines a controlled, repeatable measurement. It lists the workloads to compare (the **variants**), how many timed runs to take of each, the warmup/cooldown protocol, the schedule (interleaved, sequential, or randomized), and how to aggregate and compare the results. Ziraph executes it, wrapping each subprocess and writing a trace per run: a plain ndjson file that records 26 telemetry signals every tick - ANE/GPU/CPU power and energy, DRAM bandwidth, GPU die temperature, DVFM clock-residency histograms, a per-PID GPU-energy split, token counts, and more - under a 55-field header carrying the chip, build, quant, baselines, and method. Call it ~80 fields a run, not a single tok/s number. It then folds those runs into a σ-aware cross-variant comparison table.

The point is reproducibility: a campaign is the recipe, a trace is the result. Publish the TOML and anyone can re-run the exact protocol on their own hardware and compare. A campaign can also sweep a matrix (N models × M runners), so one file expands into every variant combination.

**Docs:**
- Concept: [Multi-variant campaigns](https://ziraph.com/docs/concepts/multi-variant-campaigns)
- Guide: [Running an N×M multi-variant campaign](https://ziraph.com/docs/guides/nxm-multi-variant-campaign)
- Reference: [`campaign.toml` schema](https://ziraph.com/docs/reference/campaign)

**See it in action:** the write-up [Apples to apples: MLX vs llama.cpp on gemma-4](https://ziraph.com/blog/apples-to-apples-mlx-vs-llama-cpp-gemma-4) is built entirely from campaigns in this repo - a good read for what these protocols produce and how to interpret the result.

This repo is the official, curated set. Run a campaign straight from the registry by name:

```
ziraph campaign remote gemma4-12b-mlx-vs-llamacpp-short
```

`ziraph campaign remote` with no name lists them all. See [Running a campaign](#running-a-campaign) for the local-path and URL forms; either way you provide the models and runners it needs (each campaign's README has a Prerequisites section).

Each campaign folder carries one `campaign.toml` plus a README explaining what it measures, **what software it requires** (each README opens with a Prerequisites section - e.g. llama.cpp, Ollama, mlx_lm), how to obtain the models, and how to read the result.

## What's here

Each campaign is one subdirectory with a single `campaign.toml`; regimes (short / long) are separate campaigns - run both, the short/long flip is the finding.

| Campaign | What it measures |
|---|---|
| [`gemma4-12b-mlx-vs-llamacpp-short`](campaigns/gemma4-12b-mlx-vs-llamacpp-short/) | Engine-isolated MLX (`mlx_lm`) vs llama.cpp (`llama-cli`), matched quant, one-shot prompt. The "apples to apples" test - short regime. |
| [`gemma4-12b-mlx-vs-llamacpp-long`](campaigns/gemma4-12b-mlx-vs-llamacpp-long/) | The same matched-quant engine test, sustained-decode prompt - where the wall-clock verdict can flip. |
| [`gemma4-12b-ollama-gguf-vs-mlx-short`](campaigns/gemma4-12b-ollama-gguf-vs-mlx-short/) | Real-world: the two official Ollama tags (GGUF Q4_K_M vs MLX nvfp4) as shipped, one-shot prompt. Not matched-quant - see its README. |
| [`gemma4-12b-ollama-gguf-vs-mlx-long`](campaigns/gemma4-12b-ollama-gguf-vs-mlx-long/) | The same as-shipped Ollama tags, sustained-decode prompt - where decode lands a near-tie. |

## Models are not included

Campaigns reference models by a `models/<file>` path **relative to your current working directory** (where you run `ziraph campaign`), or by Ollama tag. The model files are large and are not in this repo; each campaign's README documents exactly how to obtain or build them. Put GGUF/MLX files under `models/` in the directory you run from (`models/` is gitignored). This holds for `remote` runs too - the fetched `campaign.toml` runs against *your* `models/`, never a copy in the repo.

## Results are hardware-specific

Power, energy, and bandwidth depend on the chip. A number from an M1 is not comparable to an M4 Max. When comparing your run to a published reference, compare within the same chip class; the reference figures in each README state the hardware they came from.

## Running a campaign

| Form | What it does |
|---|---|
| `ziraph campaign remote <name>` | Fetch + run a campaign from this registry by name - the easy path. |
| `ziraph campaign remote` | List every available campaign. |
| `ziraph campaign campaigns/<name>/campaign.toml` | Run a local path, after cloning. |
| `ziraph campaign https://github.com/ziraph/…/campaign.toml` | Run a specific URL - the escape hatch for a non-`main` branch or fork. |

`remote` only ever reaches `github.com/ziraph/campaigns` on `main`. ziraph fetches the `campaign.toml`, shows the exact commands it will run, and asks you to confirm before anything executes (`-y` skips the prompt in scripts). Commands run **locally**, through the same no-shell subprocess path as a local run - relative paths (`models/`, `out_dir`) resolve against your current directory, never the download location.

## Scope

These are engineering field-report protocols, not a certified benchmark suite. Each README states its caveats (matched-quant vs as-shipped, single-machine, thermal conditions) plainly. See [CONTRIBUTING.md](CONTRIBUTING.md) to add your own.

---

Part of [Ziraph](https://ziraph.com) - honest local AI profiling for Apple Silicon.
