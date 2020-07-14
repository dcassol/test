---
layout: doc
title: Workflow Collection
date: 2020-04-27 8:14:30 +0600
post_image: assets/images/service-icon3.png
tags: [Workflows]
keywords: "Documentation, systemPipeR, workflow, pipelines, NGS"
---

# systemPipeR: Workflows collection

**Note:** the most recent version of this tutorial can be found
<a href="http://www.bioconductor.org/packages/devel/bioc/vignettes/systemPipeR/inst/doc/systemPipeR.html">here</a>.

**Note:** if you use *`systemPipeR`* in published research, please cite:
Backman, T.W.H and Girke, T. (2016). *`systemPipeR`*: NGS Workflow and
Report Generation Environment. *BMC Bioinformatics*, 17: 388.
[10.1186/s12859-016-1241-0](https://doi.org/10.1186/s12859-016-1241-0).

## Workflow templates

The intended way of running *`sytemPipeR`* workflows is via *`*.Rmd`*
files, which can be executed either line-wise in interactive mode or
with a single command from R or the command-line. This way comprehensive
and reproducible analysis reports can be generated in PDF or HTML format
in a fully automated manner by making use of the highly functional
reporting utilities available for R. The following shows how to execute
a workflow (*e.g.*, systemPipeRNAseq.Rmd) from the command-line.

    Rscript -e "rmarkdown::render('systemPipeRNAseq.Rmd')"

Templates for setting up custom project reports are provided as
*`*.Rmd`* files by the helper package *`systemPipeRdata`* and in the
vignettes subdirectory of *`systemPipeR`*. The corresponding HTML of
these report templates are available here:
[*`systemPipeRNAseq`*](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRNAseq.html),
[*`systemPipeRIBOseq`*](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRIBOseq.html),
[*`systemPipeChIPseq`*](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeChIPseq.html)
and
[*`systemPipeVARseq`*](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeVARseq.html).
To work with *`*.Rmd`* files efficiently, basic knowledge of
[*`knitr`*](http://yihui.name/knitr/) and
[*`Latex`*](http://www.latex-project.org/) or
[*`R Markdown v2`*](http://rmarkdown.rstudio.com/) is required.

### Directory Structure

The working environment of the sample data loaded in the previous step
contains the following pre-configured directory structure. Directory
names are indicated in <span style="color:grey">***green***</span>.
Users can change this structure as needed, but need to adjust the code
in their workflows accordingly.

-   <span style="color:green">***workflow/***</span> (*e.g.* *rnaseq/*)
    -   This is the root directory of the R session running the
        workflow.
    -   Run script ( *\*.Rmd*) and sample annotation (*targets.txt*)
        files are located here.
    -   Note, this directory can have any name (*e.g.* <span
        style="color:green">***rnaseq***</span>, <span
        style="color:green">***varseq***</span>). Changing its name does
        not require any modifications in the run script(s).
    -   **Important subdirectories**:
        -   <span style="color:green">***param/***</span>
            -   Stores non-CWL parameter files such as: *\*.param*,
                *\*.tmpl* and *\*.run.sh*. These files are only required
                for backwards compatibility to run old workflows using
                the previous custom command-line interface.
            -   <span style="color:green">***param/cwl/***</span>: This
                subdirectory stores all the CWL parameter files. To
                organize workflows, each can have its own subdirectory,
                where all `CWL param` and `input.yml` files need to be
                in the same subdirectory.
        -   <span style="color:green">***data/*** </span>
            -   FASTQ files
            -   FASTA file of reference (*e.g.* reference genome)
            -   Annotation files
            -   etc.
        -   <span style="color:green">***results/***</span>
            -   Analysis results are usually written to this directory,
                including: alignment, variant and peak files (BAM, VCF,
                BED); tabular result files; and image/plot files
            -   Note, the user has the option to organize results files
                for a given sample and analysis step in a separate
                subdirectory.

The following parameter files are included in each workflow template:

1.  *`targets.txt`*: initial one provided by user; downstream
    *`targets_*.txt`* files are generated automatically
2.  *`*.param/cwl`*: defines parameter for input/output file operations,
    *e.g.*:
    -   *`hisat2-se/hisat2-mapping-se.cwl`*
    -   *`hisat2-se/hisat2-mapping-se.yml`*
3.  *`*_run.sh`*: optional bash scripts
4.  Configuration files for computer cluster environments (skip on
    single machines):
    -   *`.batchtools.conf.R`*: defines the type of scheduler for
        *`batchtools`* pointing to template file of cluster, and located
        in user’s home directory
    -   *`*.tmpl`*: specifies parameters of scheduler used by a system,
        *e.g.* Torque, SGE, Slurm, etc.

## RNA-Seq Workflow

This workflow demonstrates how to use various utilities for building and
running automated end-to-end analysis workflows for *`RNA-Seq`* data.

**The full workflow can be found here**:
[HTML](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRNAseq.html),
[.Rmd](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRNAseq.Rmd),
and
[.R](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRNAseq.R).

### Loading package and workflow template

Load the *`RNA-Seq`* sample workflow into your current working
directory.

    library(systemPipeRdata)
    genWorkenvir(workflow = "rnaseq")
    setwd("rnaseq")

### Run workflow

Next, run the chosen sample workflow *`systemPipeRNAseq`*
([.Rmd](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRNAseq.Rmd))
by executing from the command-line *`make -B`* within the *`rnaseq`*
directory. Alternatively, one can run the code from the provided
*`*.Rmd`* template file from within R interactively.

**Workflow includes following steps:**

1.  Read preprocessing
    -   Quality filtering (trimming)
    -   FASTQ quality report
2.  Alignments: *`HISAT2`* (or any other RNA-Seq aligner)
3.  Alignment stats
4.  Read counting
5.  Sample-wise correlation analysis
6.  Analysis of differentially expressed genes (DEGs)
7.  GO term enrichment analysis
8.  Gene-wise clustering

## ChIP-Seq Workflow

This workflow demonstrates how to use various utilities for building and
running automated end-to-end analysis workflows for *`ChIP-Seq`* data.

**The full workflow can be found here**:
[HTML](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeChIPseq.html),
[.Rmd](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeChIPseq.Rmd),
and
[.R](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeChIPseq.R).

### Loading package and workflow template

Load the *`ChIP-Seq`* sample workflow into your current working
directory.

    library(systemPipeRdata)
    genWorkenvir(workflow = "chipseq")
    setwd("chipseq")

### Run workflow

Next, run the chosen sample workflow *`systemPipeChIPseq`*
([.Rmd](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeChIPseq.Rmd))
by executing from the command-line *`make -B`* within the *`chipseq`*
directory. Alternatively, one can run the code from the provided
*`*.Rmd`* template file from within R interactively.

**Workflow includes following steps:**

1.  Read preprocessing
    -   Quality filtering (trimming)
    -   FASTQ quality report
2.  Alignments: *`Bowtie2`* or *`rsubread`*
3.  Alignment stats
4.  Peak calling: *`MACS2`*, *`BayesPeak`*
5.  Peak annotation with genomic context
6.  Differential binding analysis
7.  GO term enrichment analysis
8.  Motif analysis

## VAR-Seq Workflow

This workflow demonstrates how to use various utilities for building and
running automated end-to-end analysis workflows for *`VAR-Seq`* data.

**The full workflow can be found here:**
[HTML](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeVARseq.html),
[.Rmd](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeVARseq.Rmd),
and
[.R](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeVARseq.R).

### Loading package and workflow template

Load the *`VAR-Seq`* sample workflow into your current working
directory.

    library(systemPipeRdata)
    genWorkenvir(workflow = "varseq")
    setwd("varseq")

### Run workflow

Next, run the chosen sample workflow *`systemPipeVARseq`*
([.Rmd](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeVARseq.Rmd))
by executing from the command-line *`make -B`* within the *`varseq`*
directory. Alternatively, one can run the code from the provided
*`*.Rmd`* template file from within R interactively.

**Workflow includes following steps:**

1.  Read preprocessing
    -   Quality filtering (trimming)
    -   FASTQ quality report
2.  Alignments: *`gsnap`*, *`bwa`*
3.  Variant calling: *`VariantTools`*, *`GATK`*, *`BCFtools`*
4.  Variant filtering: *`VariantTools`* and *`VariantAnnotation`*
5.  Variant annotation: *`VariantAnnotation`*
6.  Combine results from many samples
7.  Summary statistics of samples

## Ribo-Seq Workflow

This workflow demonstrates how to use various utilities for building and
running automated end-to-end analysis workflows for *`RIBO-Seq`* data.

**The full workflow can be found here:**
[HTML](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRIBOseq.html),
[.Rmd](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRIBOseq.Rmd),
and
[.R](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRIBOseq.R).

### Loading package and workflow template

Load the *`RIBO-Seq`* sample workflow into your current working
directory.

    library(systemPipeRdata)
    genWorkenvir(workflow = "riboseq")
    setwd("riboseq")

### Run workflow

Next, run the chosen sample workflow *`systemPipeRIBOseq`*
([.Rmd](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRIBOseq.Rmd))
by executing from the command-line *`make -B`* within the *`ribseq`*
directory. Alternatively, one can run the code from the provided
*`*.Rmd`* template file from within R interactively.

**Workflow includes following steps:**

1.  Read preprocessing
    -   Adaptor trimming and quality filtering
    -   FASTQ quality report
2.  Alignments: *`HISAT2`* (or any other RNA-Seq aligner)
3.  Alignment stats
4.  Compute read distribution across genomic features
5.  Adding custom features to workflow (e.g. uORFs)
6.  Genomic read coverage along transcripts
7.  Read counting
8.  Sample-wise correlation analysis
9.  Analysis of differentially expressed genes (DEGs)
10. GO term enrichment analysis
11. Gene-wise clustering
12. Differential ribosome binding (translational efficiency)

## Version information

    sessionInfo()

    ## R version 4.0.0 (2020-04-24)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 20.04 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/local/bin/R/lib/R/lib/libRblas.so
    ## LAPACK: /usr/local/bin/R/lib/R/lib/libRlapack.so
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## attached base packages:
    ## [1] stats4    parallel  stats     graphics  grDevices utils     datasets 
    ## [8] methods   base     
    ## 
    ## other attached packages:
    ##  [1] systemPipeR_1.21.13         ShortRead_1.45.4           
    ##  [3] GenomicAlignments_1.23.2    SummarizedExperiment_1.17.5
    ##  [5] DelayedArray_0.13.12        matrixStats_0.56.0         
    ##  [7] Biobase_2.47.3              BiocParallel_1.21.3        
    ##  [9] Rsamtools_2.3.7             Biostrings_2.55.7          
    ## [11] XVector_0.27.2              GenomicRanges_1.39.3       
    ## [13] GenomeInfoDb_1.23.17        IRanges_2.21.8             
    ## [15] S4Vectors_0.25.15           BiocGenerics_0.33.3        
    ## [17] BiocStyle_2.15.8            rmarkdown_2.1              
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] colorspace_1.4-1         rjson_0.2.20             hwriter_1.3.2           
    ##  [4] ellipsis_0.3.0           bit64_0.9-7              AnnotationDbi_1.49.1    
    ##  [7] codetools_0.2-16         splines_4.0.0            knitr_1.28              
    ## [10] jsonlite_1.6.1           annotate_1.65.1          GO.db_3.10.0            
    ## [13] dbplyr_1.4.3             png_0.1-7                pheatmap_1.0.12         
    ## [16] graph_1.65.3             BiocManager_1.30.10      compiler_4.0.0          
    ## [19] httr_1.4.1               GOstats_2.53.0           backports_1.1.6         
    ## [22] assertthat_0.2.1         Matrix_1.2-18            limma_3.43.8            
    ## [25] formatR_1.7              htmltools_0.4.0          prettyunits_1.1.1       
    ## [28] tools_4.0.0              gtable_0.3.0             glue_1.4.0              
    ## [31] GenomeInfoDbData_1.2.3   Category_2.53.1          dplyr_0.8.5             
    ## [34] rsvg_1.3                 batchtools_0.9.13        rappdirs_0.3.1          
    ## [37] V8_3.0.2                 Rcpp_1.0.4.6             vctrs_0.2.4             
    ## [40] rtracklayer_1.47.0       xfun_0.13                stringr_1.4.0           
    ## [43] lifecycle_0.2.0          XML_3.99-0.3             edgeR_3.29.1            
    ## [46] zlibbioc_1.33.1          scales_1.1.0             BSgenome_1.55.4         
    ## [49] VariantAnnotation_1.33.5 hms_0.5.3                RBGL_1.63.1             
    ## [52] RColorBrewer_1.1-2       yaml_2.2.1               curl_4.3                
    ## [55] memoise_1.1.0            ggplot2_3.3.0            biomaRt_2.43.6          
    ## [58] latticeExtra_0.6-29      stringi_1.4.6            RSQLite_2.2.0           
    ## [61] genefilter_1.69.0        checkmate_2.0.0          GenomicFeatures_1.39.7  
    ## [64] DOT_0.1                  rlang_0.4.5              pkgconfig_2.0.3         
    ## [67] bitops_1.0-6             evaluate_0.14            lattice_0.20-41         
    ## [70] purrr_0.3.4              bit_1.1-15.2             tidyselect_1.0.0        
    ## [73] GSEABase_1.49.1          AnnotationForge_1.29.3   magrittr_1.5            
    ## [76] R6_2.4.1                 base64url_1.4            DBI_1.1.0               
    ## [79] pillar_1.4.3             withr_2.2.0              survival_3.1-12         
    ## [82] RCurl_1.98-1.2           tibble_3.0.1             crayon_1.3.4            
    ## [85] BiocFileCache_1.11.6     jpeg_0.1-8.1             progress_1.2.2          
    ## [88] locfit_1.5-9.4           grid_4.0.0               data.table_1.12.8       
    ## [91] blob_1.2.1               Rgraphviz_2.31.0         digest_0.6.25           
    ## [94] xtable_1.8-4             brew_1.0-6               openssl_1.4.1           
    ## [97] munsell_0.5.0            askpass_1.1

## Funding

This project is funded by NSF award
[ABI-1661152](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1661152).

## References
