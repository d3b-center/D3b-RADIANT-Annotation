# Slivar Compound Hets

The workflow also contains the option to discover compound hets. The process uses Slivar and follows the rare disease
discovery methods detailed here: https://github.com/brentp/slivar/wiki/rare-disease

Our implementation relies on the following INFO fields being present:
- `CSQ` (from VEP)
- `topmed_af` (we add this during the slivar expr command using the `--slivar_zips` input)
- `gnomad_3_1_1_AF_popmax` and `gnomad_3_1_1_nhomalt` (we add this during ectvar anno using the `--echtvar_zips` input)

## Additional notes about the importance of the rare disease filtering parameters

Variant quality (min_GQ: 20, min_AB: 0.20, min_DP: 6, min_male_X_GQ: 10, min_male_X_DP: 6):
The recommended quality thresholds are pretty standard in my opinion and reduces false positives.
These are pre-coded in the default slivar-functions.js script but can be adjusted.

Population frequency (gnomad_3_1_1_AF_popmax < 0.001, gnomad_3_1_1_nhomalt < 10, topmed_af < 0.05):
I think these thresholds are relevant and necessary for rare diseases, else we would have a lot of
variants that most likely don’t really contribute to the phenotype. From my tests, adding topmed did not make much
difference in the number of variants, but I did not use real patient data and it is quick to add the annotation directly
with slivar at the filtering stage.

Impact (compound-hets --skip default: splice_region,intergenic_region,intron,non_coding_transcript,non_coding,upstream_gene,downstream_gene,non_coding_transcript_exon,NMD_transcript,5_prime_UTR,3_prime_UTR):
This is the filter that makes the most difference in the resulting number of variants. Slivar has a default
order to rank the impact and to signal the cut-off, and it can also be adjusted. We are still in discussions on how
stringent we want to be on the impact filter, but I do think filtering on this has advantages.

It can also be run on duos/solos adjusting the filtering expression and by using —allow-non-trios in the comphet
command. The comphet filter for solos is just checking that the sample is het, for duos it is checking that the parent
is het or hom_ref and that the sample is het. Information of extended family is not considered in the comphet
calculation as far as I understand, but it can be considered when assigning MOIs.
