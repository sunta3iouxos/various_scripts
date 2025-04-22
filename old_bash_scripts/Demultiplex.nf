#!/usr/bin/env nextflow

/**
 **********************************************
 * Demultiplexing pipeline *
 **********************************************
 * Basic usage:
 * ./nextflow -C nextflow.config run main.nf  --config parameters.json -resume
  **/
// config file in JSON format as main parameter -> specify on command line
params.config = ""

if (params.config == "") {
    log.info """
    Missing config file. Please specify an appropriate JSON file using the parameter.
    --config <config.json>
    """.stripIndent()
    exit 1
}

// parse config file using the JsonSlurper from Groovy
config_json = file(params.config)
new groovy.json.JsonSlurper().parseText(config_json.text)
                             .each { k,v -> params[k] = v }


//define where the bcl2fastqfile is, the path can also be defined as a param in the json file
params.bcl2fastq2 = new File ("/home/hthiele0/NGS/bcl2fastq2-v2.20.0/bin/").getCanonicalPath()

//define the process
process demultiplex {
tag "name"
label 'slurm settings'
// export the bcl2fastq2 to the enviromental PATH
beforeScript "export PATH=${params.bcl2fastq2}:\${PATH}"

 input:
    file(runfolder) from runfolder_input
    set name, file(SampleSheet) from SampleSheet_input
    
    output:
    file("*.svg")
    file("counts.RData") into counts_rdata
    file("dat.transformed.RData") into datTransformed_rdata
    file("IDtype.RData") into IDtype_rdata
    file("comparisons.RData") into comparisons_rdata
    file("DEresults.RData") into DEresults_rdata
    file("outlier_warning") into outlierWarning


"""
bcl2fastq \
                 --runfolder-dir $RUNFOLDER              \
                 --output-dir $RUNFOLDER/$OUTDIR  \
                 --sample-sheet $SAMPLESHEET          \
                 -r $RT -w $WT -p $PT                          \
                 $OPTIONS                                            \
                 --barcode-mismatches $BARCODE_MISMATCHES
"""
//OPTIONS include depending the SampleSheet_$name
//--minimum-trimmed-read-length arg
//--use-bases-mask
//--mask-short-adapter-reads
//--adapter-stringency
//--ignore-missing-bcls
//--ignore-missing-filter
//--ignore-missing-controls
//--barcode-mismatches
//--no-lane-splitting
    //--stats-dir arg (=<output-dir>/Stats/)          path to human-readable demultiplexing statistics directory
    //--reports-dir arg (=<output-dir>/Reports/)      path to reporting directory
}




    publishDir "${params.OUT}", mode: 'copy',
           saveAs: {file -> (file =~ /\.html/) ? file : null}

   

tag {name}

    script:
    """
    fastqc -q -t ${task.cpus} $fastq 
    """
}


workflow.onComplete {
    // write execution summary to publishDir
    file("${params.OUT}/execution_summary.txt") << """

    Pipeline execution summary
    ---------------------------
    Cmd line    : ${workflow.commandLine}
    Run name    : ${workflow.runName}
    Started on  : ${workflow.start}
    Completed at: ${workflow.complete}
    Duration    : ${workflow.duration}
    Execution status: ${ workflow.success ? 'OK' : 'failed' }
    workDir     : ${workflow.workDir}
    exit status : ${workflow.exitStatus}
    if (!  workflow.success) {
            Error message: ${workflow.errorMessage}
                                    }
    Error report: ${workflow.errorReport ?: '-'}
    """
}