%% Clear and laod data set*************************************************
clc;
close all;
clear;
load ('algae.mat','algae');
% **************************************************Clear and laod data set
%% Extract data************************************************************
Dataset = struct;
notUsedData = ["DICVsChloride",...
        "NitrateVsChloride","PhosphateVsChloride","comments"];
for i=1:3
    fieldNames = setdiff(string(fieldnames(algae(i))),notUsedData);
    for j=1:numel(fieldNames)
        dataName = fieldNames(j);
        Time = datetime(string(algae(i).(dataName).time));
        Data = algae(i).(dataName).data;
        Dataset(i).(dataName).TimeTable = timetable(Time,Data,...
            'VariableNames',"raw");
    end
    Dataset(i).Names = fieldNames;
end
clearvars -except Dataset
%**************************************************************Extract data
%% Plot raw data***********************************************************
nSample = 3000;
for i=1:3
    figure
    t=tiledlayout("flow");
    for j=1:numel(Dataset(i).Names)
        nexttile
        dataName = Dataset(i).Names(j);
        Time = Dataset(i).(dataName).TimeTable.Time;
        if numel(Time)>nSample
            data = Dataset(i).(dataName).TimeTable.raw(1:nSample);
            plot(Time(1:nSample),data)
        else
            data = Dataset(i).(dataName).TimeTable.raw;
            plot(Time,data)
        end
        xlabel('Time')
        ylabel(dataName)
     end
    title(t,"Raw data of the "+i+"'th raceway");
end
clearvars -except Dataset
% ************************************************************Plot raw data
%% Effect of number of samples in outlier detection************************
outlierDetectionMethods = ["median","mean","quartiles","grubbs","gesd"];
nSample = [2000,5000];
nout = zeros(2,6);
for i=1:numel(nSample)
    figure
    t2 = tiledlayout("flow");
    Y = Dataset(1).irradiance.TimeTable.raw(1:nSample(i));
    Time = Dataset(1).irradiance.TimeTable.Time(1:nSample(i));
    for j=1:numel(outlierDetectionMethods)
        TF = isoutlier(Y,outlierDetectionMethods(j));
        nout(i,j) = sum(TF);
        nexttile
        plot(Time,Y,Time(TF),Y(TF),'o',"MarkerFaceColor",'r');
        title(outlierDetectionMethods(j))
        ylabel("Irradiance")
        xlabel("Time")
    end
    title(t2,nSample(i)+" samples ")
end
clearvars -except Dataset outlierDetectionMethods
%%*************************Effect of number of samples in outlier detection
%% Outlier replacement with NAN********************************************
for i=1:3
     nr = numel(Dataset(i).Names); nc = numel(outlierDetectionMethods)+1;
     Data = zeros(nr,nc);
    for j=1:nr
        dataName = Dataset(i).Names(j);
        data = Dataset(i).(dataName).TimeTable.raw;
        TF = zeros(numel(data),nc);
        for k=1:nc-1
            TF(:,k) = isoutlier(data,outlierDetectionMethods(k));
            Data(j,k)=sum(TF(:,k));
        end
         intersected = all(TF(:,1:end-1),2);
         data(intersected) = nan;
         Dataset(i).(dataName).TimeTable.filled_Nan = data;
         Data(j,end) = sum(intersected);
    end
    Dataset(i).outlierNumbers=array2table(Data);
    Dataset(i).outlierNumbers.Properties.RowNames=Dataset(i).Names;
    Dataset(i).outlierNumbers.Properties.VariableNames=...
         [outlierDetectionMethods,"intersected"];
end
clearvars -except Dataset
%**********************************************Outlier replacement with NAN
%% Remove missing time data and fill nan values****************************
for i=1:3
    for j=1:numel(Dataset(i).Names)
        dataName = Dataset(i).Names(j);
        Tbl = Dataset(i).(dataName).TimeTable;
        uniqueTime = unique(Tbl.Time);
        uniqueTime(ismissing(uniqueTime)) = [];
        Dataset(i).(dataName).TimeTable = retime(Tbl,uniqueTime,'mean');
        Tbl = Dataset(i).(dataName).TimeTable;
        Dataset(i).(dataName).TimeTable = sortrows(Tbl);
        data = Dataset(i).(dataName).TimeTable.filled_Nan;
        data = fillmissing(data,"linear");
        Dataset(i).(dataName).TimeTable.replaced_Nan = data;
        Time = Dataset(i).(dataName).TimeTable.Time;
        if numel(unique(Time))==numel(Time)
           msg1 = sprintf("%s Data set for %d'th raceway is unique",...
               Dataset(i).Names(j),i);
        else
           msg1 = sprintf("%s Data set for %d'th raceway is not " + ...
               "unique",Dataset(i).Names(j),i);
        end
        if isempty(find(ismissing(data), 1))
           msg2 = sprintf("%s Data set for %d'th raceway has no" + ...
               " missing value",Dataset(i).Names(j),i);
        else
           msg2 = sprintf("%s Data set for %d'th raceway has " + ...
               "missing value",Dataset(i).Names(j),i);
        end
        disp(msg1)
        disp(msg2)
    end
