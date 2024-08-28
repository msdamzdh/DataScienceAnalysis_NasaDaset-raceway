%% Layer generatation******************************************************
lgraph = layerGraph();

% Add Layer Branches
% Add the branches of the network to the layer graph. Each branch is a
% linear array of layers.
tempLayers = imageInputLayer([24 12 1],"Name","imageinput");
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    convolution2dLayer([4 4],32,"Name","conv","Padding","same")
    layerNormalizationLayer("Name","layernorm")
    convolution2dLayer([4 4],32,"Name","conv_3","Padding","same")
    layerNormalizationLayer("Name","layernorm_3")
    flattenLayer("Name","flatten_1")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    convolution2dLayer([3 3],32,"Name","conv_1","Padding","same")
    layerNormalizationLayer("Name","layernorm_2")
    convolution2dLayer([3 3],32,"Name","conv_5","Padding","same")
    layerNormalizationLayer("Name","layernorm_5")
    flattenLayer("Name","flatten")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    convolution2dLayer([5 5],32,"Name","conv_2","Padding","same")
    layerNormalizationLayer("Name","layernorm_1")
    convolution2dLayer([5 5],32,"Name","conv_4","Padding","same")
    layerNormalizationLayer("Name","layernorm_4")
    flattenLayer("Name","flatten_2")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    concatenationLayer(1,3,"Name","concat")
    fullyConnectedLayer(1,"Name","fc")
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);

% clean up helper variable
clear tempLayers;

% Connect Layer Branches
% Connect all the branches of the network to create the network graph.
lgraph = connectLayers(lgraph,"imageinput","conv");
lgraph = connectLayers(lgraph,"imageinput","conv_1");
lgraph = connectLayers(lgraph,"imageinput","conv_2");
lgraph = connectLayers(lgraph,"flatten_1","concat/in1");
lgraph = connectLayers(lgraph,"flatten_2","concat/in2");
lgraph = connectLayers(lgraph,"flatten","concat/in3");

plot(lgraph);
%********************************************************Layer generatation