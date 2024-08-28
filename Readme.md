## Project Summary: Spirulina platensis Raceway Cultivation Data Analysis
This project focuses on analyzing data from experiments involving the cultivation of Spirulina platensis in three open-channel shallow artificial ponds called raceway ponds.
The dataset includes various measurements such as pH, optical density, oxygen concentration, chlorophyll a, salinity, PAM measurements, air temperature, and irradiance.
This dataset is downloadable from this [link](https://www.nasa.gov/intelligent-systems-division/discovery-and-systems-health/pcoe/pcoe-data-set-repository/)

### Project Structure

**DSProj**: Contains all MATLAB scripts and functions used for data analysis and modeling.

**Report.pdf**: Provides a comprehensive, step-by-step guide detailing the methodology, analysis process, and results interpretation.

**algae.mat**: Original dataset file containing measurements from the Spirulina platensis cultivation experiments.

**README.md**: This file, offering an overview of the project and its structure.

To replicate the analysis, please refer to the detailed instructions in the Report.pdf file while executing the scripts found in the DSProj directory.

Key aspects of the project include:
1. Data Preprocessing
2. Data Processing

### Data Preprocessing:

1. Extraction and plotting of raw data from the algae.mat file
2. Identification and replacement of outlier data using multiple methods
3. Removal of duplicates and filling of missing values
4. Data smoothing using Gaussian process theory and moving averages
   
Here some images of Data Preprocessing section from Repord.pdf is uploaded.
![image](https://github.com/user-attachments/assets/23209747-714d-44a8-a17e-060e0aa47f75)


### Data Processing:

1. Synchronization of datasets with temperature data
2. Calculation of probability functions for various parameters in relation to temperature
3. Regression analysis using deep learning models to find relationships between temperature and other variables by using Deep Learning Models.

Here some images of Data Processing section from Repord.pdf is uploaded.
![image](https://github.com/user-attachments/assets/2ac2cba9-0c84-4b53-913b-ea016cf06328)

### Results and Analysis:

Presentation of validation RMSE values for each dataset's deep learning model Visualization of relationships between variables and temperatureGeneration of 
probability density functions (PDFs) for each dataset in relation to temperature.

This project demonstrates the application of advanced data analysis techniques, including machine learning, to better understand the growth dynamics of Spirulina platensis 
in raceway pond cultivation. The insights gained from this analysis could be valuable for optimizing algae cultivation processes and potentially contribute to 
NASA's research on oxygen production and CO2 sequestration for space exploration.
