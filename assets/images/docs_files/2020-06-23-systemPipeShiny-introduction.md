---
layout: doc
title: systemPipeShiny Introduction
date: 2019-09-08 8:14:30 +0600
post_image: assets/images/service-icon3.png
tags: [systemPipeShiny]
keywords: "Documentation, systemPipeR, workflow, systemPipeShiny, visualization"
---

## Graphical User Interface: `systemPipeShiny`

To enhance user experience on data visualization and to help new users to familiarize the workflow management system, we are developing systemPipeShiny to support interactive graphics in workflow reports. This includes an interactive visualization of various statistical results and workflow topologies. 
Key features are: 

+ Interactive workflow management
  - Building metadata files from new workflows or templates;
  - Validation of the metadata files (names, file existence, statistics);
  - Visualization of the workflow structure, choose steps, preview the Rmd, and render HTML;
  - Manage workflow configuration; 
  - Run simple workflows directly from the application.
  
+ Interactive data visualization
  - Various input data types for plotting;
  - Multiple options to preprocess datasets;
  - A gallery of downstream analysis plots, such as bar plots, heat maps, Venn diagram, dendrogram, and more;
  - Interactive tweaking plotting options;
  - Custom templates and functions to extend to more types of visualization data. 

![image](../../assets/images/systemPipeShiny.png) 

Figure 1: Relevant features in `systemPipeShiny`. 