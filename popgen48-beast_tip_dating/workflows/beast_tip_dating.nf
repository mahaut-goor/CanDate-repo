/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_beast_tip_dating_pipeline'
include { SAMTOOLS_INDEX         } from '../modules/nf-core/samtools/index/main'
include { SAMTOOLS_VIEW         } from '../modules/nf-core/samtools/view/main'
include { SAMTOOLS_COVERAGE     } from '../modules/nf-core/samtools/coverage/main'
include { SAMTOOLS_CONSENSUS    } from '../modules/nf-core/samtools/consensus/main'
include { SED_RENAME_FASTA      } from '../modules/local/sed/rename_fasta/main'
include { CAT_FASTA_FILES       } from '../modules/local/cat/fasta_files/main'
include { MAFFT_ALIGN           } from '../modules/nf-core/mafft/align/main'
include { TRIMAL                } from '../modules/nf-core/trimal/main'
include { PYTHON_PARSE_XML_TIP_DATES } from '../modules/local/python/parse_xml_tip_dates/main'
include { BEAST_MCMC            } from '../modules/local/beast/mcmc/main'
include { BEAST_LOGCOMBINER ; BEAST_LOGCOMBINER as BEAST_LOGCOMBINER_TREES } from '../modules/local/beast/logcombiner/main'
include { PYTHON_RESAMPLE_FROM_TREES } from '../modules/local/python/resample_from_trees/main'
include { RSCRIPT_TRACERER } from '../modules/local/rscript/tracerer/main'
include { BEAST_MCMC_RESUME } from '../modules/local/beast/mcmc_resume/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BEAST_TIP_DATING {

    take:
    ch_samplesheet // channel: samplesheet read in from --input
    main:

    ch_versions = Channel.empty()
    
    if( params.skip_consensus == false ) {

        bam_split = ch_samplesheet.branch { id, bams ->
            no_idx: bams.size() > 1 
            idx:  bams.size() == 1 
            }
        
        //
        //SAMTOOLS_INDEX
        //
        SAMTOOLS_INDEX(
            bam_split.idx
        )

        si_bam_idx = bam_split.idx.map{meta, bam->tuple(meta, bam[0])}.combine(SAMTOOLS_INDEX.out.bai, by:0)
        def_bam_idx = bam_split.no_idx.map{meta, bam->tuple(meta, bam[0], bam[1])}

        meta_bam_idx = si_bam_idx.mix(def_bam_idx)
        
        //
        //SAMTOOLS_VIEW
        //
        SAMTOOLS_VIEW(
            meta_bam_idx.map{meta, bam, idx -> tuple([id:meta.id+"_mt"],bam,idx)},
            [[],[]],
            [],
            []

        )
        //
        //SAMTOOLS_COVERAGE
        //
        SAMTOOLS_COVERAGE(
            SAMTOOLS_VIEW.out.bam.map{meta, bam -> tuple(meta,bam,[])},
            [[],[]],
            [[],[]]
        )

        //
        //SAMTOOLS_CONSENSUS
        //
        SAMTOOLS_CONSENSUS(
            SAMTOOLS_VIEW.out.bam
        )

        //
        //SED_RENAME_FASTA
        //
        SED_RENAME_FASTA(
            SAMTOOLS_CONSENSUS.out.fasta
        )

        consensus_fasta = SED_RENAME_FASTA.out.fasta
    }

    else{
            consensus_fasta = ch_samplesheet
        }

    if(params.skip_maln == false ){

        //
        // MAFFT_ALIGN
        //
        //ch_mafft_align_add = CAT_FASTA_FILES.out.fasta.combine([params.out_prefix]).map{fasta, prefix -> tuple([id:prefix],fasta)}
        ch_mafft_align_fasta = channel.fromPath(params.existing_maln)
        ch_mafft_align_add_fasta = consensus_fasta.combine(ch_mafft_align_fasta)
        
        MAFFT_ALIGN(
            ch_mafft_align_add_fasta.map{meta, add, fasta -> tuple(meta, fasta)},
            ch_mafft_align_add_fasta.map{meta, add, fasta -> tuple(meta, add)},
            [[],[]],
            [[],[]],
            [[],[]],
            [[],[]],
            []
        )

        //
        //TRIMAL
        //
        
        TRIMAL(
            MAFFT_ALIGN.out.fas,
            channel.value("fasta")
        )

        trimmed_fasta = TRIMAL.out.trimal
    }
    else{
            trimmed_fasta = consensus_fasta
        }

    if(params.skip_parse_xml == false){

    //
    //PYTHON_PARSE_XML_TIP_DATES
    //
    ch_fasta_to_xml = channel.fromPath(params.reference_xml).combine(trimmed_fasta)

    PYTHON_PARSE_XML_TIP_DATES(
        ch_fasta_to_xml.map{ref_xml, meta, trimal -> tuple(meta, trimal)},
        ch_fasta_to_xml.map{ref_xml, meta, trimal -> ref_xml}
    )

    ch_beast_xml = PYTHON_PARSE_XML_TIP_DATES.out.xml
    
    }

    else{
            ch_beast_xml = trimmed_fasta
        }

    nb_chain = channel.of(1..params.num_chain)

    ch_beast_mcmc =  ch_beast_xml.combine(nb_chain)

    if(!params.beast_rerun_file){
    //
    //BEAST_MCMC
    //
    BEAST_MCMC(
        ch_beast_mcmc.map{meta, xml, idx -> tuple(meta, xml)},
        ch_beast_mcmc.map{meta, xml, idx -> idx},
        []
    )

    //
    //BEAST_LOGCOMBINER_LOG
    //
    ch_beast_logcombiner_log = BEAST_MCMC.out.logs.groupTuple()

    BEAST_LOGCOMBINER(
        ch_beast_logcombiner_log,
        channel.value("log")
    )

    //
    //RSCRIPT_TRACERER
    //
    RSCRIPT_TRACERER(
        BEAST_LOGCOMBINER.out.logs
    )


    //
    //BEAST_LOGCOMBINER_TREES
    //
    ch_beastcombiner_trees = BEAST_MCMC.out.trees.groupTuple()

    BEAST_LOGCOMBINER_TREES(
        ch_beastcombiner_trees,
        channel.value("trees")
    )
    //
    //MODULE: PYTHON_RESAMPLES_FROM_TREES
    //
    PYTHON_RESAMPLE_FROM_TREES(
        BEAST_LOGCOMBINER_TREES.out.logs
    )
    }

    if(params.beast_rerun_file){
            ch_input_beast_rerun = Channel
            .fromPath(params.beast_rerun_file)
            .splitCsv(header: true, sep: ',')
            .map{row->tuple([id:row.sample],row.chain,row.seed,row.state,row.log,row.tree)}

            ch_beast_rerun = ch_beast_xml.combine(ch_input_beast_rerun,by:0)

            //
            //MODULE: BEAST_MCMC_RESUME
            //
            BEAST_MCMC_RESUME(
                ch_beast_rerun
            )
        }
    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name:  'beast_tip_dating_software_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    emit:
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
