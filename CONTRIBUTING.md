# Contributing a campaign

Campaigns here are reproducible measurement protocols. The bar is honesty and reproducibility, not polish.

## Layout

Add a folder under `campaigns/<name>/`:

```
campaigns/<name>/
  campaign.toml          # or campaign-short.toml / campaign-long.toml for regimes
  README.md              # required - see below
  results/               # optional - reference trace(s) from your run, for comparison
```

## The TOML

- Reference models by a **relative `models/<file>` path** or by tool tag (e.g. an Ollama tag), never an absolute path. No `/Users/<you>/…` paths - they leak your machine and break for everyone else.
- Keep the methodology explicit: `runs_per_variant`, a `[methodology]` (warmup/cooldown), and a `schedule`. State why the schedule is safe (co-residency, memory).
- See the [`campaign.toml` reference](https://ziraph.com/docs/reference/campaign) and the [N×M guide](https://ziraph.com/docs/guides/nxm-multi-variant-campaign).

## The README must state

1. **What it measures** and what is held constant vs varied.
2. **Model acquisition** - exact tags / download / build steps for every model the TOML names.
3. **Honesty caveats** - if it is not matched-quant, say so and say what a delta actually blends (engine vs quant vs scope). Do not call a cross-quant comparison "same weights."
4. **Reference hardware** - the chip + RAM your reference figures came from. Power/energy/bandwidth are chip-specific and not cross-comparable.
5. **Thermal conditions** - quiet machine, display state, anything that affects the measurement.

## Roadmap

- **Phase 1 (now):** clone + run locally. Remote pull (`ziraph campaign <url>`) is tracked at [ziraph#1212](https://github.com/mabis/ziraph/issues/1212) and will be restricted to `github.com/ziraph/*` first, with a mandatory preview of every command before execution.
- **Phase 2:** provenance / signing for trusted sources.
- **Phase 3:** community-contributed campaigns and private-org registries.

Open a PR. Keep the voice plain and the caveats up front.
