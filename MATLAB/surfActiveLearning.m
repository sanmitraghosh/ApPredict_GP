

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This script gathers actively learnt training data for
    % classifier/boundary prediction. This corresponds to the Fig3 in the paper.
    % You can control the following variables to get different
    % behaviour::
    % 1) 'n1'--No. of initial random sampled data
    % 1) 'ns'--Active swarm/particle size. For surface fix this to 1
    % 1) 'n2'--No. active learning n2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
startup

GridData=load('Alearning_2D_10k_Grid.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pass al GP related information using the gpoptions structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Dimension='4D';
n1=500;
ns=1;
n2=2500;
STOPSURF=n1 + n2*ns;
gpoptions.n2=n2;
gpoptions.n1=n1;
gpoptions.Dimension=Dimension;
gpoptions.twoStep=0;
gpoptions.pacing=100;
gpoptions.NumInducingClass=300;
gpoptions.sparseMargin=5000;
gpoptions.NumInducingSurf=1000;
gpoptions.sparseMarginSurf=10000;
gpoptions.classHyperParams.minimize=0;
gpoptions.surfHyperParams.minimize=0;
gpoptions.covarianceKernels=@covRQiso;
gpoptions.covarianceKernelsParams=[0.1;0.21;1]; % Ifound these to work
gpoptions.likelihoodParams=0.015; % as well as this
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.paperData=1;  %%% Change this to `0` if you want fresh init data
gpoptions.figurepath=pwd;
if strcmp(Dimension,'2D')
    load('Alearning_2D_10k_Train.mat');
elseif strcmp(Dimension,'4D')
    load('Alearning_4D_100k_Train.mat');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load up a pool of random training data
    % from which we will draw randomely to compare with active learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R_random=gk;
y_random=APDtrue;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Use the gridded data for visualisations for the 2D case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(gk,2)==2
    R_Grid=GridData.gk;
    y_Grid=GridData.APDtrue;
    [ ~, labelGrid ] = labelFinder( R_Grid, y_Grid);
    dlmwrite('GridLabels.txt',labelGrid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Sample Initial Random Training Data from the pool loaded earlier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nu = fix(n1); cu = randperm(length(R_random)); cu = cu(1:nu); 
R_InitClassTrain = R_random(cu,:);
y_InitClassTrain = y_random(cu,:); %%% Start with random n1 points
R_random(cu,:)=[]; %%% Remove these chosen points from the pool
y_random(cu)=[];

%%%%%%%%%%%%%%%%%%%%% This is to replicate paper results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if gpoptions.paperData ==1
    if size(R_random,2)==2
        initData=load('./data/2D/surfActive2DpaperInit.mat');
    else
        initData=load('./data/4D/surfActive4DpaperInit.mat');
    end
    R_InitClassTrain = initData.R_Initrandom;
    y_InitClassTrain = initData.y_Initrandom; %%% Start with random n1 points
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Learn a classifier to constrain the chosen active points in the AP
%   region
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gpoptions.LearningMode='classifier';
outparam= learnGPhyp( R_InitClassTrain, y_InitClassTrain, gpoptions );
gpoptions.classHyperParams=outparam;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Learn hyperparameters for surface active learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ ~, label ] = labelFinder( R_InitClassTrain, y_InitClassTrain );
Cord=find(label(:,2)==1);
R_InitSurfTrain= R_InitClassTrain(Cord,:);
y_InitSurfTrain= y_InitClassTrain(Cord);

gpoptions.LearningMode='surface';
outparam= learnGPhyp( R_InitSurfTrain, y_InitSurfTrain, gpoptions );
gpoptions.surfHyperParams=outparam;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Do n2 rounds of surface active learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.Batch=0;
gpoptions.method='grid'; % Flag to trigger the swarming types or grid ('grid' 'pso' 'ga')
gpoptions.Model='APD';
gpoptions.LearningMode='surface';
gpoptions.STOP=STOPSURF;
gpoptions.ns=ns;
gpoptions.classHyperParams.minimize=0;
gpoptions.surfAlClass=1;
gpoptions.pltDisabled=0; % Turning it on starts plotting contour plots (slow)
gpoptions.ALtime=ones(100,1);

[ R_ALtrain, y_ALtrain ] = sequentialDesign( R_InitClassTrain, y_InitClassTrain, gpoptions );
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Keep only the AP related points for the active training data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ ~, label ] = labelFinder(R_ALtrain, y_ALtrain);
Cord=find(label(:,2)==1);
R_ALtrain= R_ALtrain(Cord,:);
y_ALtrain= y_ALtrain(Cord);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Keep only the AP related points for random training data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ ~, label ] = labelFinder( R_random, y_random );
Cord=find(label(:,2)==1);
R_train= R_random(Cord,:);
y_train= y_random(Cord);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Save the dataset, please rename accordingly!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save('surfActiveCurrent.mat')
% Clean-up
command='rm -rf *.txt';
system(command);
if size(gk,2)==2
    dlmwrite('GridLabels.txt',labelGrid);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Call up evaluation script to compare with random learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
surfActiveLearningtest
