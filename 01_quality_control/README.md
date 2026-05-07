# Step 1 — Read quality control

Before any alignment goes into IGV, the reads themselves need to pass QC.
This step runs FastQC on the raw input, trims adapters and low-quality bases
with fastp, re-runs FastQC on the trimmed output, and aggregates everything
into a single MultiQC report for side-by-side comparison.

## Tools

| Tool    | Purpose                                  |
|---------|------------------------------------------|
| FastQC  | per-file quality reports (raw + trimmed) |
| fastp   | adapter detection and quality trimming   |
| MultiQC | aggregated HTML summary across stages    |

## Setup (once)

```bash
mamba env create -f 1_quality_control/environment.yml
mamba activate qc
```

## Run

Place the paired-end reads at `data/seq_1.fastq.gz` and `data/seq_2.fastq.gz`,
then from the repository root:

```bash
bash 1_quality_control/run_qc.sh
```

## Pipeline

1. **FastQC** on raw reads — baseline assessment
2. **fastp** — adapter trimming, Q20 quality filter, minimum length 50 bp
3. **FastQC** on trimmed reads — verify the trimming worked
4. **MultiQC** — aggregate all reports into one HTML summary

## Outputs

| Path                                       | Contents                            |
|--------------------------------------------|-------------------------------------|
| `1_quality_control/results/raw/`           | FastQC reports on raw reads         |
| `1_quality_control/results/trimmed/`       | FastQC reports on trimmed reads     |
| `1_quality_control/results/fastp/`         | fastp HTML + JSON report            |
| `1_quality_control/results/multiqc/`       | aggregated MultiQC report           |
| `1_quality_control/trimmed/`               | trimmed FASTQ files for next step   |

## What to check in the report

- **Per-base sequence quality** — median Q ≥ 28 across the full read length
- **Adapter content** — flat at zero after trimming
- **% reads passing fastp filter** — typically > 90%; lower values warrant a
  parameter review
- **GC content** — a bimodal distribution in macroalgal samples often
  indicates contamination from associated microbes or epiphytes and should
  be flagged before downstream analysis

## Trimming parameters

| Parameter                   | Value | Rationale                                       |
|-----------------------------|-------|-------------------------------------------------|
| `--qualified_quality_phred` | 20    | standard Q20 threshold                          |
| `--length_required`         | 50    | discard reads too short for unique mapping      |
| `--detect_adapter_for_pe`   | on    | automatic adapter detection in paired-end mode  |

Adjust in the config block at the top of `run_qc.sh` if needed.