end
clearvars -except Dataset
%***************************** Remove missing time data and fill nan values
%% Data smoothing**********************************************************
for i=1:3
    for j=1:numel(Dataset(i).Names)
        dataName = Dataset(i).Names(j);
        Tbl = Dataset(i).(dataName).TimeTable;
        Y = Tbl.replaced_Nan;
        if ismember(dataName,["temperature","irradiance"])
            smoothed_version = movavg(Y,"simple",48);
        else
            X = daysdif(Tbl.Time(1),Tbl.Time);
            Mdl = fitrgp(X,Y,"FitMethod","fic",...
                "KernelFunction","matern52");
            smoothed_version = predict(Mdl,X);
            Dataset(i).MDModels.(dataName)=Mdl;
        end
            Dataset(i).(dataName).TimeTable.smoothed = smoothed_version;
     end
end
clearvars -except Dataset
%************************************************************Data smoothing
%% Plot smoothed data******************************************************
nSample = 3000;
for i=1:3
    figure
    t=tiledlayout("flow");
    for j=1:numel(Dataset(i).Names)
        nexttile
        dataName = Dataset(i).Names(j);
        Time = Dataset(i).(dataName).TimeTable.Time;
        if numel(Time)>nSample
            data = Dataset(i).(dataName).TimeTable.smoothed(1:nSample);
            plot(Time(1:nSample),data)
        else
            data = Dataset(i).(dataName).TimeTable.smoothed;
            plot(Time,data)
        end
        xlabel('Time')
        ylabel(dataName)
     end
    title(t,"Smoothed data of the "+i+"'th raceway");
end
clearvars -except Dataset
%********************************************************Plot smoothed data
%% Data resampling*********************************************************
timeframe = "daily";
funcNames = ["max","min","mode","mean"];
newColNames = funcNames+"-temp";
for i=1:3
    temperature = Dataset(i).temperature.TimeTable(:,"smoothed");
    irradiance = Dataset(i).irradiance.TimeTable(:,"smoothed");
    Tbl = innerjoin(temperature,irradiance);
    Tbl.Properties.VariableNames = "smoothed-"+["temperature","irradiance"];
    Dataset(i).irradiance.TTsynchTemp = Tbl;
    for j=1:numel(funcNames)
        data = retime(temperature,timeframe,funcNames(j));
        if j==1
            dailyTemp = timetable(data.Time,data.smoothed,...
                'VariableNames',funcNames(j));
        else
            dailyTemp.(funcNames(j)) = data.smoothed;
        end
    end
    dailyTemp.Properties.VariableNames=newColNames;
    Names = setdiff(Dataset(i).Names,["temperature","irradiance"]);
    Dataset(i).phoDetails = Names;
    for j=1:numel(Names)
        data = Dataset(i).(Names(j)).TimeTable(:,"smoothed");
        data.Properties.VariableNames = "smoothed-"+Names(j);
        Tbl = innerjoin(dailyTemp,data);
        Dataset(i).(Names(j)).TTsynchTemp = Tbl;
        pho = corrcoef(table2array(Tbl));
        Dataset(i).(Names(j)).phoTable = array2table(pho,"RowNames",...
            [newColNames,"smoothed-"+Names(j)],"VariableNames",...
            [newColNames,"smoothed-"+Names(j)]);
        diagPho = diag(pho);
        pho = pho-diag(diagPho);
        [pmax,pmaxInd] = max(abs(pho(end,:)));
        Dataset(i).phoDetails(j,2)=newColNames(pmaxInd);
    end
end
clearvars -except Dataset
%***********************************************************Data resampling
%% Plot synched data*******************************************************
for i=1:3
    figure
    t=tiledlayout("flow");
    axLabel = Dataset(i).phoDetails;
    for j=1:size(axLabel,1)
        nexttile
        dataName = axLabel(j,1);
        colName = "smoothed-"+axLabel(j,1);
        varName = axLabel(j,2);
        X = Dataset(i).(dataName).TTsynchTemp.(varName);
        Y = Dataset(i).(dataName).TTsynchTemp.(colName);
        scatter(X,Y)
        xlabel(varName)
        ylabel(colName)
    end
    title(t,"Data of the "+i+"'th raceway vs temperature");
