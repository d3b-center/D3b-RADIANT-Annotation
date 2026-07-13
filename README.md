# D3b RADIANT Annotation

<p align="center">
  <img src="docs/logo/d3b-inline-white.svg" alt="D3b repository logo" width="660px" />
</p>
<p align="center">
  <a href="https://github.com/d3b-center/D3b-RADIANT-Annotation/blob/master/LICENSE"><img src="https://img.shields.io/github/license/d3b-center/D3b-RADIANT-Annotation.svg?style=for-the-badge"></a>
</p>

Workflow to add various transcript and site level annotations to a DNA germline VCF. The workflow has the following framework:
 - Old annotations are stripped with bcftools
 - VCF is annotated with bcftools
 - VCF is normalized
 - VCF is annotated with VEP
 - VCF is annotated with Echtvar
 - Slivar Compound Hets is run
 - Exomiser is run

### Disabling Tools
Any of the tools can be enabled/disabled using the following disable_(insert_step) parameters. The default workflow runs in the following configuration:
- disable_bcftools_strip_anno = false
- disable_bcftools_norm = false
- disable_vep = false
- disable_echtvar_anno = false
- disable_slivar_compound_hets = true
- disable_exomiser = true

While any step can be disabled, it might have adverse affects on downstream tools. For example, if you disable VEP but turn on Slivar compound hets, the program can fail if your input VCF does not have any ANN or CSQ INFO fields.
Validation safeguards only exist for each step because we want to allow for scenarios where partially annotated VCFs can enter at any stage. This allows for faster reannotation in the future.

## Inputs

### Required - Need to provide
As mentioned above requirements depend on what is enabled. At the minimum, three inputs are required.
- `vcf`: KF VCF to process
- `vcf_index` = Index of `vcf`
- `output_basename`: String prefix of file outputs. Technically optional, but strongly recommended. Default is `TEST`

#### BCFTOOLS STRIP ENABLED
If you enable BCFTOOLS STRIP, at least one of the following must be provided:
- `rm_fields_csv`
- `annotate_vcf`
- `bcftools_strip_extra_args`

#### BCFTOOLS NORM ENABLED
If you enable BCFTOOLS NORM, all of the following must be provided:
- `fasta`

#### VEP ENABLED
If you enable VEP, all of the following must be provided:
- `assembly`
- `fasta`
- `vep_cache`
- `vep_cache_version`
- `vep_species`

#### ECHTVAR ENABLED
If you enable ECHTVAR, all of the following must be provided:
- `echtvar_zips`

#### SLIVAR ENABLED
If you enable SLIVAR, all of the following must be provided:
- `ped`

As mentioned above, Slivar does require some annotations. For more information see [our notes](./docs/slivar_compound_hets_notes.md).

#### EXOMISER ENABLED
 - `analysis_file`: YAML with analysis options. See https://exomiser.readthedocs.io/en/latest/advanced_analysis.html#analysis. Recommend `default_exomiser_WGS_analysis.yml`
 - `datadir_file`: TAR GZ with reference files. Example contents:
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

### Input Defaults and Run Configurations

All of the defaults can be found in params block of `nextflow.config`.
Kids First specific run configurations can be found in `conf/kids_first.config`.

#### Kids First Run Configuration
Here's a snapshot of the run configuration for Kids First Germline data:
- `bcftools strip` uses the `annotate` module to:
  - remove existing VEP (`CSQ`) and gnomad 3.1.1 (`gnomad_3_1_1*`) annotations
  - add annotations from `annotate_vcf`
- `bcftools norm`: Uses `norm` to split (or join) mulit-allelics and normalize indels
- `VEP` uses cache 105 and meets the following specific criteria:
    ```
    --af_1kg
    --af_esp
    --af_gnomad
    --allele_number
    --allow_non_variant
    --appris
    --assembly GRCh38
    --buffer_size 100000
    --cache
    --cache_version 105
    --canonical
    --ccds
    --check_existing
    --compress_output bgzip
    --dir_cache ./
    --domains
    --dont_skip
    --failed 1
    --fasta Homo_sapiens_assembly38.fasta
    --flag_pick
    --format vcf
    --gene_phenotype
    --hgvs
    --hgvsg
    --mane
    --merged
    --no_escape
    --no_stats
    --numbers
    --offline
    --pick_order rank,biotype,mane,canonical,appris,tsl,ccds,length,ensembl,refseq
    --polyphen b
    --protein
    --pubmed
    --regulatory
    --shift_hgvs 1
    --sift b
    --species homo_sapiens
    --symbol
    --total_length
    --tsl
    --uniprot
    --variant_class
    --vcf
    --xref_refseq
    ```

- `echtvar`: Used for fast gnomAD annotation from the `echtvar_zips` input (gnomad.v3.1.1.custom.echtvar.zip)
- `slivar`: Used for rare variant discovery, primarily in joint family VCFs using the `expr` with the `slivar_zips` input (topmed.hg38.dbsnp.151.zip)  and `compount-hets` modules
- `exomiser`: "The Exomiser is a Java program that finds potential disease-causing variants from whole-exome or whole-genome sequencing data." See https://github.com/exomiser/Exomiser for more details
- `override_suffix`: String used for production purposes to override tool-contributed portion of file name for ANNOTATED_VCF output
