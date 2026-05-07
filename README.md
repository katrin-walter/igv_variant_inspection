# igv_variant_inspection
This project provides a directly applicable protocol for inspecting short-read alignments in IGV (Integrative Genomics Viewer), covering three core tasks: visual verification of called variants, coverage analysis, and identification of mismatches. The workflow was developed using Illumina reads from a green macroalga aligned against its reference genome. Each step is documented to be reproducible on any BAM/reference pair, regardless of organism. The result is a concise, hands-on reference for quality-controlling variant calls before downstream analysis. It is aimed at users who need to move beyond automated caller output and confirm what the reads actually support.

The main steps covered:

```
├── README.md
├── 01_quality_control
│   ├── README.md 
│   ├── environment.yml
│   └── run_qc.sh
├── 02_genome_assembly
│   ├── README.md
│   ├── environment.yml
│   └── run_assembly.sh
└── 03_mapping
    ├── README.md
    ├── environment.yml
    └── run_maping.sh
```

Visualize data 
1. Load the reference genome into IGV
2. Load the annotation file (optional)
3. Index your GFF file
4. Load the GC content track
5. Load the read alignment (coverage)

After loading all files into IGV, you should see your reads and GC:
<p align="right">
  <img src="img/macroalga_getorganelle.jpg" width="500">
</p>
