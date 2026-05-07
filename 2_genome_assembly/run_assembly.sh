#!/usr/bin/env bash
# Organelle genome assembly from paired-end Illumina reads
# Sample: green macroalga
# Input:  trimmed reads from step 1
# Output: assembled plastid genome FASTA

set -euo pipefail

# ---- Config ----
THREADS=4
SAMPLE="macroalga"
ORGANELLE="other_pt"        # other_pt = plastid (non-embryophyte); other_mt = mitochondrion
KMERS="21,45,65,85,105"     # default k-mer ladder
ROUNDS=10                   # max extension rounds

R1="1_quality_control/trimmed/seq_1.trimmed.fastq.gz"
R2="1_quality_control/trimmed/seq_2.trimmed.fastq.gz"

OUT="2_organelle_assembly/results/${SAMPLE}_${ORGANELLE}"
FINAL="2_organelle_assembly/${SAMPLE}.organelle.fasta"

mkdir -p "$(dirname "${OUT}")"

# ---- Run GetOrganelle ----
echo "[1/2] Assembling ${ORGANELLE} from ${SAMPLE}..."
get_organelle_from_reads.py \
  -1 "${R1}" -2 "${R2}" \
  -o "${OUT}" \
  -F "${ORGANELLE}" \
  -R "${ROUNDS}" \
  -k "${KMERS}" \
  -t "${THREADS}"

# ---- Collect the final assembly ----
# GetOrganelle outputs *path_sequence.fasta (one per resolved path)
echo "[2/2] Copying final assembly..."
cp "${OUT}"/*path_sequence.fasta "${FINAL}"

# Quick sanity check
seqkit stats "${FINAL}"

echo "Done. Final assembly: ${FINAL}"
