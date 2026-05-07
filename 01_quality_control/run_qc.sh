#!/usr/bin/env bash
# Quality control and adapter trimming for paired-end Illumina reads
# Sample: green macroalga, raw reads in data/seq_{1,2}.fastq.gz

set -euo pipefail

# ---- Config ----
THREADS=4
MIN_QUAL=20
MIN_LEN=50
SAMPLE="seq"

R1="data/${SAMPLE}_1.fastq.gz"
R2="data/${SAMPLE}_2.fastq.gz"

OUT="1_quality_control/results"
TRIM="1_quality_control/trimmed"

mkdir -p "${OUT}/raw" "${OUT}/trimmed" "${OUT}/fastp" "${TRIM}"

# ---- 1. FastQC on raw reads ----
echo "[1/4] FastQC on raw reads..."
fastqc -t "${THREADS}" -o "${OUT}/raw" "${R1}" "${R2}"

# ---- 2. fastp trimming ----
echo "[2/4] fastp trimming..."
fastp \
  -i "${R1}" -I "${R2}" \
  -o "${TRIM}/${SAMPLE}_1.trimmed.fastq.gz" \
  -O "${TRIM}/${SAMPLE}_2.trimmed.fastq.gz" \
  --detect_adapter_for_pe \
  --qualified_quality_phred "${MIN_QUAL}" \
  --length_required "${MIN_LEN}" \
  --thread "${THREADS}" \
  --html "${OUT}/fastp/${SAMPLE}.html" \
  --json "${OUT}/fastp/${SAMPLE}.json"

# ---- 3. FastQC on trimmed reads ----
echo "[3/4] FastQC on trimmed reads..."
fastqc -t "${THREADS}" -o "${OUT}/trimmed" \
  "${TRIM}/${SAMPLE}_1.trimmed.fastq.gz" \
  "${TRIM}/${SAMPLE}_2.trimmed.fastq.gz"

# ---- 4. MultiQC aggregation ----
echo "[4/4] MultiQC aggregation..."
multiqc "${OUT}" -o "${OUT}/multiqc" --force

echo "Done. Open ${OUT}/multiqc/multiqc_report.html"
