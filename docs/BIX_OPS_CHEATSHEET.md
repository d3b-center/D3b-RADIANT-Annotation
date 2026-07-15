# Bix Ops Cheatsheet
Quick reference for bix Ops team to quickly deploy
## Generic:
- `output_basename`: `{cavatica_task_ID}.[BS/FM]XXXXX_hard-filtered_dragen_4.4`
- `annot_vcf_infix`: `vep105`
- `min_disk`: Currently CAVATICA-specific, set min disk size to save on EBS storage. Default 100GB (exomier tool min 400)
## Has phenotype:
- `disable_exomiser`: `false`
- `exomiser_pheno_file`: YAML file with sample information
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
- `exomiser*`: all other file inputs should be default
## Is a trio/duo:
- `disable_slivar_compound_hets`: `false`
  - `ped`: Need to provide ped file
  - `slivar_zips` Use default
## Already normalized:
- `disable_bcftools_norm`: `true`
## Has no previous annotation:
- `disable_bcftools_strip_anno`: `true`