end
clearvars -except Dataset
%*********************************************************Plot synched data
%% Probaility model********************************************************
Names = setdiff(Dataset(1).Names,["temperature","irradiance"]);
fitType = "thinplateinterp";
t=tiledlayout("flow");
for i=1:numel(Names)
    data = [];
    for j=1:3
        data = [data;Dataset(j).(Names(i)).TTsynchTemp.Variables];
    end
    data(:,1:3)=[];
    [N,c] =hist3(data,"nbins",[15,15],"FaceColor","interp",...
        "CDataMode","auto");
    Pdf = N/sum(N,"all");
    Pdf = Pdf(:);
    [temp,var] = meshgrid(c{1},c{2});
    temp = temp(:);var = var(:);
    fitobject = fit([temp,var],Pdf,fitType);
    Dataset(j).(Names(i)).fitObject = fitobject;
    nexttile
    plot(fitobject)
    xlabel("temperature")
    ylabel(Names(i))
    zlabel("PDF")
end
clearvars -except Dataset
%**********************************************************Probaility model
%% Feature extraction******************************************************
dataName = "salinity";
Hx = 24;Mx=0;Sx=0;
dy = 1;
allData = {};
allTarget = [];
for i=1:3
    temp = Dataset(i).temperature.TimeTable(:,"smoothed");
    T2 = Dataset(i).(dataName).TimeTable.Time(dy+1:end);
    T1 = T2-duration(Hx,Mx,Sx);
    data = Dataset(i).(dataName).TimeTable.("smoothed");
    for k=1:numel(T1)
        tdate = find(temp.Time>=T1(k) & temp.Time<T2(k));
        allData{end+1} = [temp(tdate,:).smoothed;data(k)];
        allTarget = [allTarget,data(k+1)];
    end
end
% Remove smaples with unsufficient features 
a = cell2mat(cellfun(@(x)size(x,1),allData,'UniformOutput',false));
[b,c] = groupcounts(a');
[~,ind] = max(b);
badData = find(a~=c(ind));
allData(badData)=[];
allTarget(badData)=[];
% Split train and test data
allData = cell2mat(allData);
[nfeature,nSample] = size(allData);
trSamples = randi([1,nSample],floor(0.7*nSample),1);
teSamples = setdiff(1:nSample,trSamples);
allData = reshape(allData,24,12,1,nSample);
Xtrain = arrayDatastore(allData(:,:,:,trSamples),"IterationDimension",4);
Xtest = arrayDatastore(allData(:,:,:,teSamples),"IterationDimension",4);
Ytrain = arrayDatastore(allTarget(:,trSamples),"IterationDimension",2);
Ytest = arrayDatastore(allTarget(:,teSamples),"IterationDimension",2);
% Create Data sotres
Dataset(4).(dataName).TrDs = combine(Xtrain,Ytrain);
Dataset(4).(dataName).TeDs = combine(Xtest,Ytest);
clearvars -except Dataset dataName
%********************************************************Feature extraction
%% Layer generatation******************************************************
LG
%********************************************************Layer generatation
%% Train Network***********************************************************
Options = trainingOptions("adam",...
                          "MiniBatchSize",20,...
                          "InitialLearnRate",0.001,...
                          "ValidationData",Dataset(4).(dataName).TeDs,...
                          "MaxEpochs",300,...
                          "Plots","training-progress",...
                          "OutputNetwork","best-validation-loss");

net = trainNetwork(Dataset(4).(dataName).TrDs,lgraph,Options);
Dataset(4).(dataName).network = net;
%*************************************************************Train Network
%% Feature extraction for Temp and Irr*************************************
Tbl = Dataset(1).irradiance.TTsynchTemp;
nSample = size(Tbl,1)-2;
allData = [Tbl.("smoothed-temperature")(1:end-2)';...
            Tbl.("smoothed-temperature")(2:end-1)';...
            Tbl.("smoothed-irradiance")(2:end-1)'];
allTarget = Tbl.("smoothed-irradiance")(3:end)';
allData = reshape(allData,3,1,nSample);
% Split train and test data
trSamples = randi([1,nSample],floor(0.7*nSample),1);
teSamples = setdiff(1:nSample,trSamples);
Xtrain = arrayDatastore(allData(:,:,trSamples),"IterationDimension",3);
Xtest = arrayDatastore(allData(:,:,teSamples),"IterationDimension",3);
Ytrain = arrayDatastore(allTarget(:,trSamples),"IterationDimension",2);
Ytest = arrayDatastore(allTarget(:,teSamples),"IterationDimension",2);
% Create Data sotres
Dataset(4).irradiance.TrDs = combine(Xtrain,Ytrain);
Dataset(4).irradiance.TeDs = combine(Xtest,Ytest);
clearvars -except Dataset dataName
%************************************** Feature extraction for Temp and Irr
%% Layer generatation******************************************************
LG2
%********************************************************Layer generatation
%% Train Network***********************************************************
Options = trainingOptions("adam",...
                          "MiniBatchSize",500,...
                          "InitialLearnRate",0.001,...
                          "ValidationData",Dataset(4).irradiance.TeDs,...
                          "MaxEpochs",300,...
                          "Plots","training-progress",...
                          "OutputNetwork","best-validation-loss");

net = trainNetwork(Dataset(4).irradiance.TrDs,lgraph,Options);
Dataset(4).irradiance.network = net;
%*************************************************************Train Network