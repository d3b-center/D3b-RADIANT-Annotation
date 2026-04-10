#!/usr/bin/env nextflow

include { BCFTOOLS_ANNOTATE as BCFTOOLS_STRIP } from './modules/local/bcftools/annotate/main'
include { BCFTOOLS_NORM } from './modules/local/bcftools/norm/main'
include { UNTAR as UNTAR_EXOMISER } from './modules/local/tar/main'
include { ENSEMBLVEP_VEP } from './modules/local/ensemblvep/vep/main'
include { EXOMISER } from './modules/local/exomiser/main'


def validate_params(param_obj){
  // lots of optional tools, so need to do some checks depending on input flags to avoid wasting time
  def all_errs = ""
  if (!param_obj.disable_bcftools_strip){
    def bcf_strip_min = [
      "rm_fields_csv",
      "annotate_vcf",
      "bcftools_strip_extra_args"
      ]
    if (!bcf_strip_min.any { param -> param_obj.containsKey(param) }) {
      all_errs += "At least one of ${bcf_strip_min} must be provided when bcftools_strip is enabled\n"
    }
  }
  if (!param_obj.disable_bcftools_norm && !param_obj.fasta) {
    all_errs += "Need a FASTA file to normalize\n"
  }
  if (!params.disable_vep) {
    def vep_required = [
      "vep_cache",
      "assembly",
      "vep_species",
      "fasta"

    ]
    def missed = []
    vep_required.each { param ->
      if (!param_obj.containsKey(param) || !param_obj[param]) {
        missed << param
      }
    }
    if (missed){
      all_errs += "Missing ${missed} params for VEP\n"
    }
  }
  if (!params.disable_exomiser) {
    def exomiser_required = [
      "pheno_file",
      "analysis_file",
      "datadir_file"
    ]
    def missed = []
    exomiser_required.each { param ->
      if (!param_obj.containsKey(param) || !param_obj[param]) {
        missed << param
      }
    }
    if (missed){
      all_errs += "Missing ${missed} params for exomiser\n"
    }
  }
  if (all_errs){
    error(all_errs)
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

    indexed_vcf = vcf.combine(vcf_index)
    if (!params.disable_bcftools_strip){
      indexed_vcf = BCFTOOLS_STRIP(
        indexed_vcf,
        annotate_vcf,
        annotate_vcf_index
      )
    }
    if (!params.disable_bcftools_norm) {
      indexed_vcf = BCFTOOLS_NORM(
        indexed_vcf,
        fasta
      )
    }
    if (!params.disable_vep) {
      indexed_vcf = ENSEMBLVEP_VEP(
        indexed_vcf,
        assembly,
        vep_species,
        vep_cache_version,
        vep_cache,
        fasta,
        channel.value([])
      )
    }
    if (!params.disable_exomiser) {
      exomiser_input_bundle = indexed_vcf.vcf.combine(
        indexed_vcf.tbi).combine(phenoFile).combine(analysisFile)

      cadd_bundle = caddVersion.combine(caddSnvFileName).combine(caddIndelFileName)
      EXOMISER(
        exomiser_input_bundle,
        datadir_file,
        datadir_name,
        exomiserGenome,
        exomiserDataVersion,
        localFrequencyPath,
        localFrequencyIndexPath,
        remmVersion.combine(remmFileName),
        cadd_bundle
      )
    }
}