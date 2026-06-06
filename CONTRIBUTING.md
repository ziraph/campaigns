# Contributing a campaign

Campaigns here are reproducible measurement protocols. The bar is honesty and reproducibility, not polish.

## Layout

Add a folder under `campaigns/<name>/` with **exactly one** `campaign.toml`:

```
campaigns/<name>/
  campaign.toml          # exactly one TOML per subdir, always named campaign.toml
  README.md              # required - see below
  results/               # optional - reference summaries + compare table from your run
```

One campaign per subdir - the subdir name *is* the campaign id (`ziraph campaign remote <name>` resolves it to that single `campaign.toml`). If you have regimes (short / long), make them **separate** subdirs - `<name>-short/`, `<name>-long/` - and cross-link their READMEs. Set each `out_dir` to `campaign-out/<name>` so runs don't collide, add the campaign to [`campaigns/index.json`](campaigns/index.json) (the list `ziraph campaign remote` shows), and check `scripts/check-campaigns.sh` passes.

## The TOML

- Reference models by a **`models/<file>` path relative to the working directory** ziraph runs in (not the repo, not the TOML's location) - or by tool tag (e.g. an Ollama tag). Never an absolute path: no `/Users/<you>/…` paths - they leak your machine, break for everyone else, and can't work for a `remote` run (the fetched TOML runs against the user's own `models/`).
- Keep the methodology explicit: `runs_per_variant`, a `[methodology]` (warmup/cooldown), and a `schedule`. State why the schedule is safe (co-residency, memory).
- See the [`campaign.toml` reference](https://ziraph.com/docs/reference/campaign) and the [N×M guide](https://ziraph.com/docs/guides/nxm-multi-variant-campaign).

## The README must state

1. **What it measures** and what is held constant vs varied.
2. **Model acquisition** - exact tags / download / build steps for every model the TOML names.
3. **Honesty caveats** - if it is not matched-quant, say so and say what a delta actually blends (engine vs quant vs scope). Do not call a cross-quant comparison "same weights."
4. **Reference hardware** - the chip + RAM your reference figures came from. Power/energy/bandwidth are chip-specific and not cross-comparable.
5. **Thermal conditions** - quiet machine, display state, anything that affects the measurement.

## Roadmap

- **Phase 1 (now):** run a published campaign by its `github.com/ziraph` URL (`ziraph campaign <url>`), or clone and pass a local path. Remote URLs are restricted to the Ziraph org, and ziraph previews every command before it runs.
- **Phase 2:** provenance / signing for trusted sources.
- **Phase 3:** community-contributed campaigns and private-org registries.

Open a PR. Keep the voice plain and the caveats up front.
