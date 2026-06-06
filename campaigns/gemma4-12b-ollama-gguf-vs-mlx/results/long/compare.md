## Compare: ollama-gguf-summary.json vs ollama-mlx-summary.json

> Aggregate across 3 run(s) per side; ± values are across-run σ

| Metric (unit) | Variant A | Variant B | Δ | Δ% | Sig |
|:---|---:|---:|---:|---:|:---:|
| energy_per_token (J/tok) | 0.9868 ± 0.0196 | 0.9927 ± 0.0157 | +0.0059 ± 0.0196 | +1% (A) | ≈1σ |
| tokens_per_second (tok/s) | 6.517 ± 0.016 | 6.506 ± 0.023 | -0.0115 ± 0.0230 | -0% (A) | ≈1σ |
| reported decode (tok/s) | 6.663 | 6.647 | -0.0167 | -0% (A) | — |
| non-decode overhead (%) | 2.193 | 2.121 | -0.0724 | -3% (B) | — |
| tokens_total (tok) | 5602 | 5144 | -458.0 | -8% (A) | — |
| mean_ane (J) | 0.0000 ± 0.0000 | 0.0000 ± 0.0000 | +0.0000 ± 0.0000 | — | — |
| mean_gpu (J) † | 1815 ± 87 | 1665 ± 65 | -150 ± 87 | -8% (B) | SIG ⭐ |
| mean_cpu (J) † | 71 ± 4 | 80 ± 1 | +8.6 ± 3.8 | +12% (A) | SIG ⭐ |
| duration (s) | 286.5 | 263.5 | -23.01 | -8% (B) | — |
| mean_ane (mW) | 0.0000 ± 0.0000 | 0.0000 ± 0.0000 | +0.0000 ± 0.0000 | — | — |
| mean_gpu (W) | 6.31 ± 0.13 | 6.289 ± 0.067 | -0.017 ± 0.130 | -0% (B) | ≈1σ |
| mean_cpu (W) | 0.26625 ± 0.00586 | 0.32165 ± 0.00395 | +0.05540 ± 0.00586 | +21% (A) | SIG ⭐ |
| Media Engine (W) | 0.0262 | 0.0281 | +0.0020 | +8% (A) | — |
| peak Media Engine (W) | 0.0302 | 0.0307 | +0.0005 | +2% (A) | — |
| peak accel DRAM bw (MB/s) | 52711 | 58769 | +6058 | +11% (B) | — |
| avg power (W) | 6.579 | 6.619 | +0.0402 | +1% (A) | — |

> **†** system-wide (upper bound) — upper bound, not process-attributed;
> other GPU users may have been active during the run.

### Bottleneck hints

- **Variant A:** Unattributed GPU load during run
- **Variant B:** Unattributed GPU load during run
- **Match** — both traces fired: Unattributed GPU load during run
