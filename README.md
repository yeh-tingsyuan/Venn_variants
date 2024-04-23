# Venn Variants  
**Visualization of Shared and Unique Mutations among SARS-CoV-2 Variants**  

## Overview

This repository contains an **R Shiny web application** designed to visualize mutation signatures of SARS-CoV-2 variants.  
The application allows users to explore and analyze the mutation patterns of different variants. 
Through the interactive **Venn diagrams** and detailed data tables, it enhances efficiency in identifying the shared and unique mutations among SARS-CoV-2 variants.

## Key Features

- **Variant Selection**: Users can choose specific SARS-CoV-2 variants of interest from a list provided in the application.
- **Venn Diagram Visualization**: Mutation signatures of selected variants are depicted using Venn diagrams, highlighting shared and unique mutations.
- **Interactive Data Table**: Detailed information on mutation intersections is presented in an interactive data table, facilitating in-depth analysis.
- **Download Options**: Users can download the generated Venn diagrams and mutation intersection data tables for further analysis.

## Usage

1. **Installation**:  
Ensure that R and the required R packages (`shiny`, `rjson`, `ggVennDiagram`, `ggplot2`, `plotly`, and `DT`) are installed on your system.
2. **Data Preparation**:  
Place the JSON file containing mutation data (`Mutations_2023-May-05.json`) in the same directory as the R script.  
The JSON file's content is customizable to include additional variants. However, it's important to adhere to the demonstrated key-value structure within the file.  
3. **Execution**:  
Run the R script (`Venn_diagram_app.R`) using R or RStudio.  
4. **Accessing the Application**:  
Once the script is executed, the Shiny application will be launched in your default web browser. Interact with the application by selecting variants and exploring the visualizations and data table.
5. **Downloading Results**:  
Use the provided download buttons within the application to save the generated Venn diagrams and mutation intersection data tables to your local system.

## Acknowledgments

- The project leverages various R packages for visualization and interactivity, including ggVennDiagram, shiny, plotly, and ggplot2.
