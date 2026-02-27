# D3b RADIANT Annotation

<p align="center">
  <img src="docs/logo/d3b-inline-white.svg" alt="D3b repository logo" width="660px" />
</p>
<p align="center">
  <a href="https://github.com/d3b-center/D3b-RADIANT-Annotation/blob/master/LICENSE"><img src="https://img.shields.io/github/license/d3b-center/D3b-RADIANT-Annotation.svg?style=for-the-badge"></a>
</p>

Simple workflow to reannotate Kids First VEPs to be compatible with the RADIANT framework.
However, this can also be used to annotate/reannotate any other VCF as needed to ensure the following requirements are met:
 - Old annotations are stripped
 - VCF is normalized
 - VCF is annotated with VEP
 - Exomiser is run
## Tools Run
 - `bcftools strip`: Uses `annotate` to remove existing VEP (`CSQ`) and gnomad 3.1.1 (`gnomad_3_1_1*`) annotations
 - `bcftools norm`: Uses `norm` to split (or join) mulit-allelics and normalize indels
 - `VEP`: Uses cache 111 and meets the following specific criteria:
    ```
    --canonical
    --format vcf 
    --hgvs 
    --hgvsg 
    --no_stats 
    --numbers 
    --offline 
    --fields Allele,Consequence,IMPACT,SYMBOL,Feature_type,Gene,PICK,Feature,EXON,BIOTYPE,INTRON,HGVSc,HGVSp,STRAND,CDS_position,cDNA_position,Protein_position,Amino_acids,Codons,VARIANT_CLASS,HGVSg,CANONICAL,RefSeq,MANE,MANE_SELECT,MANE_PLUS 
    --flag_pick 
    --mane 
    --mane_select 
    --pick_order rank,biotype,mane_select,mane_plus_clinical,canonical,appris,tsl,ccds,length,ensembl,refseq 
    --symbol 
    --variant_class 
    --vcf 
    --xref_refseq 
    --compress_output bgzip
    --fasta Homo_sapiens_assembly38.fasta
    --assembly GRCh38
    --species homo_sapiens
    --cache
    --cache_version 111
    ```
 - `exomiser`: "The Exomiser is a Java program that finds potential disease-causing variants from whole-exome or whole-genome sequencing data." See https://github.com/exomiser/Exomiser for more details

 ## Inputs
 What is "required" or not depends upon the input. The **Required** inputs are based on Kids First Processed VCFs. You may use the disable_(insert_step) flags to skip any step not needed based on the input.
 ### Required - Need to provide
 - `vcf`: KF VCF to process
 - `vcf_index` = Index of `vcf`
 - `output_basename`: String prefix of file outputs. Technically optional, but strongly recommended. Default is `TEST`
#### VEP
 - `vep_cache`: VEP cache for annotation. Recommend 111, `homo_sapiens_vep_111_GRCh38.tar.gz` 
 - `fasta`: FASTA used during variant calling. Recommend `Homo_sapiens_assembly38.fasta`
