#!/usr/bin/env bash
# Step 3 — Mapping and IGV tracks
# Generates GC-content bedGraph and sorted/indexed BAM for IGV inspection.

set -euo pipefail

# ---- Config ----
THREADS=4
WINDOW=50
SAMPLE="macroalga"

ASSEMBLY="2_organelle_assembly/${SAMPLE}.getorganelle.fasta"
R1="1_quality_control/trimmed/seq_1.trimmed.fastq.gz"
R2="1_quality_control/trimmed/seq_2.trimmed.fastq.gz"

OUT="3_mapping_and_tracks/results"
MAP="${OUT}/mapping"
mkdir -p "${MAP}"

# Working copy of the assembly inside the step folder, so all derived
# index files (.fai, .bt2, ...) live alongside the outputs and never
# pollute step 2.
REF="${OUT}/${SAMPLE}.getorganelle.fasta"
cp "${ASSEMBLY}" "${REF}"

# ============================================================
# 1. Generate a GC track
# ============================================================
echo "[1/8] Indexing assembly..."
samtools faidx "${REF}"

echo "[2/8] Creating ${WINDOW} bp windows..."
bedtools makewindows -g "${REF}.fai" -w "${WINDOW}" \
  > "${OUT}/${SAMPLE}.${WINDOW}bp.windows.bed"

echo "[3/8] Calculating GC content per window..."
bedtools nuc -fi "${REF}" \
  -bed "${OUT}/${SAMPLE}.${WINDOW}bp.windows.bed" \
  > "${OUT}/${SAMPLE}.${WINDOW}bp.gc.tsv"

echo "[4/8] Converting to bedGraph and sorting..."
# bedGraph columns: chrom, start, end, GC%
tail -n +2 "${OUT}/${SAMPLE}.${WINDOW}bp.gc.tsv" \
  | awk '{ printf("%s\t%d\t%d\t%.2f\n", $1, $2, $3, $5 * 100) }' \
  | sort -k1,1 -k2,2n \
  > "${OUT}/${SAMPLE}.${WINDOW}bp.gc.sorted.bedGraph"

# ============================================================
# 2. Generate coverage information
# ============================================================
echo "[5/8] Building Bowtie2 index..."
bowtie2-build "${REF}" "${REF}"

echo "[6/8] Aligning paired-end reads with Bowtie2..."
# On a Slurm cluster, prepend:
#   srun --cpus-per-task ${THREADS} --mem=50G
bowtie2 \
  -p "${THREADS}" -q --no-unal \
  -x "${REF}" \
  -1 "${R1}" -2 "${R2}" \
  2> "${MAP}/align_stats.txt" \
  | samtools view -@ "${THREADS}" -Sb -o "${MAP}/${SAMPLE}_bowtie2.bam"

cat "${MAP}/align_stats.txt"

echo "[7/8] Filtering unmapped reads and sorting BAM..."
samtools view -u -F 4 "${MAP}/${SAMPLE}_bowtie2.bam" \
  | samtools sort -@ "${THREADS}" -o "${MAP}/${SAMPLE}_sorted.bam"

echo "[8/8] Indexing sorted BAM..."
samtools index "${MAP}/${SAMPLE}_sorted.bam"

echo
echo "Done."
echo "  GC track:  ${OUT}/${SAMPLE}.${WINDOW}bp.gc.sorted.bedGraph"
echo "  BAM file:  ${MAP}/${SAMPLE}_sorted.bam"
