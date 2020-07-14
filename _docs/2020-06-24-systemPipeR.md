---
layout: doc
title: systemPipeR
date: 2020-06-24 8:14:30 +0600
post_image: assets/images/service-icon3.png
tags: [systemPipeR]
toc: true
---

# systemPipeR: Workflow design and reporting generation environment

<p class="author-name">Author: Daniela Cassol (danielac@ucr.edu) and Thomas Girke (thomas.girke@ucr.edu)</p>

Alternative formats of this tutorial:
[ [HTML](http://girke.bioinformatics.ucr.edu/systemPipeR/pages/mydoc/systemPipeR.html){:target="_blank"} ],
[ [PDF](http://girke.bioinformatics.ucr.edu/systemPipeR/pages/mydoc/systemPipeR.pdf){:target="_blank"} ],
[ [.Rmd](https://raw.githubusercontent.com/tgirke/systemPipeR/gh-pages/_vignettes/10_Rworkflows/systemPipeR.Rmd){:target="_blank"} ],
[ [.R](https://raw.githubusercontent.com/tgirke/systemPipeR/gh-pages/_vignettes/10_Rworkflows/systemPipeR.R){:target="_blank"} ],
[ [Slides](https://docs.google.com/presentation/d/175aup31LvnbIJUAvEEoSkpGsKgtBJ2RpQYd0Gs23dLo/embed?start=false&loop=false&delayms=60000){:target="_blank"} ] 

**Note:** if you use *`systemPipeR`* in published research, please cite:
Backman, T.W.H and Girke, T. (2016). *`systemPipeR`*: NGS Workflow and
Report Generation Environment. *BMC Bioinformatics*, 17: 388.
[10.1186/s12859-016-1241-0](https://doi.org/10.1186/s12859-016-1241-0).

## Introduction

[*`systemPipeR`*](http://www.bioconductor.org/packages/devel/bioc/html/systemPipeR.html)
provides flexible utilities for building and running automated
end-to-end analysis workflows for a wide range of research applications,
including next-generation sequencing (NGS) experiments, such as RNA-Seq,
ChIP-Seq, VAR-Seq and Ribo-Seq (H Backman and Girke 2016). Important
features include a uniform workflow interface across different data
analysis applications, automated report generation, and support for
running both R and command-line software, such as NGS aligners or
peak/variant callers, on local computers or compute clusters (Figure 1).
The latter supports interactive job submissions and batch submissions to
queuing systems of clusters. For instance, *`systemPipeR`* can be used
with most command-line aligners such as `BWA` (Li 2013; Li and Durbin
2009), `HISAT2` (Kim, Langmead, and Salzberg 2015), `TopHat2` (Kim et
al. 2013) and `Bowtie2` (Langmead and Salzberg 2012), as well as the
R-based NGS aligners
[*`Rsubread`*](http://www.bioconductor.org/packages/devel/bioc/html/Rsubread.html)
(Liao, Smyth, and Shi 2013) and
[*`gsnap (gmapR)`*](http://www.bioconductor.org/packages/devel/bioc/html/gmapR.html)
(Wu and Nacu 2010). Efficient handling of complex sample sets (*e.g.*
FASTQ/BAM files) and experimental designs are facilitated by a
well-defined sample annotation infrastructure which improves
reproducibility and user-friendliness of many typical analysis workflows
in the NGS area (Lawrence et al. 2013).

The main motivation and advantages of using *`systemPipeR`* for complex
data analysis tasks are:

1.  Facilitates the design of complex NGS workflows involving multiple
    R/Bioconductor packages
2.  Common workflow interface for different NGS applications
3.  Makes NGS analysis with Bioconductor utilities more accessible to
    new users
4.  Simplifies usage of command-line software from within R
5.  Reduces the complexity of using compute clusters for R and
    command-line software
6.  Accelerates runtime of workflows via parallelization on computer
    systems with multiple CPU cores and/or multiple compute nodes
7.  Improves reproducibility by automating analyses and generation of
    analysis reports

<center><img src="../../assets/images/doc/utilities.png"></center>

**Figure 1:** Relevant features in *`systemPipeR`*. Workflow design
concepts are illustrated under (A & B). Examples of *systemPipeR’s*
visualization functionalities are given under (C). </br>

A central concept for designing workflows within the *`systemPipeR`*
environment is the use of workflow management containers. In previous
versions, *`systemPipeR`* used a custom command-line interface called
*`SYSargs`* (see Figure 3) and for this purpose will continue to be
supported for some time. With the latest [Bioconductor Release
3.9](http://www.bioconductor.org/packages/release/bioc/html/systemPipeR.html),
we are adopting for this functionality the widely used community
standard [Common Workflow Language](https://www.commonwl.org/) (CWL) for
describing analysis workflows in a generic and reproducible manner,
introducing *`SYSargs2`* workflow control class (see Figure 2). Using
this community standard in *`systemPipeR`* has many advantages. For
instance, the integration of CWL allows running *`systemPipeR`*
workflows from a single specification instance either entirely from
within R, from various command-line wrappers (e.g., *cwl-runner*) or
from other languages (*, e.g.,* Bash or Python). *`systemPipeR`*
includes support for both command-line and R/Bioconductor software as
well as resources for containerization, parallel evaluations on computer
clusters along with the automated generation of interactive analysis
reports.

An important feature of *`systemPipeR's`* CWL interface is that it
provides two options to run command-line tools and workflows based on
CWL. First, one can run CWL in its native way via an R-based wrapper
utility for *cwl-runner* or *cwl-tools* (CWL-based approach). Second,
one can run workflows using CWL’s command-line and workflow instructions
from within R (R-based approach). In the latter case the same CWL
workflow definition files (*e.g.* `*.cwl` and `*.yml`) are used but
rendered and executed entirely with R functions defined by
*`systemPipeR`*, and thus use CWL mainly as a command-line and workflow
definition format rather than software to run workflows. In this regard
*`systemPipeR`* also provides several convenience functions that are
useful for designing and debugging workflows, such as a command-line
rendering function to retrieve the exact command-line strings for each
data set and processing step prior to running a command-line.

This overview introduces the design of a new CWL S4 class in
*`systemPipeR`*, as well as the custom command-line interface, combined
with the overview of all the common analysis steps of NGS experiments.

### Workflow design structure using *`SYSargs2`*

The flexibility of *`systemPipeR's`* new interface workflow control
class is the driving factor behind the use of as many steps necessary
for the analysis, as well as the connection between command-line- or
R-based software. The connectivity among all workflow steps is achieved
by the *`SYSargs2`* workflow control class (see Figure 3). This S4 class
is a list-like container where each instance stores all the input/output
paths and parameter components required for a particular data analysis
step. *`SYSargs2`* instances are generated by two constructor functions,
*loadWorkflow* and *renderWF*, using as data input *targets* or *yaml*
files as well as two *cwl* parameter files (for details see below). When
running preconfigured workflows, the only input the user needs to
provide is the initial *targets* file containing the paths to the input
files (*e.g.* FASTQ) along with unique sample labels. Subsequent targets
instances are created automatically. The parameters required for running
command-line software is provided by the parameter (*.cwl*) files
described below.

We also introduce the *`SYSargs2Pipe`* class that organizes one or many
SYSargs2 containers in a single compound object capturing all
information required to run, control and monitor complex workflows from
start to finish. This design enhances the *`systemPipeR`* workflow
framework with a generalized, flexible, and robust design.

<center><img src="../../assets/images/doc/SYS_WF.png"></center>

**Figure 2:** Workflow steps with input/output file operations are
controlled by *`SYSargs2`* objects. Each *`SYSargs2`* instance is
constructed from one *targets* and two *param* files. The only input
provided by the user is the initial *targets* file. Subsequent *targets*
instances are created automatically, from the previous output files. Any
number of predefined or custom workflow steps are supported. One or many
*`SYSargs2`* objects are organized in an *`SYSargs2Pipe`* container.

### Workflow Management using *`SYSargsList`*

**systemPipeR** allows creation (multi-step analyses) and execution of
workflow entirely for R, with control, flexibility, and scalability of
the all process. The execution of the workflow can be sent to a HPC, can
be parallelizes, accelerating results acquisition. A workflow management
system provides an infrastructure for the set-up, performance and
monitoring of a defined sequence of tasks, arranged as a workflow
application.

<center><img src="../../assets/images/doc/sysargslist.png"></center>

**Figure 3:** Workflow Management using *`SYSargsList`*.

### Workflow design structure using *`SYSargs`*: Previous version

Instances of this S4 object class are constructed by the *`systemArgs`*
function from two simple tabular files: a *`targets`* file and a
*`param`* file. The latter is optional for workflow steps lacking
command-line software. Typically, a *`SYSargs`* instance stores all
sample-level inputs as well as the paths to the corresponding outputs
generated by command-line- or R-based software generating sample-level
output files, such as read preprocessors (trimmed/filtered FASTQ files),
aligners (SAM/BAM files), variant callers (VCF/BCF files) or peak
callers (BED/WIG files). Each sample level input/output operation uses
its own *`SYSargs`* instance. The outpaths of *`SYSargs`* usually define
the sample inputs for the next *`SYSargs`* instance. This connectivity
is established by writing the outpaths with the *`writeTargetsout`*
function to a new *`targets`* file that serves as input to the next
*`systemArgs`* call. Typically, the user has to provide only the initial
*`targets`* file. All downstream *`targets`* files are generated
automatically. By chaining several *`SYSargs`* steps together one can
construct complex workflows involving many sample-level input/output
file operations with any combination of command-line or R-based
software.

<center><img src="../../assets/images/doc/SystemPipeR_Workflow.png"></center>

**Figure 4:** Workflow design structure of *`systemPipeR`* using
*`SYSargs`*.

## Getting Started

### Installation

The R software for running
[*`systemPipeR`*](http://www.bioconductor.org/packages/devel/bioc/html/systemPipeR.html)
can be downloaded from [*CRAN*](http://cran.at.r-project.org/). The
*`systemPipeR`* environment can be installed from the R console using
the
[*`BiocManager::install`*](https://cran.r-project.org/web/packages/BiocManager/index.html)
command. The associated data package
[*`systemPipeRdata`*](http://www.bioconductor.org/packages/devel/data/experiment/html/systemPipeRdata.html)
can be installed the same way. The latter is a helper package for
generating *`systemPipeR`* workflow environments with a single command
containing all parameter files and sample data required to quickly test
and run workflows.

    if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
    BiocManager::install("systemPipeR")
    BiocManager::install("systemPipeRdata")

### Loading package and documentation

    library("systemPipeR")  # Loads the package
    library(help = "systemPipeR")  # Lists package info
    vignette("systemPipeR")  # Opens vignette

### Load sample data and workflow templates

The mini sample FASTQ files used by this overview vignette as well as
the associated workflow reporting vignettes can be loaded via the
*`systemPipeRdata`* package as shown below. The chosen data set
[`SRP010938`](http://www.ncbi.nlm.nih.gov/sra/?term=SRP010938) obtains
18 paired-end (PE) read sets from *Arabidposis thaliana* (Howard et al.
2013). To minimize processing time during testing, each FASTQ file has
been subsetted to 90,000-100,000 randomly sampled PE reads that map to
the first 100,000 nucleotides of each chromosome of the *A. thalina*
genome. The corresponding reference genome sequence (FASTA) and its GFF
annotation files (provided in the same download) have been truncated
accordingly. This way the entire test sample data set requires less than
200MB disk storage space. A PE read set has been chosen for this test
data set for flexibility, because it can be used for testing both types
of analysis routines requiring either SE (single-end) reads or PE reads.

The following generates a fully populated *`systemPipeR`* workflow
environment (here for RNA-Seq) in the current working directory of an R
session. At this time the package includes workflow templates for
RNA-Seq, ChIP-Seq, VAR-Seq, and Ribo-Seq. Templates for additional NGS
applications will be provided in the future.

    library(systemPipeRdata)
    genWorkenvir(workflow = "rnaseq")
    setwd("rnaseq")

If you desire run this tutorial with your data set, please follow the
instruction here:

    library(systemPipeRdata)
    genWorkenvir(workflow = "new", mydirname = "FEB_project")

#### Workflow template from an individual’s package

The package provides pre-configured workflows and reporting templates
for a wide range of NGS applications that are listed
[here](https://github.com/tgirke/systemPipeR/tree/devel#workflow).
Additional workflow templates will be provided in the future. If you
desire to use an individual package and version, follow the instruction
below:

    library(systemPipeRdata)
    genWorkenvir(workflow = NULL, package_repo = "systemPipeR/systemPipeRIBOseq", ref = "master", 
        subdir = NULL)

    library(systemPipeRdata)
    genWorkenvir(workflow = NULL, package_repo = "systemPipeR/systemPipeRNAseq", ref = "singleMachine", 
        subdir = NULL)

### Directory Structure

The working environment of the sample data loaded in the previous step
contains the following pre-configured directory structure (Figure 4).
Directory names are indicated in <span
style="color:grey">***green***</span>. Users can change this structure
as needed, but need to adjust the code in their workflows accordingly.

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

<center><img src="../../assets/images/doc/SYSdir.png"></center>

**Figure 5:** *systemPipeR’s* preconfigured directory structure.

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

### Structure of *`targets`* file

The *`targets`* file defines all input files (*e.g.* FASTQ, BAM, BCF)
and sample comparisons of an analysis workflow. The following shows the
format of a sample *`targets`* file included in the package. It also can
be viewed and downloaded from *`systemPipeR`*’s GitHub repository
[here](https://github.com/tgirke/systemPipeR/blob/master/inst/extdata/targets.txt).
In a target file with a single type of input files, here FASTQ files of
single-end (SE) reads, the first three columns are mandatory including
their column names, while it is four mandatory columns for FASTQ files
of PE reads. All subsequent columns are optional and any number of
additional columns can be added as needed.

Users should note here, the usage of targets files is optional when
using *systemPipeR’s* new CWL interface. They can be replaced by a
standard YAML input file used by CWL. Since for organizing experimental
variables targets files are extremely useful and user-friendly. Thus, we
encourage users to keep using them.

#### Structure of *`targets`* file for single-end (SE) samples

    library(systemPipeR)
    targetspath <- system.file("extdata", "targets.txt", package = "systemPipeR")
    read.delim(targetspath, comment.char = "#")[1:4, ]

    ##                      FileName SampleName Factor SampleLong Experiment
    ## 1 data/SRR446027_1.fastq.gz        M1A     M1  Mock.1h.A          1
    ## 2 data/SRR446028_1.fastq.gz        M1B     M1  Mock.1h.B          1
    ## 3 data/SRR446029_1.fastq.gz        A1A     A1   Avr.1h.A          1
    ## 4 data/SRR446030_1.fastq.gz        A1B     A1   Avr.1h.B          1
    ##          Date
    ## 1 23-Mar-2012
    ## 2 23-Mar-2012
    ## 3 23-Mar-2012
    ## 4 23-Mar-2012

To work with custom data, users need to generate a *`targets`* file
containing the paths to their own FASTQ files and then provide under
*`targetspath`* the path to the corresponding *`targets`* file.

#### Structure of *`targets`* file for paired-end (PE) samples

For paired-end (PE) samples, the structure of the targets file is
similar, where users need to provide two FASTQ path columns:
*`FileName1`* and *`FileName2`* with the paths to the PE FASTQ files.

    targetspath <- system.file("extdata", "targetsPE.txt", package = "systemPipeR")
    read.delim(targetspath, comment.char = "#")[1:2, 1:6]

    ##                     FileName1                   FileName2 SampleName Factor
    ## 1 data/SRR446027_1.fastq.gz data/SRR446027_2.fastq.gz        M1A     M1
    ## 2 data/SRR446028_1.fastq.gz data/SRR446028_2.fastq.gz        M1B     M1
    ##   SampleLong Experiment
    ## 1  Mock.1h.A          1
    ## 2  Mock.1h.B          1

#### Sample comparisons

Sample comparisons are defined in the header lines of the *`targets`*
file starting with ‘`# <CMP>`’.

    readLines(targetspath)[1:4]

    ## [1] "# Project ID: Arabidopsis - Pseudomonas alternative splicing study (SRA: SRP010938; PMID: 24098335)"                                                                              
    ## [2] "# The following line(s) allow to specify the contrasts needed for comparative analyses, such as DEG identification. All possible comparisons can be specified with 'CMPset: ALL'."
    ## [3] "# <CMP> CMPset1: M1-A1, M1-V1, A1-V1, M6-A6, M6-V6, A6-V6, M12-A12, M12-V12, A12-V12"                                                                                             
    ## [4] "# <CMP> CMPset2: ALL"

The function *`readComp`* imports the comparison information and stores
it in a *`list`*. Alternatively, *`readComp`* can obtain the comparison
information from the corresponding *`SYSargs`* object (see below). Note,
these header lines are optional. They are mainly useful for controlling
comparative analyses according to certain biological expectations, such
as identifying differentially expressed genes in RNA-Seq experiments
based on simple pair-wise comparisons.

    readComp(file = targetspath, format = "vector", delim = "-")

    ## $CMPset1
    ## [1] "M1-A1"   "M1-V1"   "A1-V1"   "M6-A6"   "M6-V6"   "A6-V6"   "M12-A12"
    ## [8] "M12-V12" "A12-V12"
    ## 
    ## $CMPset2
    ##  [1] "M1-A1"   "M1-V1"   "M1-M6"   "M1-A6"   "M1-V6"   "M1-M12"  "M1-A12" 
    ##  [8] "M1-V12"  "A1-V1"   "A1-M6"   "A1-A6"   "A1-V6"   "A1-M12"  "A1-A12" 
    ## [15] "A1-V12"  "V1-M6"   "V1-A6"   "V1-V6"   "V1-M12"  "V1-A12"  "V1-V12" 
    ## [22] "M6-A6"   "M6-V6"   "M6-M12"  "M6-A12"  "M6-V12"  "A6-V6"   "A6-M12" 
    ## [29] "A6-A12"  "A6-V12"  "V6-M12"  "V6-A12"  "V6-V12"  "M12-A12" "M12-V12"
    ## [36] "A12-V12"

### Structure of the new *`param`* files and construct *`SYSargs2`* container

*`SYSargs2`* stores all the information and instructions needed for
processing a set of input files with a single or many command-line steps
within a workflow (*i.e.* several components of the software or several
independent software tools). The *`SYSargs2`* object is created and
fully populated with the *loadWorkflow* and *renderWF* functions,
respectively.

In CWL, files with the extension *`.cwl`* define the parameters of a
chosen command-line step or workflow, while files with the extension
*`.yml`* define the input variables of command-line steps. Note, input
variables provided by a *targets* file can be passed on to a
*`SYSargs2`* instance via the *inputvars* argument of the *renderWF*
function.

The following imports a *`.cwl`* file (here *`hisat2-mapping-se.cwl`*)
for running the short read aligner HISAT2 (Kim, Langmead, and Salzberg
2015). The *loadWorkflow* and *renderWF* functions render the proper
command-line strings for each sample and software tool.

    library(systemPipeR)
    targets <- system.file("extdata", "targets.txt", package = "systemPipeR")
    dir_path <- system.file("extdata/cwl/hisat2/hisat2-se", package = "systemPipeR")
    WF <- loadWorkflow(targets = targets, wf_file = "hisat2-mapping-se.cwl", input_file = "hisat2-mapping-se.yml", 
        dir_path = dir_path)

    WF <- renderWF(WF, inputvars = c(FileName = "_FASTQ_PATH1_", SampleName = "_SampleName_"))

Several accessor methods are available that are named after the slot
names of the *`SYSargs2`* object.

    names(WF)

    ##  [1] "targets"       "targetsheader" "modules"       "wf"           
    ##  [5] "clt"           "yamlinput"     "cmdlist"       "input"        
    ##  [9] "output"        "cwlfiles"      "inputvars"

Of particular interest is the *`cmdlist()`* method. It constructs the
system commands for running command-line software as specified by a
given *`.cwl`* file combined with the paths to the input samples (*e.g.*
FASTQ files) provided by a *`targets`* file. The example below shows the
*`cmdlist()`* output for running HISAT2 on the first SE read sample.
Evaluating the output of *`cmdlist()`* can be very helpful for designing
and debugging *`.cwl`* files of new command-line software or changing
the parameter settings of existing ones.

    cmdlist(WF)[1]

    ## $M1A
    ## $M1A$`hisat2-mapping-se`
    ## [1] "hisat2 -S results/M1A.sam  -x data/tair10.fasta  -k 1  --min-intronlen 30  --max-intronlen 3000  -U data/SRR446027_1.fastq.gz --threads 4"

The output components of *`SYSargs2`* define the expected output files
for each step in the workflow; some of which are the input for the next
workflow step, here next *`SYSargs2`* instance (see Figure 2).

    output(WF)[1]

    ## $M1A
    ## $M1A$`hisat2-mapping-se`
    ## [1] "results/M1A.sam"

    modules(WF)

    ##        module1 
    ## "hisat2/2.1.0"

    targets(WF)[1]

    ## $M1A
    ## $M1A$FileName
    ## [1] "data/SRR446027_1.fastq.gz"
    ## 
    ## $M1A$SampleName
    ## [1] "M1A"
    ## 
    ## $M1A$Factor
    ## [1] "M1"
    ## 
    ## $M1A$SampleLong
    ## [1] "Mock.1h.A"
    ## 
    ## $M1A$Experiment
    ## [1] 1
    ## 
    ## $M1A$Date
    ## [1] "23-Mar-2012"

    targets.as.df(targets(WF))[1:4, 1:4]

    ##                      FileName SampleName Factor SampleLong
    ## 1 data/SRR446027_1.fastq.gz        M1A     M1  Mock.1h.A
    ## 2 data/SRR446028_1.fastq.gz        M1B     M1  Mock.1h.B
    ## 3 data/SRR446029_1.fastq.gz        A1A     A1   Avr.1h.A
    ## 4 data/SRR446030_1.fastq.gz        A1B     A1   Avr.1h.B

    output(WF)[1]

    ## $M1A
    ## $M1A$`hisat2-mapping-se`
    ## [1] "results/M1A.sam"

    cwlfiles(WF)

    ## $cwl
    ## [1] "/home/dcassol/R/x86_64-pc-linux-gnu-library/4.1/systemPipeR/extdata/cwl/hisat2/hisat2-se/hisat2-mapping-se.cwl"
    ## 
    ## $yml
    ## [1] "/home/dcassol/R/x86_64-pc-linux-gnu-library/4.1/systemPipeR/extdata/cwl/hisat2/hisat2-se/hisat2-mapping-se.yml"
    ## 
    ## $steps
    ## [1] "hisat2-mapping-se"

    inputvars(WF)

    ## $FileName
    ## [1] "_FASTQ_PATH1_"
    ## 
    ## $SampleName
    ## [1] "_SampleName_"

In an ‘R-centric’ rather than a ‘CWL-centric’ workflow design the
connectivity among workflow steps is established by writing all relevant
output with the *writeTargetsout* function to a new targets file that
serves as input to the next *loadWorkflow* and *renderWF* call. By
chaining several *`SYSargs2`* steps together one can construct complex
workflows involving many sample-level input/output file operations with
any combination of command-line or R-based software. Alternatively, a
CWL-centric workflow design can be used that defines all/most workflow
steps with CWL workflow and parameter files. Due to time and space
restrictions, the CWL-centric approach is not covered by this tutorial.

### Structure of *`param`* file and *`SYSargs`* container (Previous version)

The *`param`* file defines the parameters of a chosen command-line
software. The following shows the format of a sample *`param`* file
provided by this package.

    parampath <- system.file("extdata", "tophat.param", package = "systemPipeR")
    read.delim(parampath, comment.char = "#")

    ##      PairSet         Name                                  Value
    ## 1    modules         <NA>                          bowtie2/2.2.5
    ## 2    modules         <NA>                          tophat/2.0.14
    ## 3   software         <NA>                                 tophat
    ## 4      cores           -p                                      4
    ## 5      other         <NA> -g 1 --segment-length 25 -i 30 -I 3000
    ## 6   outfile1           -o                            <FileName1>
    ## 7   outfile1         path                             results/
    ## 8   outfile1       remove                                   <NA>
    ## 9   outfile1       append                                .tophat
    ## 10  outfile1 outextension              .tophat/accepted_hits.bam
    ## 11 reference         <NA>                    data/tair10.fasta
    ## 12   infile1         <NA>                            <FileName1>
    ## 13   infile1         path                                   <NA>
    ## 14   infile2         <NA>                            <FileName2>
    ## 15   infile2         path                                   <NA>

The *`systemArgs`* function imports the definitions of both the
*`param`* file and the *`targets`* file, and stores all relevant
information in a *`SYSargs`* object (S4 class). To run the pipeline
without command-line software, one can assign *`NULL`* to *`sysma`*
instead of a *`param`* file. In addition, one can start *`systemPipeR`*
workflows with pre-generated BAM files by providing a targets file where
the *`FileName`* column provides the paths to the BAM files. Note, in
the following example the usage of *`suppressWarnings()`* is only
relevant for building this vignette. In typical workflows it should be
removed.

    targetspath <- system.file("extdata", "targets.txt", package = "systemPipeR")
    args <- suppressWarnings(systemArgs(sysma = parampath, mytargets = targetspath))
    args

    ## An instance of 'SYSargs' for running 'tophat' on 18 samples

Several accessor methods are available that are named after the slot
names of the *`SYSargs`* object.

    names(args)

    ##  [1] "targetsin"     "targetsout"    "targetsheader" "modules"      
    ##  [5] "software"      "cores"         "other"         "reference"    
    ##  [9] "results"       "infile1"       "infile2"       "outfile1"     
    ## [13] "sysargs"       "outpaths"

Of particular interest is the *`sysargs()`* method. It constructs the
system commands for running command-lined software as specified by a
given *`param`* file combined with the paths to the input samples
(*e.g.* FASTQ files) provided by a *`targets`* file. The example below
shows the *`sysargs()`* output for running TopHat2 on the first PE read
sample. Evaluating the output of *`sysargs()`* can be very helpful for
designing and debugging *`param`* files of new command-line software or
changing the parameter settings of existing ones.

    sysargs(args)[1]

    ##                                                                                                                                                                                                                                                                                                            M1A 
    ## "tophat -p 4 -g 1 --segment-length 25 -i 30 -I 3000 -o /home/dcassol/danielac@ucr.edu/projects/SYSPipeWF_org/systemPipeR.github.io/_docs/results/SRR446027_1.fastq.gz.tophat /home/dcassol/danielac@ucr.edu/projects/SYSPipeWF_org/systemPipeR.github.io/_docs/data/tair10.fasta data/SRR446027_1.fastq.gz "

    modules(args)

    ## [1] "bowtie2/2.2.5" "tophat/2.0.14"

    cores(args)

    ## [1] 4

    outpaths(args)[1]

    ##                                                                                                                                       M1A 
    ## "/home/dcassol/danielac@ucr.edu/projects/SYSPipeWF_org/systemPipeR.github.io/_docs/results/SRR446027_1.fastq.gz.tophat/accepted_hits.bam"

The content of the *`param`* file can also be returned as JSON object as
follows (requires *`rjson`* package).

    systemArgs(sysma = parampath, mytargets = targetspath, type = "json")

    ## [1] "{\"modules\":{\"n1\":\"\",\"v2\":\"bowtie2/2.2.5\",\"n1\":\"\",\"v2\":\"tophat/2.0.14\"},\"software\":{\"n1\":\"\",\"v1\":\"tophat\"},\"cores\":{\"n1\":\"-p\",\"v1\":\"4\"},\"other\":{\"n1\":\"\",\"v1\":\"-g 1 --segment-length 25 -i 30 -I 3000\"},\"outfile1\":{\"n1\":\"-o\",\"v2\":\"<FileName1>\",\"n3\":\"path\",\"v4\":\"results/\",\"n5\":\"remove\",\"v1\":\"\",\"n2\":\"append\",\"v3\":\".tophat\",\"n4\":\"outextension\",\"v5\":\".tophat/accepted_hits.bam\"},\"reference\":{\"n1\":\"\",\"v1\":\"data/tair10.fasta\"},\"infile1\":{\"n1\":\"\",\"v2\":\"<FileName1>\",\"n1\":\"path\",\"v2\":\"\"},\"infile2\":{\"n1\":\"\",\"v2\":\"<FileName2>\",\"n1\":\"path\",\"v2\":\"\"}}"

## How to run a Workflow

This tutorial introduces the basic ideas and tools needed to build a
specific workflow from preconfigured templates.

### Load sample data and workflow templates

    library(systemPipeRdata)
    genWorkenvir(workflow = "rnaseq")
    setwd("rnaseq")

### Setup and Requirements

To go through this tutorial, you need the following software installed:

-   R/&gt;=3.6.2
-   systemPipeR R package (version 1.22)
-   Hisat2/2.1.0

If you desire to build your pipeline with any different software, make
sure to have the respective software installed and configured in your
PATH. To make sure if the configuration is right, you always can test as
follow:

    tryCL(command = "hisat2")  ## 'All set up, proceed!'

### Project Initialization

The Project management structure is essential, especially for
reproducibility and efficiency in the analysis. Here we show how to
construct an instance of this S4 object class by the *`initWF`*
function. The object of class *`SYSarsgsList`* storing all the
configuration information for the project and allows management and
control at a high level.

    script <- "systemPipeRNAseq.Rmd"
    targetspath <- "targets.txt"
    sysargslist <- initWF(script = script, targets = targets)

### Project Initialization in a Temporary Directory

    library(systemPipeRdata)
    script <- system.file("extdata/workflows/rnaseq", "systemPipeRNAseq.Rmd", package = "systemPipeRdata")
    targets <- system.file("extdata", "targets.txt", package = "systemPipeR")
    dir_path <- tempdir()
    SYSconfig <- initProject(projPath = dir_path, targets = targets, script = script, 
        overwrite = TRUE)
    sysargslist_temp <- initWF(sysconfig = "SYSconfig.yml")

### Configuration and run of the project

    sysargslist <- configWF(x = sysargslist, input_steps = "1:3")
    sysargslist <- runWF(sysargslist = sysargslist, steps = "ALL")
    sysargslist <- runWF(sysargslist = sysargslist, steps = "1:2")

## Workflow steps overview

### Define environment settings and samples

A typical workflow starts with generating the expected working
environment containing the proper directory structure, input files, and
parameter settings. To simplify this task, one can load one of the
existing NGS workflows templates provided by *`systemPipeRdata`* into
the current working directory. The following does this for the
*`rnaseq`* template. The name of the resulting workflow directory can be
specified under the *`mydirname`* argument. The default *`NULL`* uses
the name of the chosen workflow. An error is issued if a directory of
the same name and path exists already. On Linux and OS X systems one can
also create new workflow instances from the command-line of a terminal
as shown
[here](http://bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRdata.html#generate-workflow-template).
To apply workflows to custom data, the user needs to modify the
*`targets`* file and if necessary update the corresponding *`.cwl`* and
*`.yml`* files. A collection of pre-generated *`.cwl`* and *`.yml`*
files are provided in the *`param/cwl`* subdirectory of each workflow
template. They are also viewable in the GitHub repository of
*`systemPipeRdata`* ([see
here](https://github.com/tgirke/systemPipeRdata/tree/master/inst/extdata/param)).

    library(systemPipeR)
    library(systemPipeRdata)
    genWorkenvir(workflow = "rnaseq", mydirname = NULL)
    setwd("rnaseq")

### Read Preprocessing

#### Preprocessing with *`preprocessReads`* function

The function *`preprocessReads`* allows to apply predefined or custom
read preprocessing functions to all FASTQ files referenced in a
*`SYSargs2`* container, such as quality filtering or adaptor trimming
routines. The paths to the resulting output FASTQ files are stored in
the *`output`* slot of the *`SYSargs2`* object. Internally,
*`preprocessReads`* uses the *`FastqStreamer`* function from the
*`ShortRead`* package to stream through large FASTQ files in a
memory-efficient manner. The following example performs adaptor trimming
with the *`trimLRPatterns`* function from the *`Biostrings`* package.
After the trimming step a new targets file is generated (here
*`targets_trimPE.txt`*) containing the paths to the trimmed FASTQ files.
The new targets file can be used for the next workflow step with an
updated *`SYSargs2`* instance, *e.g.* running the NGS alignments with
the trimmed FASTQ files.

Construct *`SYSargs2`* object from *`cwl`* and *`yml`* param and
*`targets`* files.

    targetsPE <- system.file("extdata", "targetsPE.txt", package = "systemPipeR")
    dir_path <- system.file("extdata/cwl/preprocessReads/trim-pe", package = "systemPipeR")
    trim <- loadWorkflow(targets = targetsPE, wf_file = "trim-pe.cwl", input_file = "trim-pe.yml", 
        dir_path = dir_path)
    trim <- renderWF(trim, inputvars = c(FileName1 = "_FASTQ_PATH1_", FileName2 = "_FASTQ_PATH2_", 
        SampleName = "_SampleName_"))
    trim
    output(trim)[1:2]

    preprocessReads(args = trim, Fct = "trimLRPatterns(Rpattern='GCCCGGGTAA', 
                    subject=fq)", 
        batchsize = 1e+05, overwrite = TRUE, compress = TRUE)

The following example shows how one can design a custom read
preprocessing function using utilities provided by the *`ShortRead`*
package, and then run it in batch mode with the *‘preprocessReads’*
function (here on paired-end reads).

    filterFct <- function(fq, cutoff = 20, Nexceptions = 0) {
        qcount <- rowSums(as(quality(fq), "matrix") <= cutoff, na.rm = TRUE)
        # Retains reads where Phred scores are >= cutoff with N exceptions
        fq[qcount <= Nexceptions]
    }
    preprocessReads(args = trim, Fct = "filterFct(fq, cutoff=20, Nexceptions=0)", batchsize = 1e+05)

#### Preprocessing with TrimGalore!

[TrimGalore!](http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)
is a wrapper tool to consistently apply quality and adapter trimming to
fastq files, with some extra functionality for removing Reduced
Representation Bisulfite-Seq (RRBS) libraries.

    targets <- system.file("extdata", "targets.txt", package = "systemPipeR")
    dir_path <- system.file("extdata/cwl/trim_galore/trim_galore-se", package = "systemPipeR")
    trimG <- loadWorkflow(targets = targets, wf_file = "trim_galore-se.cwl", input_file = "trim_galore-se.yml", 
        dir_path = dir_path)
    trimG <- renderWF(trimG, inputvars = c(FileName = "_FASTQ_PATH1_", SampleName = "_SampleName_"))
    trimG
    cmdlist(trimG)[1:2]
    output(trimG)[1:2]
    ## Run Single Machine Option
    trimG <- runCommandline(trimG[1], make_bam = FALSE)

#### Preprocessing with Trimmomatic

    targetsPE <- system.file("extdata", "targetsPE.txt", package = "systemPipeR")
    dir_path <- system.file("extdata/cwl/trimmomatic/trimmomatic-pe", package = "systemPipeR")
    trimM <- loadWorkflow(targets = targetsPE, wf_file = "trimmomatic-pe.cwl", input_file = "trimmomatic-pe.yml", 
        dir_path = dir_path)
    trimM <- renderWF(trimM, inputvars = c(FileName1 = "_FASTQ_PATH1_", FileName2 = "_FASTQ_PATH2_", 
        SampleName = "_SampleName_"))
    trimM
    cmdlist(trimM)[1:2]
    output(trimM)[1:2]
    ## Run Single Machine Option
    trimM <- runCommandline(trimM[1], make_bam = FALSE)

### FASTQ quality report

The following *`seeFastq`* and *`seeFastqPlot`* functions generate and
plot a series of useful quality statistics for a set of FASTQ files
including per cycle quality box plots, base proportions, base-level
quality trends, relative k-mer diversity, length and occurrence
distribution of reads, number of reads above quality cutoffs and mean
quality distribution.  
The function *`seeFastq`* computes the quality statistics and stores the
results in a relatively small list object that can be saved to disk with
*`save()`* and reloaded with *`load()`* for later plotting. The argument
*`klength`* specifies the k-mer length and *`batchsize`* the number of
reads to a random sample from each FASTQ file.

    fqlist <- seeFastq(fastq = infile1(trim), batchsize = 10000, klength = 8)
    pdf("results/fastqReport.pdf", height = 18, width = 4 * length(fqlist))
    seeFastqPlot(fqlist)
    dev.off()

<center><img src="../../assets/images/doc/fastqReport.png"></center>
<div align="center">

**Figure 5:** FASTQ quality report </div></br>

Parallelization of FASTQ quality report on a single machine with
multiple cores.

    f <- function(x) seeFastq(fastq = infile1(trim)[x], batchsize = 1e+05, klength = 8)
    fqlist <- bplapply(seq(along = trim), f, BPPARAM = MulticoreParam(workers = 4))
    seeFastqPlot(unlist(fqlist, recursive = FALSE))

Parallelization of FASTQ quality report via scheduler (*e.g.* Slurm)
across several compute nodes.

    library(BiocParallel)
    library(batchtools)
    f <- function(x) {
        library(systemPipeR)
        targetsPE <- system.file("extdata", "targetsPE.txt", package = "systemPipeR")
        dir_path <- system.file("extdata/cwl/preprocessReads/trim-pe", package = "systemPipeR")
        trim <- loadWorkflow(targets = targetsPE, wf_file = "trim-pe.cwl", input_file = "trim-pe.yml", 
            dir_path = dir_path)
        trim <- renderWF(trim, inputvars = c(FileName1 = "_FASTQ_PATH1_", FileName2 = "_FASTQ_PATH2_", 
            SampleName = "_SampleName_"))
        seeFastq(fastq = infile1(trim)[x], batchsize = 1e+05, klength = 8)
    }
    resources <- list(walltime = 120, ntasks = 1, ncpus = 4, memory = 1024)
    param <- BatchtoolsParam(workers = 4, cluster = "slurm", template = "batchtools.slurm.tmpl", 
        resources = resources)
    fqlist <- bplapply(seq(along = trim), f, BPPARAM = param)
    seeFastqPlot(unlist(fqlist, recursive = FALSE))

### NGS Alignment software

After quality control, the sequence reads can be aligned to a reference
genome or transcriptome database. The following sessions present some
NGS sequence alignment software. Select the most accurate aligner and
determining the optimal parameter for your custom data set project.

For all the following examples, it is necessary to install the
respective software and export the `PATH` accordingly. If it is
available [Environment Module](http://modules.sourceforge.net/) in the
system, you can load all the request software with *`moduleload(args)`*
function.

#### Alignment with `HISAT2` using *`SYSargs2`*

The following steps will demonstrate how to use the short read aligner
`Hisat2` (Kim, Langmead, and Salzberg 2015) in both interactive job
submissions and batch submissions to queuing systems of clusters using
the *`systemPipeR's`* new CWL command-line interface.

The parameter settings of the aligner are defined in the
`hisat2-mapping-se.cwl` and `hisat2-mapping-se.yml` files. The following
shows how to construct the corresponding *SYSargs2* object, here *args*.

    targets <- system.file("extdata", "targets.txt", package = "systemPipeR")
    dir_path <- system.file("extdata/cwl/hisat2/hisat2-se", package = "systemPipeR")
    args <- loadWorkflow(targets = targets, wf_file = "hisat2-mapping-se.cwl", input_file = "hisat2-mapping-se.yml", 
        dir_path = dir_path)
    args <- renderWF(args, inputvars = c(FileName = "_FASTQ_PATH1_", SampleName = "_SampleName_"))
    args

    ## Instance of 'SYSargs2':
    ##    Slot names/accessors: 
    ##       targets: 18 (M1A...V12B), targetsheader: 4 (lines)
    ##       modules: 1
    ##       wf: 0, clt: 1, yamlinput: 7 (components)
    ##       input: 18, output: 18
    ##       cmdlist: 18
    ##    WF Steps:
    ##       1. hisat2-mapping-se (rendered: TRUE)

    cmdlist(args)[1:2]

    ## $M1A
    ## $M1A$`hisat2-mapping-se`
    ## [1] "hisat2 -S results/M1A.sam  -x data/tair10.fasta  -k 1  --min-intronlen 30  --max-intronlen 3000  -U data/SRR446027_1.fastq.gz --threads 4"
    ## 
    ## 
    ## $M1B
    ## $M1B$`hisat2-mapping-se`
    ## [1] "hisat2 -S results/M1B.sam  -x data/tair10.fasta  -k 1  --min-intronlen 30  --max-intronlen 3000  -U data/SRR446028_1.fastq.gz --threads 4"

    output(args)[1:2]

    ## $M1A
    ## $M1A$`hisat2-mapping-se`
    ## [1] "results/M1A.sam"
    ## 
    ## 
    ## $M1B
    ## $M1B$`hisat2-mapping-se`
    ## [1] "results/M1B.sam"

Subsetting *`SYSargs2`* class slots for each workflow step.

    subsetWF(args, slot = "input", subset = "FileName")[1:2]  ## Subsetting the input files for this particular workflow 

    ##                           M1A                           M1B 
    ## "data/SRR446027_1.fastq.gz" "data/SRR446028_1.fastq.gz"

    subsetWF(args, slot = "output", subset = 1, index = 1)[1:2]  ## Subsetting the output files for one particular step in the workflow 

    ##                 M1A                 M1B 
    ## "results/M1A.sam" "results/M1B.sam"

    subsetWF(args, slot = "step", subset = 1)[1]  ## Subsetting the command-lines for one particular step in the workflow 

    ##                                                                                                                                               M1A 
    ## "hisat2 -S results/M1A.sam  -x data/tair10.fasta  -k 1  --min-intronlen 30  --max-intronlen 3000  -U data/SRR446027_1.fastq.gz --threads 4"

    subsetWF(args, slot = "output", subset = 1, index = 1, delete = TRUE)[1]  ## DELETING specific output files

    ## The subset cannot be deleted: no such file

    ##                 M1A 
    ## "results/M1A.sam"

Build `Hisat2` index.

    dir_path <- system.file("extdata/cwl/hisat2/hisat2-idx", package = "systemPipeR")
    idx <- loadWorkflow(targets = NULL, wf_file = "hisat2-index.cwl", input_file = "hisat2-index.yml", 
        dir_path = dir_path)
    idx <- renderWF(idx)
    idx
    cmdlist(idx)

    ## Run
    runCommandline(idx, make_bam = FALSE)

##### Interactive job submissions in a single machine

To simplify the short read alignment execution for the user, the
command-line can be run with the *`runCommandline`* function. The
execution will be on a single machine without submitting to a queuing
system of a computer cluster. This way, the input FASTQ files will be
processed sequentially. By default *`runCommandline`* auto detects SAM
file outputs and converts them to sorted and indexed BAM files, using
internally the `Rsamtools` package (Morgan et al. 2019). Besides,
*`runCommandline`* allows the user to create a dedicated results folder
for each workflow and a sub-folder for each sample defined in the
*targets* file. This includes all the output and log files for each
step. When these options are used, the output location will be updated
by default and can be assigned to the same object.

    runCommandline(args, make_bam = FALSE)  ## generates alignments and writes *.sam files to results folder 
    args <- runCommandline(args, make_bam = TRUE)  ## same as above but writes files and converts *.sam files to sorted and indexed BAM files. Assigning the new extention of the output files to the object args.

If available, multiple CPU cores can be used for processing each file.
The number of CPU cores (here 4) to use for each process is defined in
the *`*.yml`* file. With *`yamlinput(args)['thread']`* one can return
this value from the *`SYSargs2`* object.

##### Parallelization on clusters

Alternatively, the computation can be greatly accelerated by processing
many files in parallel using several compute nodes of a cluster, where a
scheduling/queuing system is used for load balancing. For this the
*`clusterRun`* function submits the computing requests to the scheduler
using the run specifications defined by *`runCommandline`*.

To avoid over-subscription of CPU cores on the compute nodes, the value
from *`yamlinput(args)['thread']`* is passed on to the submission
command, here *`ncpus`* in the *`resources`* list object. The number of
independent parallel cluster processes is defined under the *`Njobs`*
argument. The following example will run 18 processes in parallel using
for each 4 CPU cores. If the resources available on a cluster allow
running all 18 processes at the same time then the shown sample
submission will utilize in total 72 CPU cores. Note, *`clusterRun`* can
be used with most queueing systems as it is based on utilities from the
*`batchtools`* package which supports the use of template files
(*`*.tmpl`*) for defining the run parameters of different schedulers. To
run the following code, one needs to have both a conf file (see
*`.batchtools.conf.R`* samples
[here](https://mllg.github.io/batchtools/)) and a template file (see
*`*.tmpl`* samples
[here](https://github.com/mllg/batchtools/tree/master/inst/templates))
for the queueing available on a system. The following example uses the
sample conf and template files for the Slurm scheduler provided by this
package.

    library(batchtools)
    resources <- list(walltime = 120, ntasks = 1, ncpus = 4, memory = 1024)
    reg <- clusterRun(args, FUN = runCommandline, more.args = list(args = args, make_bam = TRUE, 
        dir = FALSE), conffile = ".batchtools.conf.R", template = "batchtools.slurm.tmpl", 
        Njobs = 18, runid = "01", resourceList = resources)
    getStatus(reg = reg)
    waitForJobs(reg = reg)

Check and update the output location if necessary.

    args <- output_update(args, dir = FALSE, replace = TRUE, extension = c(".sam", ".bam"))  ## Updates the output(args) to the right location in the subfolders
    output(args)

##### Create new targets file

To establish the connectivity to the next workflow step, one can write a
new *targets* file with the *`writeTargetsout`* function. The new
*targets* file serves as input to the next *`loadWorkflow`* and
*`renderWF`* call.

    names(clt(args))
    writeTargetsout(x = args, file = "default", step = 1, new_col = "FileName", new_col_output_index = 1, 
        overwrite = TRUE)

##### Alignment with `HISAT2` and `SAMtools`

Alternatively, it possible to build an workflow with `HISAT2` and
`SAMtools`.

    targets <- system.file("extdata", "targets.txt", package = "systemPipeR")
    dir_path <- system.file("extdata/cwl/workflow-hisat2/workflow-hisat2-se", package = "systemPipeR")
    WF <- loadWorkflow(targets = targets, wf_file = "workflow_hisat2-se.cwl", input_file = "workflow_hisat2-se.yml", 
        dir_path = dir_path)
    WF <- renderWF(WF, inputvars = c(FileName = "_FASTQ_PATH1_", SampleName = "_SampleName_"))
    WF
    cmdlist(WF)[1:2]
    output(WF)[1:2]

#### Alignment with *`Tophat2`*

The NGS reads of this project can also be aligned against the reference
genome sequence using `Bowtie2/TopHat2` (Kim et al. 2013; Langmead and
Salzberg 2012).

Build *`Bowtie2`* index.

    dir_path <- system.file("extdata/cwl/bowtie2/bowtie2-idx", package = "systemPipeR")
    idx <- loadWorkflow(targets = NULL, wf_file = "bowtie2-index.cwl", input_file = "bowtie2-index.yml", 
        dir_path = dir_path)
    idx <- renderWF(idx)
    idx
    cmdlist(idx)

    ## Run in single machine
    runCommandline(idx, make_bam = FALSE)

The parameter settings of the aligner are defined in the
`tophat2-mapping-pe.cwl` and `tophat2-mapping-pe.yml` files. The
following shows how to construct the corresponding *SYSargs2* object,
here *tophat2PE*.

    targetsPE <- system.file("extdata", "targetsPE.txt", package = "systemPipeR")
    dir_path <- system.file("extdata/cwl/tophat2/tophat2-pe", package = "systemPipeR")
    tophat2PE <- loadWorkflow(targets = targetsPE, wf_file = "tophat2-mapping-pe.cwl", 
        input_file = "tophat2-mapping-pe.yml", dir_path = dir_path)
    tophat2PE <- renderWF(tophat2PE, inputvars = c(FileName1 = "_FASTQ_PATH1_", FileName2 = "_FASTQ_PATH2_", 
        SampleName = "_SampleName_"))
    tophat2PE
    cmdlist(tophat2PE)[1:2]
    output(tophat2PE)[1:2]

    ## Run in single machine
    tophat2PE <- runCommandline(tophat2PE[1], make_bam = TRUE)

Parallelization on clusters.

    resources <- list(walltime = 120, ntasks = 1, ncpus = 4, memory = 1024)
    reg <- clusterRun(tophat2PE, FUN = runCommandline, more.args = list(args = tophat2PE, 
        make_bam = TRUE, dir = FALSE), conffile = ".batchtools.conf.R", template = "batchtools.slurm.tmpl", 
        Njobs = 18, runid = "01", resourceList = resources)
    waitForJobs(reg = reg)

Create new targets file

    names(clt(tophat2PE))
    writeTargetsout(x = tophat2PE, file = "default", step = 1, new_col = "tophat2PE", 
        new_col_output_index = 1, overwrite = TRUE)

#### Alignment with *`Bowtie2`* (*e.g.* for miRNA profiling)

The following example runs *`Bowtie2`* as a single process without
submitting it to a cluster.

Building the index:

    dir_path <- system.file("extdata/cwl/bowtie2/bowtie2-idx", package = "systemPipeR")
    idx <- loadWorkflow(targets = NULL, wf_file = "bowtie2-index.cwl", input_file = "bowtie2-index.yml", 
        dir_path = dir_path)
    idx <- renderWF(idx)
    idx
    cmdlist(idx)

    ## Run in single machine
    runCommandline(idx, make_bam = FALSE)

Building all the command-line:

    targetsPE <- system.file("extdata", "targetsPE.txt", package = "systemPipeR")
    dir_path <- system.file("extdata/cwl/bowtie2/bowtie2-pe", package = "systemPipeR")
    bowtiePE <- loadWorkflow(targets = targetsPE, wf_file = "bowtie2-mapping-pe.cwl", 
        input_file = "bowtie2-mapping-pe.yml", dir_path = dir_path)
    bowtiePE <- renderWF(bowtiePE, inputvars = c(FileName1 = "_FASTQ_PATH1_", FileName2 = "_FASTQ_PATH2_", 
        SampleName = "_SampleName_"))
    bowtiePE
    cmdlist(bowtiePE)[1:2]
    output(bowtiePE)[1:2]

Running all the jobs to computing nodes.

    resources <- list(walltime = 120, ntasks = 1, ncpus = 4, memory = 1024)
    reg <- clusterRun(bowtiePE, FUN = runCommandline, more.args = list(args = bowtiePE, 
        dir = FALSE), conffile = ".batchtools.conf.R", template = "batchtools.slurm.tmpl", 
        Njobs = 18, runid = "01", resourceList = resources)
    getStatus(reg = reg)

Alternatively, it possible to run all the jobs in a single machine.

    bowtiePE <- runCommandline(bowtiePE)

Create new targets file.

    names(clt(bowtiePE))
    writeTargetsout(x = bowtiePE, file = "default", step = 1, new_col = "bowtiePE", new_col_output_index = 1, 
        overwrite = TRUE)

#### Alignment with *`BWA-MEM`* (*e.g.* for VAR-Seq)

The following example runs BWA-MEM as a single process without
submitting it to a cluster. \#\#TODO: add reference

Build the index:

    dir_path <- system.file("extdata/cwl/bwa/bwa-idx", package = "systemPipeR")
    idx <- loadWorkflow(targets = NULL, wf_file = "bwa-index.cwl", input_file = "bwa-index.yml", 
        dir_path = dir_path)
    idx <- renderWF(idx)
    idx
    cmdlist(idx)  # Indexes reference genome

    ## Run
    runCommandline(idx, make_bam = FALSE)

Running the alignment:

    targetsPE <- system.file("extdata", "targetsPE.txt", package = "systemPipeR")
    dir_path <- system.file("extdata/cwl/bwa/bwa-pe", package = "systemPipeR")
    bwaPE <- loadWorkflow(targets = targetsPE, wf_file = "bwa-pe.cwl", input_file = "bwa-pe.yml", 
        dir_path = dir_path)
    bwaPE <- renderWF(bwaPE, inputvars = c(FileName1 = "_FASTQ_PATH1_", FileName2 = "_FASTQ_PATH2_", 
        SampleName = "_SampleName_"))
    bwaPE
    cmdlist(bwaPE)[1:2]
    output(bwaPE)[1:2]
    ## Single Machine
    bwaPE <- runCommandline(args = bwaPE, make_bam = FALSE)

    ## Cluster
    library(batchtools)
    resources <- list(walltime = 120, ntasks = 1, ncpus = 4, memory = 1024)
    reg <- clusterRun(bwaPE, FUN = runCommandline, more.args = list(args = bwaPE, dir = FALSE), 
        conffile = ".batchtools.conf.R", template = "batchtools.slurm.tmpl", Njobs = 18, 
        runid = "01", resourceList = resources)
    getStatus(reg = reg)

Create new targets file.

    names(clt(bwaPE))
    writeTargetsout(x = bwaPE, file = "default", step = 1, new_col = "bwaPE", new_col_output_index = 1, 
        overwrite = TRUE)

#### Alignment with *`Rsubread`* (*e.g.* for RNA-Seq)

The following example shows how one can use within the environment the
R-based aligner , allowing running from R or command-line.

    ## Build the index:
    dir_path <- system.file("extdata/cwl/rsubread/rsubread-idx", package = "systemPipeR")
    idx <- loadWorkflow(targets = NULL, wf_file = "rsubread-index.cwl", input_file = "rsubread-index.yml", 
        dir_path = dir_path)
    idx <- renderWF(idx)
    idx
    cmdlist(idx)
    runCommandline(args = idx, make_bam = FALSE)

    ## Running the alignment:
    targets <- system.file("extdata", "targets.txt", package = "systemPipeR")
    dir_path <- system.file("extdata/cwl/rsubread/rsubread-se", package = "systemPipeR")
    rsubread <- loadWorkflow(targets = targets, wf_file = "rsubread-mapping-se.cwl", 
        input_file = "rsubread-mapping-se.yml", dir_path = dir_path)
    rsubread <- renderWF(rsubread, inputvars = c(FileName = "_FASTQ_PATH1_", SampleName = "_SampleName_"))
    rsubread
    cmdlist(rsubread)[1]

    ## Single Machine
    rsubread <- runCommandline(args = rsubread[1])

Create new targets file.

    names(clt(rsubread))
    writeTargetsout(x = rsubread, file = "default", step = 1, new_col = "rsubread", new_col_output_index = 1, 
        overwrite = TRUE)

#### Alignment with *`gsnap`* (*e.g.* for VAR-Seq and RNA-Seq)

Another R-based short read aligner is *`gsnap`* from the *`gmapR`*
package (Wu and Nacu 2010). The code sample below introduces how to run
this aligner on multiple nodes of a compute cluster.

    ## Build the index:
    dir_path <- system.file("extdata/cwl/gsnap/gsnap-idx", package = "systemPipeR")
    idx <- loadWorkflow(targets = NULL, wf_file = "gsnap-index.cwl", input_file = "gsnap-index.yml", 
        dir_path = dir_path)
    idx <- renderWF(idx)
    idx
    cmdlist(idx)
    runCommandline(args = idx, make_bam = FALSE)

    ## Running the alignment:
    targetsPE <- system.file("extdata", "targetsPE.txt", package = "systemPipeR")
    dir_path <- system.file("extdata/cwl/gsnap/gsnap-pe", package = "systemPipeR")
    gsnap <- loadWorkflow(targets = targetsPE, wf_file = "gsnap-mapping-pe.cwl", input_file = "gsnap-mapping-pe.yml", 
        dir_path = dir_path)
    gsnap <- renderWF(gsnap, inputvars = c(FileName1 = "_FASTQ_PATH1_", FileName2 = "_FASTQ_PATH2_", 
        SampleName = "_SampleName_"))
    gsnap
    cmdlist(gsnap)[1]
    output(gsnap)[1]

    ## Cluster
    library(batchtools)
    resources <- list(walltime = 120, ntasks = 1, ncpus = 4, memory = 1024)
    reg <- clusterRun(gsnap, FUN = runCommandline, more.args = list(args = gsnap, make_bam = FALSE), 
        conffile = ".batchtools.conf.R", template = "batchtools.slurm.tmpl", Njobs = 18, 
        runid = "01", resourceList = resources)
    getStatus(reg = reg)
    gsnap <- output_update(gsnap, dir = FALSE, replace = TRUE, extension = c(".sam", 
        ".bam"))

Create new targets file.

    names(clt(gsnap))
    writeTargetsout(x = gsnap, file = "default", step = 1, new_col = "gsnap", new_col_output_index = 1, 
        overwrite = TRUE)

### Create symbolic links for viewing BAM files in IGV

The genome browser IGV supports reading of indexed/sorted BAM files via
web URLs. This way it can be avoided to create unnecessary copies of
these large files. To enable this approach, an HTML directory with Http
access needs to be available in the user account (*e.g.*
*`home/publichtml`*) of a system. If this is not the case then the BAM
files need to be moved or copied to the system where IGV runs. In the
following, *`htmldir`* defines the path to the HTML directory with http
access where the symbolic links to the BAM files will be stored. The
corresponding URLs will be written to a text file specified under the
`_urlfile`\_ argument.

    symLink2bam(sysargs = args, htmldir = c("~/.html/", "somedir/"), urlbase = "http://myserver.edu/~username/", 
        urlfile = "IGVurl.txt")

### Read counting for mRNA profiling experiments

Create *`txdb`* (needs to be done only once).

    library(GenomicFeatures)
    txdb <- makeTxDbFromGFF(file = "data/tair10.gff", format = "gff", dataSource = "TAIR", 
        organism = "Arabidopsis thaliana")
    saveDb(txdb, file = "data/tair10.sqlite")

The following performs read counting with *`summarizeOverlaps`* in
parallel mode with multiple cores.

    library(BiocParallel)
    txdb <- loadDb("data/tair10.sqlite")
    eByg <- exonsBy(txdb, by = "gene")
    outpaths <- subsetWF(args, slot = "output", subset = 1, index = 1)
    bfl <- BamFileList(outpaths, yieldSize = 50000, index = character())
    multicoreParam <- MulticoreParam(workers = 4)
    register(multicoreParam)
    registered()
    counteByg <- bplapply(bfl, function(x) summarizeOverlaps(eByg, x, mode = "Union", 
        ignore.strand = TRUE, inter.feature = TRUE, singleEnd = TRUE))

    # Note: for strand-specific RNA-Seq set 'ignore.strand=FALSE' and for PE data set
    # 'singleEnd=FALSE'
    countDFeByg <- sapply(seq(along = counteByg), function(x) assays(counteByg[[x]])$counts)
    rownames(countDFeByg) <- names(rowRanges(counteByg[[1]]))
    colnames(countDFeByg) <- names(bfl)
    rpkmDFeByg <- apply(countDFeByg, 2, function(x) returnRPKM(counts = x, ranges = eByg))
    write.table(countDFeByg, "results/countDFeByg.xls", col.names = NA, quote = FALSE, 
        sep = "\t")
    write.table(rpkmDFeByg, "results/rpkmDFeByg.xls", col.names = NA, quote = FALSE, 
        sep = "\t")

Please note, in addition to read counts this step generates RPKM
normalized expression values. For most statistical differential
expression or abundance analysis methods, such as *`edgeR`* or
*`DESeq2`*, the raw count values should be used as input. The usage of
RPKM values should be restricted to specialty applications required by
some users, *e.g.* manually comparing the expression levels of different
genes or features.

Read counting with *`summarizeOverlaps`* using multiple nodes of a
cluster.

    library(BiocParallel)
    f <- function(x) {
        library(systemPipeR)
        library(BiocParallel)
        library(GenomicFeatures)
        txdb <- loadDb("data/tair10.sqlite")
        eByg <- exonsBy(txdb, by = "gene")
        args <- systemArgs(sysma = "param/tophat.param", mytargets = "targets.txt")
        outpaths <- subsetWF(args, slot = "output", subset = 1, index = 1)
        bfl <- BamFileList(outpaths, yieldSize = 50000, index = character())
        summarizeOverlaps(eByg, bfl[x], mode = "Union", ignore.strand = TRUE, inter.feature = TRUE, 
            singleEnd = TRUE)
    }
    resources <- list(walltime = 120, ntasks = 1, ncpus = 4, memory = 1024)
    param <- BatchtoolsParam(workers = 4, cluster = "slurm", template = "batchtools.slurm.tmpl", 
        resources = resources)
    counteByg <- bplapply(seq(along = args), f, BPPARAM = param)
    countDFeByg <- sapply(seq(along = counteByg), function(x) assays(counteByg[[x]])$counts)
    rownames(countDFeByg) <- names(rowRanges(counteByg[[1]]))
    colnames(countDFeByg) <- names(outpaths)

Useful commands for monitoring the progress of submitted jobs

    getStatus(reg = reg)
    outpaths <- subsetWF(args, slot = "output", subset = 1, index = 1)
    file.exists(outpaths)
    sapply(1:length(outpaths), function(x) loadResult(reg, id = x))  # Works after job completion

##### Read and alignment count stats

Generate a table of read and alignment counts for all samples.

    read_statsDF <- alignStats(args)
    write.table(read_statsDF, "results/alignStats.xls", row.names = FALSE, quote = FALSE, 
        sep = "\t")

The following shows the first four lines of the sample alignment stats
file provided by the *`systemPipeR`* package. For simplicity the number
of PE reads is multiplied here by 2 to approximate proper alignment
frequencies where each read in a pair is counted.

    read.table(system.file("extdata", "alignStats.xls", package = "systemPipeR"), header = TRUE)[1:4, 
        ]

    ##   FileName Nreads2x Nalign Perc_Aligned Nalign_Primary Perc_Aligned_Primary
    ## 1      M1A   192918 177961     92.24697         177961             92.24697
    ## 2      M1B   197484 159378     80.70426         159378             80.70426
    ## 3      A1A   189870 176055     92.72397         176055             92.72397
    ## 4      A1B   188854 147768     78.24457         147768             78.24457

Parallelization of read/alignment stats on single machine with multiple
cores.

    f <- function(x) alignStats(args[x])
    read_statsList <- bplapply(seq(along = args), f, BPPARAM = MulticoreParam(workers = 8))
    read_statsDF <- do.call("rbind", read_statsList)

Parallelization of read/alignment stats via scheduler (*e.g.* Slurm)
across several compute nodes.

    library(BiocParallel)
    library(batchtools)
    f <- function(x) {
        library(systemPipeR)
        targets <- system.file("extdata", "targets.txt", package = "systemPipeR")
        dir_path <- "param/cwl/hisat2/hisat2-se"  ## TODO: replace path to system.file 
        args <- loadWorkflow(targets = targets, wf_file = "hisat2-mapping-se.cwl", input_file = "hisat2-mapping-se.yml", 
            dir_path = dir_path)
        args <- renderWF(args, inputvars = c(FileName = "_FASTQ_PATH1_", SampleName = "_SampleName_"))
        args <- output_update(args, dir = FALSE, replace = TRUE, extension = c(".sam", 
            ".bam"))
        alignStats(args[x])
    }
    resources <- list(walltime = 120, ntasks = 1, ncpus = 4, memory = 1024)
    param <- BatchtoolsParam(workers = 4, cluster = "slurm", template = "batchtools.slurm.tmpl", 
        resources = resources)
    read_statsList <- bplapply(seq(along = args), f, BPPARAM = param)
    read_statsDF <- do.call("rbind", read_statsList)

### Read counting for miRNA profiling experiments

Download miRNA genes from miRBase.

    system("wget ftp://mirbase.org/pub/mirbase/19/genomes/My_species.gff3 -P data/")
    gff <- import.gff("data/My_species.gff3")
    gff <- split(gff, elementMetadata(gff)$ID)
    bams <- names(bampaths)
    names(bams) <- targets$SampleName
    bfl <- BamFileList(bams, yieldSize = 50000, index = character())
    countDFmiR <- summarizeOverlaps(gff, bfl, mode = "Union", ignore.strand = FALSE, 
        inter.feature = FALSE)  # Note: inter.feature=FALSE important since pre and mature miRNA ranges overlap
    rpkmDFmiR <- apply(countDFmiR, 2, function(x) returnRPKM(counts = x, gffsub = gff))
    write.table(assays(countDFmiR)$counts, "results/countDFmiR.xls", col.names = NA, 
        quote = FALSE, sep = "\t")
    write.table(rpkmDFmiR, "results/rpkmDFmiR.xls", col.names = NA, quote = FALSE, sep = "\t")

### Correlation analysis of samples

The following computes the sample-wise Spearman correlation coefficients
from the *`rlog`* (regularized-logarithm) transformed expression values
generated with the *`DESeq2`* package. After transformation to a
distance matrix, hierarchical clustering is performed with the
*`hclust`* function and the result is plotted as a dendrogram
([sample\_tree.pdf](results/sample_tree.pdf)).

    library(DESeq2, warn.conflicts = FALSE, quietly = TRUE)
    library(ape, warn.conflicts = FALSE)
    countDFpath <- system.file("extdata", "countDFeByg.xls", package = "systemPipeR")
    countDF <- as.matrix(read.table(countDFpath))
    colData <- data.frame(row.names = targets.as.df(targets(args))$SampleName, condition = targets.as.df(targets(args))$Factor)
    dds <- DESeqDataSetFromMatrix(countData = countDF, colData = colData, design = ~condition)

    ## Warning in DESeqDataSet(se, design = design, ignoreRank): some variables in
    ## design formula are characters, converting to factors

    d <- cor(assay(rlog(dds)), method = "spearman")
    hc <- hclust(dist(1 - d))
    plot.phylo(as.phylo(hc), type = "p", edge.col = 4, edge.width = 3, show.node.label = TRUE, 
        no.margin = TRUE)

![](../../assets/images/doc/sample_tree_rlog-1.png)

<div align="center">

**Figure 6:** Correlation dendrogram of samples for *`rlog`* values.
</div></br>

Alternatively, the clustering can be performed with *`RPKM`* normalized
expression values. In combination with Spearman correlation the results
of the two clustering methods are often relatively similar.

    rpkmDFeBygpath <- system.file("extdata", "rpkmDFeByg.xls", package = "systemPipeR")
    rpkmDFeByg <- read.table(rpkmDFeBygpath, check.names = FALSE)
    rpkmDFeByg <- rpkmDFeByg[rowMeans(rpkmDFeByg) > 50, ]
    d <- cor(rpkmDFeByg, method = "spearman")
    hc <- hclust(as.dist(1 - d))
    plot.phylo(as.phylo(hc), type = "p", edge.col = "blue", edge.width = 2, show.node.label = TRUE, 
        no.margin = TRUE)

### DEG analysis with *`edgeR`*

The following *`run_edgeR`* function is a convenience wrapper for
identifying differentially expressed genes (DEGs) in batch mode with
*`edgeR`*’s GML method (Robinson, McCarthy, and Smyth 2010) for any
number of pairwise sample comparisons specified under the *`cmp`*
argument. Users are strongly encouraged to consult the
[*`edgeR`*](\href%7Bhttp://www.bioconductor.org/packages/devel/bioc/vignettes/edgeR/inst/doc/edgeRUsersGuide.pdf)
vignette for more detailed information on this topic and how to properly
run *`edgeR`* on data sets with more complex experimental designs.

    targets <- read.delim(targetspath, comment = "#")
    cmp <- readComp(file = targetspath, format = "matrix", delim = "-")
    cmp[[1]]

    ##       [,1]  [,2] 
    ##  [1,] "M1"  "A1" 
    ##  [2,] "M1"  "V1" 
    ##  [3,] "A1"  "V1" 
    ##  [4,] "M6"  "A6" 
    ##  [5,] "M6"  "V6" 
    ##  [6,] "A6"  "V6" 
    ##  [7,] "M12" "A12"
    ##  [8,] "M12" "V12"
    ##  [9,] "A12" "V12"

    countDFeBygpath <- system.file("extdata", "countDFeByg.xls", package = "systemPipeR")
    countDFeByg <- read.delim(countDFeBygpath, row.names = 1)
    edgeDF <- run_edgeR(countDF = countDFeByg, targets = targets, cmp = cmp[[1]], independent = FALSE, 
        mdsplot = "")

    ## Disp = 0.21829 , BCV = 0.4672

Filter and plot DEG results for up and down-regulated genes. Because of
the small size of the toy data set used by this vignette, the *FDR*
value has been set to a relatively high threshold (here 10%). More
commonly used *FDR* cutoffs are 1% or 5%. The definition of ‘*up*’ and
‘*down*’ is given in the corresponding help file. To open it, type
*`?filterDEGs`* in the R console.

    DEG_list <- filterDEGs(degDF = edgeDF, filter = c(Fold = 2, FDR = 10))

![](../../assets/images/doc/edger_deg_counts-1.png)

<div align="center">

**Figure 7:** Up and down regulated DEGs identified by *`edgeR`*.
</div></br>

    names(DEG_list)

    ## [1] "UporDown" "Up"       "Down"     "Summary"

    DEG_list$Summary[1:4, ]

    ##       Comparisons Counts_Up_or_Down Counts_Up Counts_Down
    ## M1-A1       M1-A1                 0         0           0
    ## M1-V1       M1-V1                 1         1           0
    ## A1-V1       A1-V1                 1         1           0
    ## M6-A6       M6-A6                 0         0           0

### DEG analysis with *`DESeq2`*

The following *`run_DESeq2`* function is a convenience wrapper for
identifying DEGs in batch mode with *`DESeq2`* (Love, Huber, and Anders
2014) for any number of pairwise sample comparisons specified under the
*`cmp`* argument. Users are strongly encouraged to consult the
[*`DESeq2`*](http://www.bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.pdf)
vignette for more detailed information on this topic and how to properly
run *`DESeq2`* on data sets with more complex experimental designs.

    degseqDF <- run_DESeq2(countDF = countDFeByg, targets = targets, cmp = cmp[[1]], 
        independent = FALSE)

    ## Warning in DESeqDataSet(se, design = design, ignoreRank): some variables in
    ## design formula are characters, converting to factors

Filter and plot DEG results for up and down-regulated genes.

    DEG_list2 <- filterDEGs(degDF = degseqDF, filter = c(Fold = 2, FDR = 10))

![](../../assets/images/doc/deseq2_deg_counts-1.png)

<div align="center">

**Figure 8:** Up and down regulated DEGs identified by *`DESeq2`*.
</div></br>

### Venn Diagrams

The function *`overLapper`* can compute Venn intersects for large
numbers of sample sets (up to 20 or more) and *`vennPlot`* can plot 2-5
way Venn diagrams. A useful feature is the possibility to combine the
counts from several Venn comparisons with the same number of sample sets
in a single Venn diagram (here for 4 up and down DEG sets).

    vennsetup <- overLapper(DEG_list$Up[6:9], type = "vennsets")
    vennsetdown <- overLapper(DEG_list$Down[6:9], type = "vennsets")
    vennPlot(list(vennsetup, vennsetdown), mymain = "", mysub = "", colmode = 2, ccol = c("blue", 
        "red"))

![](../../assets/images/doc/vennplot-1.png)

<div align="center">

**Figure 9:** Venn Diagram for 4 Up and Down DEG Sets. </div></br>

### GO term enrichment analysis of DEGs

#### Obtain gene-to-GO mappings

The following shows how to obtain gene-to-GO mappings from *`biomaRt`*
(here for *A. thaliana*) and how to organize them for the downstream GO
term enrichment analysis. Alternatively, the gene-to-GO mappings can be
obtained for many organisms from Bioconductor’s *`*.db`* genome
annotation packages or GO annotation files provided by various genome
databases. For each annotation, this relatively slow preprocessing step
needs to be performed only once. Subsequently, the preprocessed data can
be loaded with the *`load`* function as shown in the next subsection.

    library("biomaRt")
    listMarts()  # To choose BioMart database
    listMarts(host = "plants.ensembl.org")
    m <- useMart("plants_mart", host = "plants.ensembl.org")
    listDatasets(m)
    m <- useMart("plants_mart", dataset = "athaliana_eg_gene", host = "plants.ensembl.org")
    listAttributes(m)  # Choose data types you want to download
    go <- getBM(attributes = c("go_id", "tair_locus", "namespace_1003"), mart = m)
    go <- go[go[, 3] != "", ]
    go[, 3] <- as.character(go[, 3])
    go[go[, 3] == "molecular_function", 3] <- "F"
    go[go[, 3] == "biological_process", 3] <- "P"
    go[go[, 3] == "cellular_component", 3] <- "C"
    go[1:4, ]
    dir.create("data/GO")
    write.table(go, "data/GO/GOannotationsBiomart_mod.txt", quote = FALSE, row.names = FALSE, 
        col.names = FALSE, sep = "\t")
    catdb <- makeCATdb(myfile = "data/GO/GOannotationsBiomart_mod.txt", lib = NULL, org = "", 
        colno = c(1, 2, 3), idconv = NULL)
    save(catdb, file = "data/GO/catdb.RData")

#### Batch GO term enrichment analysis

Apply the enrichment analysis to the DEG sets obtained in the above
differential expression analysis. Note, in the following example the
*FDR* filter is set here to an unreasonably high value, simply because
of the small size of the toy data set used in this vignette. Batch
enrichment analysis of many gene sets is performed with the
*`GOCluster_Report`* function. When *`method="all"`*, it returns all GO
terms passing the p-value cutoff specified under the *`cutoff`*
arguments. When *`method="slim"`*, it returns only the GO terms
specified under the *`myslimv`* argument. The given example shows how
one can obtain such a GO slim vector from BioMart for a specific
organism.

    load("data/GO/catdb.RData")
    DEG_list <- filterDEGs(degDF = edgeDF, filter = c(Fold = 2, FDR = 50), plot = FALSE)
    up_down <- DEG_list$UporDown
    names(up_down) <- paste(names(up_down), "_up_down", sep = "")
    up <- DEG_list$Up
    names(up) <- paste(names(up), "_up", sep = "")
    down <- DEG_list$Down
    names(down) <- paste(names(down), "_down", sep = "")
    DEGlist <- c(up_down, up, down)
    DEGlist <- DEGlist[sapply(DEGlist, length) > 0]
    BatchResult <- GOCluster_Report(catdb = catdb, setlist = DEGlist, method = "all", 
        id_type = "gene", CLSZ = 2, cutoff = 0.9, gocats = c("MF", "BP", "CC"), recordSpecGO = NULL)
    library("biomaRt")
    m <- useMart("plants_mart", dataset = "athaliana_eg_gene", host = "plants.ensembl.org")
    goslimvec <- as.character(getBM(attributes = c("goslim_goa_accession"), mart = m)[, 
        1])
    BatchResultslim <- GOCluster_Report(catdb = catdb, setlist = DEGlist, method = "slim", 
        id_type = "gene", myslimv = goslimvec, CLSZ = 10, cutoff = 0.01, gocats = c("MF", 
            "BP", "CC"), recordSpecGO = NULL)

#### Plot batch GO term results

The *`data.frame`* generated by *`GOCluster_Report`* can be plotted with
the *`goBarplot`* function. Because of the variable size of the sample
sets, it may not always be desirable to show the results from different
DEG sets in the same bar plot. Plotting single sample sets is achieved
by subsetting the input data frame as shown in the first line of the
following example.

    gos <- BatchResultslim[grep("M6-V6_up_down", BatchResultslim$CLID), ]
    gos <- BatchResultslim
    pdf("GOslimbarplotMF.pdf", height = 8, width = 10)
    goBarplot(gos, gocat = "MF")
    dev.off()
    goBarplot(gos, gocat = "BP")
    goBarplot(gos, gocat = "CC")

![](../../assets/images/doc/GOslimbarplotMF.png) <div align="center">**Figure 10:** GO Slim
Barplot for MF Ontology.</div></br>

### Clustering and heat maps

The following example performs hierarchical clustering on the *`rlog`*
transformed expression matrix subsetted by the DEGs identified in the
above differential expression analysis. It uses a Pearson
correlation-based distance measure and complete linkage for cluster
join.

    library(pheatmap)
    geneids <- unique(as.character(unlist(DEG_list[[1]])))
    y <- assay(rlog(dds))[geneids, ]
    pdf("heatmap1.pdf")
    pheatmap(y, scale = "row", clustering_distance_rows = "correlation", clustering_distance_cols = "correlation")
    dev.off()

<center><img src="../../assets/images/doc/heatmap1.png"></center>
<div align="center">

**Figure 11:** Heat map with hierarchical clustering dendrograms of
DEGs.</div></br>

## Workflow templates

The intended way of running *`systemPipeR`* workflows is via *`*.Rmd`*
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
To work with *`*.Rnw`* or *`*.Rmd`* files efficiently, basic knowledge
of [*`Sweave`*](https://www.stat.uni-muenchen.de/~leisch/Sweave/) or
[*`knitr`*](http://yihui.name/knitr/) and
[*`Latex`*](http://www.latex-project.org/) or
[*`R Markdown v2`*](http://rmarkdown.rstudio.com/) is required.

### RNA-Seq sample

Load the RNA-Seq sample workflow into your current working directory.

    library(systemPipeRdata)
    genWorkenvir(workflow = "rnaseq")
    setwd("rnaseq")

#### Run workflow

Next, run the chosen sample workflow *`systemPipeRNAseq`*
([PDF](https://github.com/tgirke/systemPipeRdata/blob/master/inst/extdata/workflows/rnaseq/systemPipeRNAseq.pdf?raw=true),
[Rmd](https://github.com/tgirke/systemPipeRdata/blob/master/inst/extdata/workflows/rnaseq/systemPipeRNAseq.Rmd))
by executing from the command-line *`make -B`* within the *`rnaseq`*
directory. Alternatively, one can run the code from the provided
*`*.Rmd`* template file from within R interactively.

The workflow includes following steps:

1.  Read preprocessing
    -   Quality filtering (trimming)
    -   FASTQ quality report
2.  Alignments: *`Tophat2`* (or any other RNA-Seq aligner)
3.  Alignment stats
4.  Read counting
5.  Sample-wise correlation analysis
6.  Analysis of differentially expressed genes (DEGs)
7.  GO term enrichment analysis
8.  Gene-wise clustering

### ChIP-Seq sample

Load the ChIP-Seq sample workflow into your current working directory.

    library(systemPipeRdata)
    genWorkenvir(workflow = "chipseq")
    setwd("chipseq")

#### Run workflow

Next, run the chosen sample workflow *`systemPipeChIPseq_single`*
([PDF](https://github.com/tgirke/systemPipeRdata/blob/master/inst/extdata/workflows/chipseq/systemPipeChIPseq.pdf?raw=true),
[Rmd](https://github.com/tgirke/systemPipeRdata/blob/master/inst/extdata/workflows/chipseq/systemPipeChIPseq.Rmd))
by executing from the command-line *`make -B`* within the *`chipseq`*
directory. Alternatively, one can run the code from the provided
*`*.Rmd`* template file from within R interactively.

The workflow includes the following steps:

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

### VAR-Seq sample

#### VAR-Seq workflow for the single machine

Load the VAR-Seq sample workflow into your current working directory.

    library(systemPipeRdata)
    genWorkenvir(workflow = "varseq")
    setwd("varseq")

#### Run workflow

Next, run the chosen sample workflow *`systemPipeVARseq_single`*
([PDF](https://github.com/tgirke/systemPipeRdata/blob/master/inst/extdata/workflows/varseq/systemPipeVARseq_single.pdf?raw=true),
[Rmd](https://github.com/tgirke/systemPipeRdata/blob/master/inst/extdata/workflows/varseq/systemPipeVARseq_single.Rmd))
by executing from the command-line *`make -B`* within the *`varseq`*
directory. Alternatively, one can run the code from the provided
*`*.Rmd`* template file from within R interactively.

The workflow includes following steps:

1.  Read preprocessing
    -   Quality filtering (trimming)
    -   FASTQ quality report
2.  Alignments: *`gsnap`*, *`bwa`*
3.  Variant calling: *`VariantTools`*, *`GATK`*, *`BCFtools`*
4.  Variant filtering: *`VariantTools`* and *`VariantAnnotation`*
5.  Variant annotation: *`VariantAnnotation`*
6.  Combine results from many samples
7.  Summary statistics of samples

#### VAR-Seq workflow for computer cluster

The workflow template provided for this step is called
*`systemPipeVARseq.Rmd`*
([PDF](https://github.com/tgirke/systemPipeRdata/blob/master/inst/extdata/workflows/varseq/systemPipeVARseq.pdf?raw=true),
[Rmd](https://github.com/tgirke/systemPipeRdata/blob/master/inst/extdata/workflows/varseq/systemPipeVARseq.Rmd)).
It runs the above VAR-Seq workflow in parallel on multiple compute nodes
of an HPC system using Slurm as the scheduler.

### Ribo-Seq sample

Load the Ribo-Seq sample workflow into your current working directory.

    library(systemPipeRdata)
    genWorkenvir(workflow = "riboseq")
    setwd("riboseq")

#### Run workflow

Next, run the chosen sample workflow *`systemPipeRIBOseq`*
([PDF](https://github.com/tgirke/systemPipeRdata/blob/master/inst/extdata/workflows/riboseq/systemPipeRIBOseq.pdf?raw=true),
[Rmd](https://github.com/tgirke/systemPipeRdata/blob/master/inst/extdata/workflows/ribseq/systemPipeRIBOseq.Rmd))
by executing from the command-line *`make -B`* within the *`ribseq`*
directory. Alternatively, one can run the code from the provided
*`*.Rmd`* template file from within R interactively.

The workflow includes following steps:

1.  Read preprocessing
    -   Adaptor trimming and quality filtering
    -   FASTQ quality report
2.  Alignments: *`Tophat2`* (or any other RNA-Seq aligner)
3.  Alignment stats
4.  Compute read distribution across genomic features
5.  Adding custom features to the workflow (e.g. uORFs)
6.  Genomic read coverage along with transcripts
7.  Read counting
8.  Sample-wise correlation analysis
9.  Analysis of differentially expressed genes (DEGs)
10. GO term enrichment analysis
11. Gene-wise clustering
12. Differential ribosome binding (translational efficiency)

## Version information

**Note:** the most recent version of this tutorial can be found
<a href="http://www.bioconductor.org/packages/devel/bioc/vignettes/systemPipeR/inst/doc/systemPipeR.html">here</a>.

    sessionInfo()

    ## R Under development (unstable) (2020-04-30 r78337)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 20.04 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/bin/lib/R/lib/libRblas.so
    ## LAPACK: /usr/bin/lib/R/lib/libRlapack.so
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
    ##  [1] DESeq2_1.29.6               magrittr_1.5               
    ##  [3] batchtools_0.9.13           ape_5.4                    
    ##  [5] ggplot2_3.3.1               systemPipeR_1.23.2         
    ##  [7] ShortRead_1.47.2            GenomicAlignments_1.25.3   
    ##  [9] SummarizedExperiment_1.19.5 DelayedArray_0.15.4        
    ## [11] matrixStats_0.56.0          Matrix_1.2-18              
    ## [13] Biobase_2.49.0              BiocParallel_1.23.0        
    ## [15] Rsamtools_2.5.1             Biostrings_2.57.2          
    ## [17] XVector_0.29.2              GenomicRanges_1.41.5       
    ## [19] GenomeInfoDb_1.25.2         IRanges_2.23.10            
    ## [21] S4Vectors_0.27.12           BiocGenerics_0.35.4        
    ## [23] BiocStyle_2.17.0            rmarkdown_2.3              
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] colorspace_1.4-1         rjson_0.2.20             hwriter_1.3.2           
    ##  [4] ellipsis_0.3.1           farver_2.0.3             bit64_0.9-7             
    ##  [7] AnnotationDbi_1.51.0     codetools_0.2-16         splines_4.1.0           
    ## [10] geneplotter_1.67.0       knitr_1.29               jsonlite_1.6.1          
    ## [13] annotate_1.67.0          GO.db_3.11.4             dbplyr_1.4.4            
    ## [16] png_0.1-7                pheatmap_1.0.12          graph_1.67.1            
    ## [19] BiocManager_1.30.10      compiler_4.1.0           httr_1.4.1              
    ## [22] GOstats_2.55.0           backports_1.1.8          assertthat_0.2.1        
    ## [25] limma_3.45.7             formatR_1.7              htmltools_0.5.0         
    ## [28] prettyunits_1.1.1        tools_4.1.0              gtable_0.3.0            
    ## [31] glue_1.4.1               GenomeInfoDbData_1.2.3   Category_2.55.0         
    ## [34] dplyr_1.0.0              rsvg_2.1                 rappdirs_0.3.1          
    ## [37] V8_3.1.0                 Rcpp_1.0.4.6             vctrs_0.3.1             
    ## [40] nlme_3.1-148             rtracklayer_1.49.3       xfun_0.15               
    ## [43] stringr_1.4.0            lifecycle_0.2.0          XML_3.99-0.3            
    ## [46] edgeR_3.31.4             zlibbioc_1.35.0          scales_1.1.1            
    ## [49] BSgenome_1.57.0          VariantAnnotation_1.35.2 hms_0.5.3               
    ## [52] RBGL_1.65.0              RColorBrewer_1.1-2       yaml_2.2.1              
    ## [55] curl_4.3                 memoise_1.1.0            biomaRt_2.45.0          
    ## [58] latticeExtra_0.6-29      stringi_1.4.6            RSQLite_2.2.0           
    ## [61] genefilter_1.71.0        checkmate_2.0.0          GenomicFeatures_1.41.0  
    ## [64] DOT_0.1                  rlang_0.4.6              pkgconfig_2.0.3         
    ## [67] bitops_1.0-6             evaluate_0.14            lattice_0.20-41         
    ## [70] purrr_0.3.4              labeling_0.3             bit_1.1-15.2            
    ## [73] tidyselect_1.1.0         GSEABase_1.51.1          AnnotationForge_1.31.2  
    ## [76] R6_2.4.1                 generics_0.0.2           base64url_1.4           
    ## [79] DBI_1.1.0                pillar_1.4.4             withr_2.2.0             
    ## [82] survival_3.2-3           RCurl_1.98-1.2           tibble_3.0.1            
    ## [85] crayon_1.3.4             BiocFileCache_1.13.0     jpeg_0.1-8.1            
    ## [88] progress_1.2.2           locfit_1.5-9.4           grid_4.1.0              
    ## [91] data.table_1.12.8        blob_1.2.1               Rgraphviz_2.33.0        
    ## [94] digest_0.6.25            xtable_1.8-4             brew_1.0-6              
    ## [97] openssl_1.4.1            munsell_0.5.0            askpass_1.1

## Funding

This project is funded by NSF award
[ABI-1661152](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1661152).

## References

H Backman, Tyler W, and Thomas Girke. 2016. “systemPipeR: NGS workflow
and report generation environment.” *BMC Bioinformatics* 17 (1): 388.
<https://doi.org/10.1186/s12859-016-1241-0>.

Howard, Brian E, Qiwen Hu, Ahmet Can Babaoglu, Manan Chandra, Monica
Borghi, Xiaoping Tan, Luyan He, et al. 2013. “High-Throughput RNA
Sequencing of Pseudomonas-Infected Arabidopsis Reveals Hidden
Transcriptome Complexity and Novel Splice Variants.” *PLoS One* 8 (10):
e74183. <https://doi.org/10.1371/journal.pone.0074183>.

Kim, Daehwan, Ben Langmead, and Steven L Salzberg. 2015. “HISAT: A Fast
Spliced Aligner with Low Memory Requirements.” *Nat. Methods* 12 (4):
357–60.

Kim, Daehwan, Geo Pertea, Cole Trapnell, Harold Pimentel, Ryan Kelley,
and Steven L Salzberg. 2013. “TopHat2: Accurate Alignment of
Transcriptomes in the Presence of Insertions, Deletions and Gene
Fusions.” *Genome Biol.* 14 (4): R36.
<https://doi.org/10.1186/gb-2013-14-4-r36>.

Langmead, Ben, and Steven L Salzberg. 2012. “Fast Gapped-Read Alignment
with Bowtie 2.” *Nat. Methods* 9 (4): 357–59.
<https://doi.org/10.1038/nmeth.1923>.

Lawrence, Michael, Wolfgang Huber, Hervé Pagès, Patrick Aboyoun, Marc
Carlson, Robert Gentleman, Martin T Morgan, and Vincent J Carey. 2013.
“Software for Computing and Annotating Genomic Ranges.” *PLoS Comput.
Biol.* 9 (8): e1003118. <https://doi.org/10.1371/journal.pcbi.1003118>.

Li, H, and R Durbin. 2009. “Fast and Accurate Short Read Alignment with
Burrows-Wheeler Transform.” *Bioinformatics* 25 (14): 1754–60.
<https://doi.org/10.1093/bioinformatics/btp324>.

Li, Heng. 2013. “Aligning Sequence Reads, Clone Sequences and Assembly
Contigs with BWA-MEM.” *arXiv \[Q-bio.GN\]*, March.
<http://arxiv.org/abs/1303.3997>.

Liao, Yang, Gordon K Smyth, and Wei Shi. 2013. “The Subread Aligner:
Fast, Accurate and Scalable Read Mapping by Seed-and-Vote.” *Nucleic
Acids Res.* 41 (10): e108. <https://doi.org/10.1093/nar/gkt214>.

Love, Michael, Wolfgang Huber, and Simon Anders. 2014. “Moderated
Estimation of Fold Change and Dispersion for RNA-seq Data with DESeq2.”
*Genome Biol.* 15 (12): 550.
<https://doi.org/10.1186/s13059-014-0550-8>.

Morgan, Martin, Hervé Pagès, Valerie Obenchain, and Nathaniel Hayden.
2019. *Rsamtools: Binary Alignment (Bam), Fasta, Variant Call (Bcf), and
Tabix File Import*. <http://bioconductor.org/packages/Rsamtools>.

Robinson, M D, D J McCarthy, and G K Smyth. 2010. “EdgeR: A Bioconductor
Package for Differential Expression Analysis of Digital Gene Expression
Data.” *Bioinformatics* 26 (1): 139–40.
<https://doi.org/10.1093/bioinformatics/btp616>.

Wu, T D, and S Nacu. 2010. “Fast and SNP-tolerant Detection of Complex
Variants and Splicing in Short Reads.” *Bioinformatics* 26 (7): 873–81.
<https://doi.org/10.1093/bioinformatics/btq057>.
