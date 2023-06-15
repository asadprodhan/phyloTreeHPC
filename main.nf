#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//data_location

params.in = "$PWD/*_alignment.nex"
params.ref = "$PWD/*_ref.nex"

// results location

params.outdir = './results'


// process mrbayes

process mrbayes {
	tag { file }
	publishDir "${params.outdir}", mode:'copy'

	input:
	path (file)

	output:
	path "${file.simpleName}.mrbayes*"
	
	script:
	"""
	cat $file ${params.ref} > ${file.simpleName}.mrbayes  
	mb ${file.simpleName}.mrbayes 

	"""
}

// workflow
workflow {

	Channel.fromPath(params.in) | mrbayes
}
