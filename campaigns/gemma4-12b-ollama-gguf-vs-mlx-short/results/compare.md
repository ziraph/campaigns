## Compare: ollama-gguf-summary.json vs ollama-mlx-summary.json

> Aggregate across 3 run(s) per side; ± values are across-run σ

| Metric (unit) | Variant A | Variant B | Δ | Δ% | Sig |
|:---|---:|---:|---:|---:|:---:|
| energy_per_token (J/tok) | 1.331 ± 0.032 | 1.436 ± 0.094 | +0.1053 ± 0.0937 | +8% (A) | ≈2σ |
| tokens_per_second (tok/s) | 5.54 ± 0.47 | 5.27 ± 0.32 | -0.273 ± 0.471 | -5% (A) | ≈1σ |
| reported decode (tok/s) | 7.063 | 6.750 | -0.3133 | -4% (A) | — |
| non-decode overhead (%) | 21.52 | 21.93 | +0.4067 | +2% (A) | — |
| tokens_total (tok) | 436.0 | 469.0 | +33.00 | +8% (B) | — |
| mean_ane (J) | 0.0000 ± 0.0000 | 0.0000 ± 0.0000 | +0.0000 ± 0.0000 | — | — |
| mean_gpu (J) † | 184 ± 9 | 193 ± 15 | +9.2 ± 15.1 | +5% (A) | ≈1σ |
| mean_cpu (J) † | 22 ± 6 | 45 ± 16 | +24 ± 16 | +110% (A) | SIG ⭐ |
| duration (s) | 26.22 | 29.67 | +3.447 | +13% (A) | — |
| mean_ane (mW) | 0.0000 ± 0.0000 | 0.0000 ± 0.0000 | +0.0000 ± 0.0000 | — | — |
| mean_gpu (W) | 6.76 ± 0.50 | 6.233 ± 0.088 | -0.525 ± 0.500 | -8% (B) | ≈2σ |
| mean_cpu (W) | 0.986 ± 0.135 | 1.64 ± 0.29 | +0.650 ± 0.291 | +66% (A) | SIG ⭐ |
| Media Engine (W) | 0.0212 | 0.0262 | +0.0050 | +24% (A) | — |
| peak Media Engine (W) | 0.0275 | 0.0316 | +0.0041 | +15% (A) | — |
| peak accel DRAM bw (MB/s) | 56018 | 56249 | +231.1 | +0% (B) | — |
| avg power (W) | 7.881 | 8.019 | +0.1383 | +2% (A) | — |

> **†** system-wide (upper bound) — upper bound, not process-attributed;
> other GPU users may have been active during the run.

### Bottleneck hints

- **Variant A:** Unattributed GPU load during run
- **Variant B:** Unattributed GPU load during run
- **Match** — both traces fired: Unattributed GPU load during run
