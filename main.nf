#!/usr/bin/env nextflow

include { BCFTOOLS_ANNOTATE as BCFTOOLS_STRIP } from './modules/local/bcftools/annotate/main'
include { BCFTOOLS_NORM } from './modules/local/bcftools/norm/main'
include { UNTAR as UNTAR_EXOMISER } from './modules/local/tar/main'
include { ENSEMBLVEP_VEP } from './modules/local/ensemblvep/vep/main'
include { ECHTVAR_ANNO } from './modules/local/echtvar/anno/main'
include { SLIVAR_COMPOUND_HETS } from './modules/local/slivar/compound-hets/main'
include { EXOMISER } from './modules/local/exomiser/main'

def validate_params(param_obj) {

  def errors = []

  // helper: check required params if tool is enabled
  def require_when_enabled = { disabled_flag, required, tool_name, mode = 'ALL' ->
    if (!param_obj[disabled_flag]) {

      def present = required.findAll { param_obj[it] }

      if (mode == 'ALL' && present.size() != required.size()) {
        def missing = required - present
        errors << "Missing ${missing} params for ${tool_name}"

      } else if (mode == 'ANY' && present.isEmpty()) {
        errors << "At least one of ${required} must be provided for ${tool_name}"
      }
    }
  }

  // bcftools strip: will work if ANY are set
  require_when_enabled(
    "disable_bcftools_strip",
    ["rm_fields_csv", "annotate_vcf", "bcftools_strip_extra_args"],
    "bcftools strip",
    "ANY"
  )

  // bcftools norm
  require_when_enabled(
    "disable_bcftools_norm",
    ["fasta"],
    "bcftools norm"
  )

  // VEP
  require_when_enabled(
    "disable_vep",
    ["vep_cache", "assembly", "vep_species", "fasta"],
    "VEP"
  )

  // gnomAD / Echtvar
  require_when_enabled(
    "disable_gnomad_anno",
    ["echtvar_zips"],
    "Echtvar anno"
  )

  // compound hets / slivar
  require_when_enabled(
    "disable_compound_hets",
    ["ped"],
    "Slivar compound-hets"
  )

  // exomiser
  require_when_enabled(
    "disable_exomiser",
    ["pheno_file", "analysis_file", "datadir_file"],
    "Exomiser"
  )

  if (errors) {
    error(errors.join("\n"))
  }
}

workflow {
  main:
    // validate params to start
    validate_params(params)
    //flags
    vcf = channel.fromPath(params.vcf)
    vcf_index = channel.fromPath(params.vcf_index)
    // bcftools
    annotate_vcf = params.annotate_vcf ? channel.fromPath(params.annotate_vcf) : channel.value([])
    annotate_vcf_index = params.annotate_vcf_index ? channel.fromPath(params.annotate_vcf_index) : channel.value([])
    // VEP
    vep_cache = channel.fromPath(params.vep_cache)
    vep_cache_version = params.vep_cache_version ?: '105'
    assembly = params.assembly
    vep_species = params.vep_species
    fasta = channel.fromPath(params.fasta)
    // exomiser
    phenoFile = params.pheno_file ? channel.fromPath(params.pheno_file) : channel.value([])
    analysisFile = params.analysis_file ? channel.fromPath(params.analysis_file) : channel.value([])
    datadir_file = params.datadir_file ? channel.fromPath(params.datadir_file) : channel.value([])
    datadir_name = params.datadir_name ?: "data"
    exomiserGenome = params.exomiser_genome ?: 'GRCh38'
    exomiserDataVersion = params.exomiser_version ?: '2406'
    localFrequencyPath = params.local_frequency ? channel.fromPath(params.local_frequency) : channel.value([])
    localFrequencyIndexPath = params.local_frequency_index ? channel.fromPath(params.local_frequency_index) : channel.value([])
    remmVersion = params.remm_version ? channel.value(params.remm_version) : channel.value("")
    remmFileName = params.remm_filename ? channel.value(params.remm_filename) : channel.value("")
    caddVersion = params.cadd_version ? channel.value(params.cadd_version) : channel.value("")
    caddSnvFileName = params.cadd_snvname ? channel.value(params.cadd_snvname) : channel.value("")
    caddIndelFileName = params.cadd_indelname ? channel.value(params.cadd_indelname) : channel.value("")

    // CAVATICA DEBUG
    if (params.sbg_run){
      def path = file("input_params.json", checkIfExists: true)
      if (path){
        println("SBG custom param inputs:")
        println (path.text)
      }
    }

    indexed_vcf = vcf.combine(vcf_index).map{ vcf, tbi -> [["id": "TEST"], vcf, tbi]}

    if (!params.disable_bcftools_strip){
      BCFTOOLS_STRIP(
        indexed_vcf,
        annotate_vcf.combine(annotate_vcf_index)
      )
      indexed_vcf = BCFTOOLS_STRIP.out.annotated_vcf
    }

    if (!params.disable_bcftools_norm) {
      BCFTOOLS_NORM(
        indexed_vcf,
        fasta
      )
      indexed_vcf = BCFTOOLS_NORM.out.normed_vcf
    }

    if (!params.disable_vep) {
      ENSEMBLVEP_VEP(
        indexed_vcf,
        assembly,
        vep_species,
        vep_cache_version,
        vep_cache,
        fasta,
        channel.value([])
      )
      indexed_vcf = ENSEMBLVEP_VEP.out.annotated_vcf
    }

    if (!params.disable_gnomad_anno) {
      ECHTVAR_ANNO(
        indexed_vcf,
        echtvar_zips
      )
      indexed_vcf = ECHTVAR_ANNO.out.annotated_vcf
    }

    if (!params.disable_compount_hets) {
      SLIVAR_COMPOUND_HETS(
        indexed_vcf,
        ped
      )
    }

    if (!params.disable_exomiser) {
      EXOMISER(
        indexed_vcf.combine(phenoFile).combine(analysisFile)
        datadir_file,
        datadir_name,
        exomiserGenome,
        exomiserDataVersion,
        localFrequencyPath,
        localFrequencyIndexPath,
        remmVersion.combine(remmFileName),
        caddVersion.combine(caddSnvFileName).combine(caddIndelFileName)
      )
    }
}
