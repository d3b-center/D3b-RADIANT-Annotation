#!/usr/bin/env nextflow

include { BCFTOOLS_ANNOTATE as BCFTOOLS_STRIP } from './modules/local/bcftools/annotate/main'
include { BCFTOOLS_NORM } from './modules/local/bcftools/norm/main'
include { UNTAR as UNTAR_EXOMISER } from './modules/local/tar/main'
include { ENSEMBLVEP_VEP } from './modules/local/ensemblvep/vep/main'
include { ECHTVAR_ANNO } from './modules/local/echtvar/anno/main'
include { SLIVAR_EXPR } from './modules/local/slivar/expr/main'
include { SLIVAR_COMPOUND_HETS } from './modules/local/slivar/compound-hets/main'
include { EXOMISER } from './modules/local/exomiser/main'

def asBool(v) {
  if (v instanceof Boolean) return v
  if (v == null) return false
  return v.toString().toLowerCase() == 'true'
}

def requireWhenEnabled(param_obj, errors, disabled_flag, required, tool_name, mode = 'ALL') {
  if (!asBool(param_obj[disabled_flag])) {

    def present = required.findAll { param_obj[it] }

    if (mode == 'ALL' && present.size() != required.size()) {
      errors << "Missing ${required - present} params for ${tool_name}"

    } else if (mode == 'ANY' && present.isEmpty()) {
      errors << "At least one of ${required} must be provided for ${tool_name}"
    }
  }
}

def validate_params(param_obj) {

  def errors = []

  // bcftools strip: will work if ANY are set
  requireWhenEnabled(
    param_obj,
    errors,
    "disable_bcftools_strip",
    ["rm_fields_csv", "annotate_vcf", "bcftools_strip_extra_args"],
    "bcftools strip",
    "ANY"
  )

  // bcftools norm
  requireWhenEnabled(
    param_obj,
    errors,
    "disable_bcftools_norm",
    ["fasta"],
    "bcftools norm"
  )

  // VEP
  requireWhenEnabled(
    param_obj,
    errors,
    "disable_vep",
    ["vep_cache", "assembly", "vep_species", "fasta"],
    "VEP"
  )

  // gnomAD / Echtvar
  requireWhenEnabled(
    param_obj,
    errors,
    "disable_gnomad_anno",
    ["echtvar_zips"],
    "Echtvar anno"
  )

  // compound hets / slivar
  requireWhenEnabled(
    param_obj,
    errors,
    "disable_compound_hets",
    ["ped"],
    "Slivar compound-hets"
  )

  // exomiser
  requireWhenEnabled(
    param_obj,
    errors,
    "disable_exomiser",
    ["pheno_file", "analysis_file", "datadir_file"],
    "Exomiser"
  )

  if (errors) {
    log.error(errors.join("\n"))
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
    vep_cache_version = params.vep_cache_version
    assembly = params.assembly
    vep_species = params.vep_species
    fasta = channel.fromPath(params.fasta)
    // echtvar
    echtvar_zips = params.echtvar_zips ? channel.fromPath(params.echtvar_zips) : channel.empty()
    // slivar
    slivar_zips = params.slivar_zips ? channel.fromPath(params.slivar_zips) : channel.empty()
    ped = params.ped ? channel.fromPath(params.ped) : channel.empty()
    // exomiser
    phenoFile = params.pheno_file ? channel.fromPath(params.pheno_file) : channel.value([])
    analysisFile = params.analysis_file ? channel.fromPath(params.analysis_file) : channel.value([])
    datadir_file = params.datadir_file ? channel.fromPath(params.datadir_file) : channel.value([])
    datadir_name = params.datadir_name
    exomiserGenome = params.exomiser_genome
    exomiserDataVersion = params.exomiser_version
    localFrequencyPath = params.local_frequency ? channel.fromPath(params.local_frequency) : channel.value([])
    localFrequencyIndexPath = params.local_frequency_index ? channel.fromPath(params.local_frequency_index) : channel.value([])
    remmVersion = params.remm_version ? channel.value(params.remm_version) : channel.value("")
    remmFileName = params.remm_filename ? channel.value(params.remm_filename) : channel.value("")
    caddVersion = params.cadd_version ? channel.value(params.cadd_version) : channel.value("")
    caddSnvFileName = params.cadd_snvname ? channel.value(params.cadd_snvname) : channel.value("")
    caddIndelFileName = params.cadd_indelname ? channel.value(params.cadd_indelname) : channel.value("")

    // CAVATICA DEBUG
    if (asBool(params.sbg_run)){
      def path = file("input_params.json", checkIfExists: true)
      if (path){
        log.info("SBG custom param inputs:")
        log.info(path.text)
      }
    }

    indexed_vcf = vcf.combine(vcf_index).map{ v, i -> [["id": "TEST"], v, i]}

    if (!asBool(params.disable_bcftools_strip)){
      BCFTOOLS_STRIP(
        indexed_vcf,
        annotate_vcf,
        annotate_vcf_index
      )
      indexed_vcf = BCFTOOLS_STRIP.out.annotated_vcf
    }

    if (!asBool(params.disable_bcftools_norm)) {
      BCFTOOLS_NORM(
        indexed_vcf,
        fasta
      )
      indexed_vcf = BCFTOOLS_NORM.out.normed_vcf
    }

    if (!asBool(params.disable_vep)) {
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

    if (!asBool(params.disable_gnomad_anno)) {
      ECHTVAR_ANNO(
        indexed_vcf,
        echtvar_zips
      )
      indexed_vcf = ECHTVAR_ANNO.out.annotated_vcf
    }

    if (!asBool(params.disable_compound_hets)) {
      SLIVAR_EXPR(
        indexed_vcf,
        ped,
        slivar_zips
      )
      SLIVAR_COMPOUND_HETS(
        SLIVAR_EXPR.out.filtered_vcf,
        ped
      )
    }

    if (!asBool(params.disable_exomiser)) {
      EXOMISER(
        indexed_vcf.combine(phenoFile).combine(analysisFile),
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
