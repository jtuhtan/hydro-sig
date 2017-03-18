% HydroSigKMeans - generates a concatenated hydrodynamic signature feature
% for k-means clustering of a series of pool cross-section measurements
% Jeffrey A. Tuhtan
% Centre for Biorobotics, Dept. of Computer Systems, Tallinn University of Technology
% jetuht@ttu.ee
 
%% Dependencies
% Wind Rose: https://www.mathworks.com/matlabcentral/fileexchange/47248-wind-rose
% sort_nat: https://www.mathworks.com/matlabcentral/fileexchange/10959-sort-nat--natural-order-sort
% MATLAB Statistics and Machine Learning Toolbox
%%
    
% Set path to folder where batch routine will run using .mat formatted data
% Example for Hirnbach data:
addpath('D:\MATLAB\Kmeans\');
filePath = 'D:\MATLAB\Kmeans\Data\Hirnbach\Basin_8_Center_Profile-60s\MATLAB\Data';
     
tInt = 12000; % sample length
tDur = 1;
nt = 1;
    
filePathExport = filePath;
contents = cellstr(ls(filePath));
contents = sort_nat(contents(3:end,1)); % uses FEX SORT_NAT to get correct sorting otherwise 1,10,2,24,etc. will be used by MATLAB
%%

numFiles = size(contents,1);

for itFiles = 1:numFiles
    
    % retrieve file
    fileNameTxt = char(contents(itFiles));
    filePathFullTxt = strcat(filePath,'\',fileNameTxt);
    load(filePathFullTxt);
    disp(['Importing file: ',fileNameTxt,' ...']);
    
    close all
    clear pAllT 
    
    
    for it = 1:tInt:(tInt*tDur)
        
    %% Detrend each sensor
    p0 = detrend(ps0.b(it:it+tInt-1));
    p1 = detrend(ps1.b(it:it+tInt-1));
    p2 = detrend(ps2.b(it:it+tInt-1));
    p3 = detrend(ps3.b(it:it+tInt-1));
    p4 = detrend(ps4.b(it:it+tInt-1));
    p5 = detrend(ps5.b(it:it+tInt-1));
    p6 = detrend(ps6.b(it:it+tInt-1));
    p7 = detrend(ps7.b(it:it+tInt-1));
    p8 = detrend(ps8.b(it:it+tInt-1));
    p9 = detrend(ps9.b(it:it+tInt-1));
    p10 = detrend(ps10.b(it:it+tInt-1));
    
    end
    
pAllT(:,:,nt) = (7.5591/1000).* [p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10]; % save pressure data as kPa
       
sizep0 = size(p0,1);
    
v = abs((7.5591/1000).* [p0;p1;p2;p3;p4;p5;p6;p7;p8;p9;p10]); % convert signals to to kPa, using only abs values!
       
angles = [0,20,-20,40,-40,60,-60,80,-80,100,-100];
    
d = repmat(angles,sizep0,1);
d = d(:);
   
interval = 100*1/11; % creates scaled procent interval equal to the number of inputs (e.g. 11 data sets have to be shifted by 1/11)

% 0:1:6 kPa range for slots, 0:3 kPa for pools
pMax = 6; % max of kPa windrose scale
pStep = 6; % discretization interval 0:pStep:pMax
[figure_handle,count,speeds,directions,Table,circles] = WindRose(d,v,'anglenorth',0,'angleeast',90,'labels',{'Anterior','Posterior','Right','Left'},'MaxFrequency',interval,'inverse',false,'FreqLabelAngle',-45,'vWinds',[0:pMax/pStep:pMax],...
'cMap','jet','TitleString',{'';''},'LabLegend','Pressure (kPa)','LegendVariable','kPa','LegendType',2);

% create histogram of pressure time series data
edges = 0:pMax/pStep:pMax; % bin range and edges in kPa (KLD uses 0:0.05:5)
for pN = 1:11
    data1 = pAllT(:,pN,1);
    [PBins,PEdges] = histcounts(data1,edges);% histogram 
    PBins = PBins ./ sum(PBins); % Normalize histograms to create PDFs
    PHist(:,pN) = PBins; % save histograms of all sensors as single matrix
end

feature(itFiles,:) = PHist(:)'; % generate CS feature with all locations and concatenated PDFs

pause(1);
folder = filePath; % location to store hydrodynamic signature images
name = strcat(folder,num2str(itFiles),'_',fileNameTxt,'.png');
saveas(gcf,name);

end

disp('Hydrodynamic signatures for all cross-sections complete.');

disp('k-means clustering beginning...');

X = feature; % use .mat file with feature created using HomerRoseKmeans.m from a series of pool cross-section measurements

kRange = 2:size(X,1); % range of classes, k assessed

for itk = kRange
    
    [idx, C, sumD, D] = kmeans(X, itk, 'Distance', 'sqEuclidean', 'Replicates', 10000);

for it = 1:itk % iterate over all number of classes, 1:k
    idxK = find(idx == it); % find locations of clustered data for current class,k
end

    % sumD - within cluster sum of point to centroid distance
    % D - point to centroid distances

    sumDMin(itk-1) = min(sumD);
    sumDMean(itk-1) = mean(sumD);
    sumDMax(itk-1) = max(sumD);
    sumDRSS(itk-1) = sum(sumD);

end

disp('k-means clustering completed.');

figure(2)
plot(kRange,sumDMin); % min elbow plot
hold on
plot(kRange,sumDMean); % mean elbow plot
plot(kRange,sumDMax); % max elbow plot
plot(kRange,sumDRSS); % sum elbow plot

xlabel('Number of clusters, k');
ylabel('Averaged sum of point to centroid distances');
legend('min','mean','max','sum');

