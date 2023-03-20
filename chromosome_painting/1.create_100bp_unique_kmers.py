#!/usr/bin/env python3
import sys
import subprocess
from Bio import SeqIO
from collections import Counter
from Bio.Blast.Applications import NcbiblastnCommandline
import tempfile

def split_sequence(reference_id, seq, segment_length, unfiltered_output_file, filtered_output_file):
    segments = [seq[i:i + segment_length] for i in range(0, len(seq) - segment_length + 1, segment_length)]

    with open(unfiltered_output_file, "a") as f_unfiltered:
        with open(filtered_output_file, "a") as f_filtered:
            for i, segment in enumerate(segments):
                start, end = i * segment_length + 1, (i + 1) * segment_length
                f_unfiltered.write(f">{reference_id}:{start}-{end}\n{segment}\n")

                if segment.upper().count("N") == 0:
                    f_filtered.write(f">{reference_id}:{start}-{end}\n{segment}\n")

def blast_sequences(input_file, db_name):
    blastn_cline = NcbiblastnCommandline(query=input_file, db=db_name, outfmt=6, out="blast_results.txt", num_threads=10)
    stdout, stderr = blastn_cline()

def filter_blast_results(identity_threshold, length_threshold):
    filtered_segments = []
    all_segments = []
    with open("blast_results.txt", "r") as f:
        for line in f:

            fields = line.strip().split("\t")
            query_id, subject_chr, subject_start, subject_end, identity, length = fields[0], fields[1], fields[8], fields[9], float(fields[2]), int(fields[3])

            #all queries, we will remove the filtered ones from this list
            all_segments.append(query_id)
            subject_id = subject_chr + ":" + subject_start + "-" + subject_end

            #grab the baddies
            if query_id != subject_id and identity >= 70 and length >= 80:
                filtered_segments.append(query_id)
                continue

    unique = set(filtered_segments)
    remove_these = list(unique)
    uniqueall = set(all_segments)
    all_segs = list(uniqueall)
    print(round(len(unique) / len(all_segs),2),"% of windows removed, approximately:",((len(all_segs) - len(unique)) * 100 ) / 1000000000, "Gb left for analysis")

    good_segments = list((Counter(all_segs) - Counter(remove_these)).elements())
    print(len(good_segments))

    return good_segments

def seqtk_subset_fasta(input_fasta, retained_ids, output_fasta):
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as temp_file:
        temp_file.writelines(f"{seq_id}\n" for seq_id in retained_ids)
        temp_file.flush()
        subprocess.run(["seqtk", "subseq", input_fasta, temp_file.name], stdout=open(output_fasta, "w"))

def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} input.fasta")
        sys.exit(1)

    input_file = sys.argv[1]
    # Read input FASTA file
    seq_records = list(SeqIO.parse(input_file, "fasta"))

    # Clear the output files before writing
    open("unfiltered_segments.fasta", "w").close()
    open("filtered_segments.fasta", "w").close()

    for seq_record in seq_records:
        seq = str(seq_record.seq)
        reference_id = seq_record.id

        # Divide sequence into 100-base pair segments and write to files
        split_sequence(reference_id, seq, 100, "unfiltered_segments.fasta", "filtered_segments.fasta")

    # Create BLAST database from the input FASTA file
    subprocess.run(["makeblastdb", "-in", input_file, "-dbtype", "nucl", "-out", "input_db"])

    # Perform BLAST search
    blast_sequences("filtered_segments.fasta", "input_db")

    # Filter BLAST results
    good_segments = filter_blast_results(70, 50)
    
    input_fasta = "filtered_segments.fasta"
    retained_ids = good_segments
    print(len(retained_ids))
    output_fasta = "unique_segments.fasta"

    seqtk_subset_fasta(input_fasta, retained_ids, output_fasta)

if __name__ == "__main__":
    main()
