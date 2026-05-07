# Step 2 — Organelle genome assembly

Assembles the plastid genome of a green macroalga from paired-end Illumina
reads using GetOrganelle. The resulting FASTA serves as the reference for
read mapping in step 3 and for visual inspection in IGV.

## Tools

| Tool         | Purpose                                  |
|--------------|------------------------------------------|
| GetOrganelle | targeted organelle genome assembly       |
| SeqKit       | FASTA statistics and manipulation        |
| BLAST+       | optional sanity check against NCBI       |

## Setup (once)

```bash
mamba env create -f 2_organelle_assembly/environment.yml
mamba activate assembly
get_organelle_config.py --add other_pt,other_mt
```

For green algae (Chlorophyta) use `other_pt` / `other_mt`, not the
embryophyte-specific databases.

## Run

From the repository root:

```bash
bash 2_organelle_assembly/run_assembly.sh
```

Input: trimmed reads from step 1
Output: `2_organelle_assembly/macroalga.getorganelle.fasta`

## Key parameters

| Parameter | Value             | Rationale                                     |
|-----------|-------------------|-----------------------------------------------|
| `-F`      | `other_pt`        | plastid database for non-embryophyte taxa     |
| `-k`      | 21,45,65,85,105   | default k-mer ladder, robust across coverage  |
| `-R`      | 10                | extension rounds; raise for low-coverage data |

## Quality checks

- Total length ~100–200 kb for a green algal plastome
- Header ideally marked as `(circular)`
- BLAST of a few kb against NCBI nt should hit related green algal plastids
- Assembly graph in Bandage shows the typical quadripartite plastome structure