#### EXOMISER
 - `analysis_file`: YAML with analysis options. See https://exomiser.readthedocs.io/en/latest/advanced_analysis.html#analysis. Recommend `default_exomiser_WGS_analysis.yml`
 - `datadir_file`: TAR GZ with referenece files. Example contents:
    ```
    data/
    data/remm/
    data/remm/ReMM.v0.4.hg38.tsv.gz.tbi
    data/remm/ReMM.v0.4.hg38.tsv.gz
    data/2406_hg38.sha256
    data/2406_hg38/
    data/2406_hg38/2406_hg38_transcripts_refseq.ser
    data/2406_hg38/2406_hg38_transcripts_ensembl.ser
    data/2406_hg38/2406_hg38_genome.mv.db
    data/2406_hg38/2406_hg38_variants.mv.db
    data/2406_hg38/2406_hg38_transcripts_ucsc.ser
    data/2406_hg38/2406_hg38_clinvar.mv.db
    data/cadd/
    data/cadd/1.7/
    data/cadd/1.7/whole_genome_SNVs.tsv.gz
    data/cadd/1.7/whole_genome_SNVs.tsv.gz.tbi
    data/cadd/1.7/gnomad.genomes.r4.0.indel.tsv.gz
    data/cadd/1.7/gnomad.genomes.r4.0.indel.tsv.gz.tbi
    data/2406_phenotype/
    data/2406_phenotype/2406_phenotype.mv.db
    data/2406_phenotype/rw_string_10.mv
    data/2406_phenotype/phenix/
    data/2406_phenotype/phenix/out/
    data/2406_phenotype/phenix/out/10.out
    data/2406_phenotype/phenix/out/9_symmetric.out
    data/2406_phenotype/phenix/out/14.out
    data/2406_phenotype/phenix/out/13_symmetric.out
    data/2406_phenotype/phenix/out/20.out
    data/2406_phenotype/phenix/out/19.out
    data/2406_phenotype/phenix/out/16_symmetric.out
    data/2406_phenotype/phenix/out/7.out
    data/2406_phenotype/phenix/out/3_symmetric.out
    data/2406_phenotype/phenix/out/8.out
    data/2406_phenotype/phenix/out/17_symmetric.out
    data/2406_phenotype/phenix/out/15_symmetric.out
    data/2406_phenotype/phenix/out/5_symmetric.out
    data/2406_phenotype/phenix/out/11.out
    data/2406_phenotype/phenix/out/14_symmetric.out
    data/2406_phenotype/phenix/out/8_symmetric.out
    data/2406_phenotype/phenix/out/10_symmetric.out
    data/2406_phenotype/phenix/out/1.out
    data/2406_phenotype/phenix/out/20_symmetric.out
    data/2406_phenotype/phenix/out/11_symmetric.out
    data/2406_phenotype/phenix/out/18_symmetric.out
    data/2406_phenotype/phenix/out/4.out
    data/2406_phenotype/phenix/out/19_symmetric.out
    data/2406_phenotype/phenix/out/2.out
    data/2406_phenotype/phenix/out/12.out
    data/2406_phenotype/phenix/out/15.out
    data/2406_phenotype/phenix/out/2_symmetric.out
    data/2406_phenotype/phenix/out/9.out
    data/2406_phenotype/phenix/out/17.out
    data/2406_phenotype/phenix/out/16.out
    data/2406_phenotype/phenix/out/6_symmetric.out
    data/2406_phenotype/phenix/out/13.out
    data/2406_phenotype/phenix/out/18.out
    data/2406_phenotype/phenix/out/3.out
    data/2406_phenotype/phenix/out/4_symmetric.out
    data/2406_phenotype/phenix/out/1_symmetric.out
    data/2406_phenotype/phenix/out/7_symmetric.out
    data/2406_phenotype/phenix/out/6.out
    data/2406_phenotype/phenix/out/5.out
    data/2406_phenotype/phenix/out/12_symmetric.out
    data/2406_phenotype/phenix/hp.obo
    data/2406_phenotype/phenix/ALL_SOURCES_ALL_FREQUENCIES_genes_to_phenotype.txt
    data/2406_phenotype/hp.obo
    ```
 - `pheno_file`: YAML file with sample information
    - Individual example:
      ```yaml
        ---
        id: FM_ZCF17CPC
        proband:
        subject:
            id: BS_4JPDCXVR
            sex: MALE
        phenotypicFeatures:
            - type:
                id: HP:0009733
                label: Glioma
        pedigree:
        persons:
            - individualId: BS_4JPDCXVR
            sex: MALE
            affectedStatus: AFFECTED

        metaData:
        resources:
            - id: hp
            name: human phenotype ontology
            url: http://purl.obolibrary.org/obo/hp.owl
            version: hp/releases/2019-11-08
            namespacePrefix: HP
            iriPrefix: 'http://purl.obolibrary.org/obo/HP_'
        phenopacketSchemaVersion: 2.0
      ```
    - Family example:
       ```yaml
        ---
        id: FM_ASMHHE2N
        proband:
        subject:
            id: BS_KPAR4N94
            sex: MALE
        phenotypicFeatures:
            - type:
                id: HP:0009733
        pedigree:
        persons:
            - individualId: BS_KPAR4N94
            sex: MALE
            paternalId: BS_264QQD38
            maternalId: BS_EQ98CJJT
            affectedStatus: AFFECTED
            - individualId: BS_264QQD38
            sex: MALE
            affectedStatus: UNAFFECTED
            - individualId: BS_EQ98CJJT
            sex: FEMALE
            affectedStatus: UNAFFECTED
        metaData:
        resources:
            - id: hp
            name: human phenotype ontology
            url: http://purl.obolibrary.org/obo/hp.owl
            version: hp/releases/2019-11-08
            namespacePrefix: HP
            iriPrefix: 'http://purl.obolibrary.org/obo/HP_'
        phenopacketSchemaVersion: 2.0

       ```

