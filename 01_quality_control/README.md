Before any alignment goes into IGV, the reads themselves need to pass QC.
This step runs FastQC on the raw input, trims adapters and low-quality bases
with fastp, re-runs FastQC on the trimmed output, and produces a single
MultiQC report summarising both stages side by side


Setup (once)

```
mamba env create -f 1_quality_control/environment.yml
mamba activate qc
```
