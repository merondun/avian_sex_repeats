#!/usr/bin/env python3
import sys
import subprocess
from Bio.Blast.Applications import NcbiblastnCommandline

def blast_sequences(query_file, db_name, output_file):
    blastn_cline = NcbiblastnCommandline(
        query=query_file,
        db=db_name,
        outfmt="6 qseqid sseqid pident qstart qend sstart send sstrand",
        max_target_seqs=1,
        max_hsps=1,
        out=output_file
    )
    stdout, stderr = blastn_cline()

def parse_blast_output(output_file):
    with open(output_file, "r") as f:
        for line in f:
            fields = line.strip().split("\t")
            qseqid, sseqid, pident = fields[:3]
            qstart, qend, sstart, send, sstrand = fields[3:]

            if sstrand == "-":
                sstart, send = send, sstart

            yield sseqid, sstart, send, qseqid, pident, sstrand

def write_bed_file(blast_results, output_file):
    with open(output_file, "w") as f:
        for result in blast_results:
            f.write("\t".join(map(str, result)) + "\n")

def main():
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} target.fasta reference.fasta output.bed")
        sys.exit(1)

    target_file, reference_file, output_bed = sys.argv[1:]

    # Create BLAST database from the reference FASTA file
    subprocess.run(["makeblastdb", "-in", reference_file, "-dbtype", "nucl", "-out", "reference_db"])

    # Perform BLAST search
    blast_output = "blast_results.txt"
    blast_sequences(target_file, "reference_db", blast_output)

    # Parse BLAST output and convert to BED format
    blast_results = list(parse_blast_output(blast_output))

    # Write BED file
    write_bed_file(blast_results, output_bed)

if __name__ == "__main__":
    main()