### Required - Has defaults
#### BCFTOOLS
  - `rm_fields_csv`: List of existing annotation to remove. Default:
    ```
      INFO/CSQ,INFO/gnomad_3_1_1_AC,INFO/gnomad_3_1_1_AN,INFO/gnomad_3_1_1_AF,INFO/gnomad_3_1_1_nhomalt,INFO/gnomad_3_1_1_AC_popmax,INFO/gnomad_3_1_1_AN_popmax,INFO/gnomad_3_1_1_AF_popmax,INFO/gnomad_3_1_1_nhomalt_popmax,INFO/gnomad_3_1_1_AC_controls_and_biobanks,INFO/gnomad_3_1_1_AN_controls_and_biobanks,INFO/gnomad_3_1_1_AF_controls_and_biobanks,INFO/gnomad_3_1_1_AF_non_cancer,INFO/gnomad_3_1_1_primate_ai_score,INFO/gnomad_3_1_1_splice_ai_consequence,INFO/gnomad_3_1_1_FILTER,INFO/gnomad_3_1_1_AF_non_cancer_afr,INFO/gnomad_3_1_1_AF_non_cancer_ami,INFO/gnomad_3_1_1_AF_non_cancer_asj,INFO/gnomad_3_1_1_AF_non_cancer_eas,INFO/gnomad_3_1_1_AF_non_cancer_fin,INFO/gnomad_3_1_1_AF_non_cancer_mid,INFO/gnomad_3_1_1_AF_non_cancer_nfe,INFO/gnomad_3_1_1_AF_non_cancer_oth,INFO/gnomad_3_1_1_AF_non_cancer_raw,INFO/gnomad_3_1_1_AF_non_cancer_sas,INFO/gnomad_3_1_1_AF_non_cancer_amr,INFO/gnomad_3_1_1_AF_non_cancer_popmax,INFO/gnomad_3_1_1_AF_non_cancer_all_popmax
    ```
#### VEP
 - `assembly`: `GRCh38`
 - `vep_cache_version`: `111`
 - `vep_species`: `homo_sapiens`
 - `vep_cpus`: `32`
#### EXOMISER
 - `datadir_name`: `data`
 - `cadd_indelname`: `gnomad.genomes.r4.0.indel.tsv.gz`
 - `cadd_snvname`: `whole_genome_SNVs.tsv.gz`
 - `cadd_version`: `1.7`
 - `exomiser_version`: `2406`
 - `exomiser_genome`: `hg38`
 - `exomiser_mem`: `16`
 - `remm_filename`: `ReMM.v0.4.hg38.tsv.gz`
 - `remm_version`: `v0.4`

### Optional
#### BCFTOOLS STRIP
 - `annotate_vcf`: VCF to use to add annotations using bcftools
 - `annotate_vcf_index`: Index of `annotate_vcf`
 - `annot_fields_csv`: CSV list of fields to use from `annotate_vcf` and/or list of fields to rename
 - `bcftools_strip_extra_args`: Extra args to add to the step. Consult tool manual if needed
#### BCFTOOLS NORM
 - `check_ref`: For BCFTOOLS norm. Check REF alleles and exit (e), warn (w), exclude (x), or set (s) bad sites. Default is `w`
 - `multiallelics`: Split multiallelics (-) or join biallelics (+), type: snps|indels|both|any. Default is `-any`
#### VEP
 -  `vep_buffer_size`: `100000`
#### EXOMISER
 - `local_frequency`: custom frequency source file
 - `local_frequency_index`: Index of `local_frequency`
