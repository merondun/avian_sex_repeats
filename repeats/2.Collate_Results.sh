#!/bin/bash

# Remove old files
rm -f collated_outputs/highLevelCounts.txt collated_outputs/familyLevelCounts.txt collated_outputs/divergence_summary.txt collated_outputs/missing_files.txt

echo "Collating EarlGrey Results"

# Initialize a flag to indicate if the header should be skipped for each type of output
skip_highLevelCount_header=false
skip_familyLevelCount_header=false
skip_divergence_summary_header=false

# Read species list
while read SPECIES; do
    # Loop through chromosome types
    for CHR in Z W; do
        # Define base path for easier access
        base_path="output/${SPECIES}_${CHR}/${SPECIES}_EarlGrey/${SPECIES}_summaryFiles"

        # Initialize a flag to check file existence
        file_missing=false

        # Check and process highLevelCount
        if [ -f "${base_path}/${SPECIES}.highLevelCount.txt" ]; then
            if $skip_highLevelCount_header; then
                awk 'FNR > 1' "${base_path}/${SPECIES}.highLevelCount.txt" | awk -v c="${CHR}" -v s="${SPECIES}" 'BEGIN {OFS="\t"} {print $0, c, s}' >> collated_outputs/highLevelCounts.txt
            else
                awk -v c="${CHR}" -v s="${SPECIES}" 'BEGIN {OFS="\t"} {print $0, c, s}' "${base_path}/${SPECIES}.highLevelCount.txt" >> collated_outputs/highLevelCounts.txt
                skip_highLevelCount_header=true
            fi
        else
            file_missing=true
        fi

        # Check and process familyLevelCount
        if [ -f "${base_path}/${SPECIES}.familyLevelCount.txt" ]; then
            if $skip_familyLevelCount_header; then
                awk 'FNR > 1' "${base_path}/${SPECIES}.familyLevelCount.txt" | awk -v c="${CHR}" -v s="${SPECIES}" 'BEGIN {OFS="\t"} {print $0, c, s}' >> collated_outputs/familyLevelCounts.txt
            else
                awk -v c="${CHR}" -v s="${SPECIES}" 'BEGIN {OFS="\t"} {print $0, c, s}' "${base_path}/${SPECIES}.familyLevelCount.txt" >> collated_outputs/familyLevelCounts.txt
                skip_familyLevelCount_header=true
            fi
        else
            file_missing=true
        fi

        # Check and process divergence_summary_table
        if [ -f "${base_path}/${SPECIES}_divergence_summary_table.tsv" ]; then
            if $skip_divergence_summary_header; then
                awk 'FNR > 1' "${base_path}/${SPECIES}_divergence_summary_table.tsv" | awk -v c="${CHR}" -v s="${SPECIES}" 'BEGIN {OFS="\t"} {print $0, c, s}' >> collated_outputs/divergence_summary.txt
            else
                awk -v c="${CHR}" -v s="${SPECIES}" 'BEGIN {OFS="\t"} {print $0, c, s}' "${base_path}/${SPECIES}_divergence_summary_table.tsv" >> collated_outputs/divergence_summary.txt
                skip_divergence_summary_header=true
            fi
        else
            file_missing=true
        fi

        # Log missing files
        if [ "$file_missing" = true ]; then
            echo "${SPECIES} ${CHR}" >> collated_outputs/missing_files.txt
        fi
    done
done < Species.list

echo "Collation complete. Check 'collated_outputs/missing_files.txt' for any missing files."
