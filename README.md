# hydro-sig
Data and MATLAB code to create hydrodynamic signatures from a artificial lateral line probe

The Matlab script HydroSigKMean.m creates the hydrodynamic signatures, generates a concatenated features for the collection of measurement data in a single folder and performs k-means clustering with an elbow plot to determine the optimal number of clusters.

A PDF outlining the use of the script and data is provided in the "MATLAB_Code_User_Guide".

All lateral line probe raw measurement data are included in the folder Raw_Data. The data is organized based on each of the three vertical slot fishways; Hirnbach, Runserau and Wenns. At each site, the measurements were segregated into two folders, Pool_Cross-Sections or Slots. The basin numbering based on figure 6 of the submitted manuscript reflects the numbering of each measurement location (Basin 4 is labeled "B04").
