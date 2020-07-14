download.file(url="https://raw.githubusercontent.com/tgirke/systemPipeR/master/vignettes/systemPipeR.Rmd", 
                destfile = "systemPipeR.Rmd")
library(rmarkdown)
rmarkdown::render('systemPipeR.Rmd', c('BiocStyle::md_document'), clean=T)
file <- "systemPipeR.Rmd"
render("systemPipeR.Rmd", md_document())
rename <- paste0(format(Sys.Date(), "%Y-%m-%d-"), systemPipeR:::.getFileName(file), ".md")
file.rename("systemPipeR.md", rename)
unlink("systemPipeR.Rmd")

download.file(url="https://raw.githubusercontent.com/tgirke/systemPipeR/master/vignettes/systemPipeR_workflows.Rmd", 
              destfile = "systemPipeR_workflows.Rmd")
#library(rmarkdown)
# rmarkdown::render('systemPipeR_workflows.Rmd', c('BiocStyle::md_document'), clean=T)
file <- "systemPipeR_workflows.Rmd"
# source("../../../SYS_DEVEL/systemPipeR/R/SYSargsList.R")
render("systemPipeR_workflows.Rmd", md_document())
rename <- paste0(format(Sys.Date(), "%Y-%m-%d-"), .getFileName(file), ".md")
file.rename("systemPipeR_workflows.md", rename)
unlink("systemPipeR_workflows.Rmd")

download.file(url="https://raw.githubusercontent.com/tgirke/systemPipeRdata/master/vignettes/systemPipeChIPseq.Rmd", 
              destfile = "systemPipeChIPseq.Rmd")
#library(rmarkdown)
# rmarkdown::render('systemPipeR_workflows.Rmd', c('BiocStyle::md_document'), clean=T)
file <- "systemPipeChIPseq.Rmd"
# source("../../../SYS_DEVEL/systemPipeR/R/SYSargsList.R")
render("systemPipeChIPseq.Rmd", md_document())
rename <- paste0(format(Sys.Date(), "%Y-%m-%d-"), .getFileName(file), ".md")
file.rename("systemPipeChIPseq.md", rename)
unlink("systemPipeChIPseq.Rmd")

download.file(url="https://raw.githubusercontent.com/tgirke/systemPipeRdata/master/vignettes/systemPipeRIBOseq.Rmd", 
              destfile = "systemPipeRIBOseq.Rmd")
#library(rmarkdown)
# rmarkdown::render('systemPipeR_workflows.Rmd', c('BiocStyle::md_document'), clean=T)
file <- "systemPipeRIBOseq.Rmd"
# source("../../../SYS_DEVEL/systemPipeR/R/SYSargsList.R")
render("systemPipeRIBOseq.Rmd", md_document())
rename <- paste0(format(Sys.Date(), "%Y-%m-%d-"), .getFileName(file), ".md")
file.rename("systemPipeRIBOseq.md", rename)
unlink("systemPipeRIBOseq.Rmd")

download.file(url="https://raw.githubusercontent.com/tgirke/systemPipeRdata/master/vignettes/systemPipeRNAseq.Rmd", 
              destfile = "systemPipeRNAseq.Rmd")
#library(rmarkdown)
# rmarkdown::render('systemPipeR_workflows.Rmd', c('BiocStyle::md_document'), clean=T)
file <- "systemPipeRNAseq.Rmd"
# source("../../../SYS_DEVEL/systemPipeR/R/SYSargsList.R")
render("systemPipeRNAseq.Rmd", md_document())
rename <- paste0(format(Sys.Date(), "%Y-%m-%d-"), .getFileName(file), ".md")
file.rename("systemPipeRNAseq.md", rename)
unlink("systemPipeRNAseq.Rmd")

download.file(url="https://raw.githubusercontent.com/tgirke/systemPipeRdata/master/vignettes/systemPipeVARseq.Rmd", 
              destfile = "systemPipeVARseq.Rmd")
#library(rmarkdown)
# rmarkdown::render('systemPipeR_workflows.Rmd', c('BiocStyle::md_document'), clean=T)
file <- "systemPipeVARseq.Rmd"
# source("../../../SYS_DEVEL/systemPipeR/R/SYSargsList.R")
render("systemPipeVARseq.Rmd", md_document())
rename <- paste0(format(Sys.Date(), "%Y-%m-%d-"), .getFileName(file), ".md")
file.rename("systemPipeVARseq.md", rename)
unlink("systemPipeVARseq.Rmd")


download.file(url="https://raw.githubusercontent.com/tgirke/systemPipeRdata/master/vignettes/systemPipeRdata.Rmd", 
              destfile = "systemPipeRdata.Rmd")
#library(rmarkdown)
# rmarkdown::render('systemPipeR_workflows.Rmd', c('BiocStyle::md_document'), clean=T)
file <- "systemPipeRdata.Rmd"
# source("../../../SYS_DEVEL/systemPipeR/R/SYSargsList.R")
render("systemPipeRdata.Rmd", md_document())
rename <- paste0(format(Sys.Date(), "%Y-%m-%d-"), .getFileName(file), ".md")
file.rename("systemPipeVARseq.md", rename)
unlink("systemPipeRdata.Rmd")
