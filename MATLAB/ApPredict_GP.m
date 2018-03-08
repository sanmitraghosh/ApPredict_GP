
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This script runs the iterative active learning for
    % accumulating training points for the O'hara emulator using
    % Gaussian Processes.
    % You can control the following variables to get different
    % behaviour::
    % 1) 'n1'--No. of initial random sampled data
    % 1) 'ns'--Active swarm/particle size. For surface fix this to 1
    % 1) 'Rounds**'--No. active learning rounds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scp coml0640@arcus-b.arc.ox.ac.uk:/data/coml-cardiac/coml0640/Backup/ApPredict_GPmat/Fig1_bck/Fig1lCurve.mat /home/sanosh/work_oxford/ApPredict_GPmat/results/
% scp ApPredict_GP_fitc4Dinit.mat  coml0640@arcus-b.arc.ox.ac.uk:/data/coml-cardiac/coml0640/Backup/ApPredict_GPmat/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
startup
TestData=load('Alearning_4D_100k_Test.mat');% Change this with 'Alearning_4D_100k_Test.mat' for 4D
n1=50; %% Initial random data size
ns=10; %% Active learning swarm size
n2=100; %% Number of surface active learning rounds
r=5; %% Number of classifier active learning rounds
Telapsed=zeros(1000,1);
STOPCLASS=n1 + r*ns;
STOPSURF=n1 + n2*ns/ns;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pass al GP related information using the gpoptions structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.twoStep=1;
gpoptions.n1=n1;
gpoptions.pacing=100;
gpoptions.NumInducingClass=300; % Inducing points for classifier
gpoptions.sparseMargin=100; % No of training points upto which we use exact classifier inference
gpoptions.NumInducingSurf=1000; % Inducing points for surface
gpoptions.sparseMarginSurf=20000; % No of training points upto which we use exact surface inference
gpoptions.classHyperParams.minimize=0;
gpoptions.surfHyperParams.minimize=0;
gpoptions.covarianceKernels=@covRQiso;%{'covMaterniso',5};
gpoptions.covarianceKernelsParams=[0.1;0.1;1];%[0.1;1.20];
gpoptions.likelihoodParams=0.015;
gpoptions.paperData=1;
gpoptions.cornerCases=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Sample Initial Random Training Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;
if size(TestData.gk,2)==2
    R_InitTrain = unifrnd(0,1,2,n1)';
    y_InitTrain=EvaluateAPD([R_InitTrain ones(n1,2)],gpoptions.pacing);
    R_Grid=TestData.gk;
    y_Grid=TestData.APDtrue;
    [ ~, labelGrid ] = labelFinder( R_Grid, y_Grid);
    dlmwrite('GridLabels.txt',labelGrid);
elseif gpoptions.paperData==1;
    initData=load('./data/twoStep/fitc4Dinit.mat');
    R_InitTrain=initData.X_init;
    y_InitTrain=initData.Y_init;
else
    R_InitTrain = unifrnd(0,1,4,n1)';
    y_InitTrain=EvaluateAPD(R_InitTrain,gpoptions.pacing);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Add corner cases for Drug Block UQ task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if gpoptions.cornerCases==1
    
    CornerCases=dlmread('./data/twoStep/CornerCases.txt');
    APDCornerCases=EvaluateAPD(CornerCases,gpoptions.pacing);

    R_InitTrain=[R_InitTrain;CornerCases];
    y_InitTrain=[y_InitTrain;APDCornerCases];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Classifier Learning Phase
%   Learn Hyperparameters for Active Classifier Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gpoptions.LearningMode='classifier';
outparam= learnGPhyp( R_InitTrain, y_InitTrain, gpoptions );
gpoptions.classHyperParams=outparam;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Do a few Rounds of Active Classifier Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gpoptions.Batch=0;
gpoptions.method='pso'; % Flag to trigger the swarming types or grid ('grid' 'pso' 'ga')
gpoptions.Model='APD';
gpoptions.STOP=STOPCLASS;
gpoptions.ns=ns;
[ R_ALClassTrain, y_ALClassTrain ] = sequentialDesign( R_InitTrain, y_InitTrain, gpoptions );
% TclassActive=dlmread(Telapsed.txt);
close all

R_train_class=R_ALClassTrain;
y_train_class=y_ALClassTrain;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Update/Re-learn Hyperparameters after Active Classifier Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.LearningMode='classifier';
outparam= learnGPhyp( R_train_class, y_train_class, gpoptions );
gpoptions.classHyperParams=outparam;
TclassTrain=toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Surface Learning Phase
%   Learn Hyperparameters for Active Surface Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
[ ~, label ] = labelFinder( R_InitTrain, y_InitTrain );
Cord=find(label(:,2)==1);
R_InitSurfTrain= R_InitTrain(Cord,:);
y_InitSurfTrain= y_InitTrain(Cord);
gpoptions.LearningMode='surface';
outparam= learnGPhyp( R_InitSurfTrain, y_InitSurfTrain, gpoptions );
gpoptions.surfHyperParams=outparam;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Do a few Rounds of Active Surface Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.Batch=0;
gpoptions.method='grid'; % Flag to trigger the swarming types or grid ('grid' 'pso' 'ga')
gpoptions.Model='APD';
gpoptions.LearningMode='surface';
gpoptions.STOP=STOPSURF;
gpoptions.ns=1;
gpoptions.classHyperParams.minimize=0;
gpoptions.surfAlClass=1;
gpoptions.pltDisabled=0;
gpoptions.ALtime=ones(100,1);
[ R_ALSurfTrain, y_ALSurfTrain ] = sequentialDesign( [R_train_class;R_InitTrain], [y_train_class;y_InitTrain], gpoptions );
% TsurfActive=dlmread(Telapsed.txt);
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Filter out only AP related data after Active Surface Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ ~, label ] = labelFinder( R_ALSurfTrain, y_ALSurfTrain );
Cord=find(label(:,2)==1);
R_ALSurfTrain= R_ALSurfTrain(Cord,:);
y_ALSurfTrain= y_ALSurfTrain(Cord);
R_train_surf=[R_InitSurfTrain;R_ALSurfTrain];
y_train_surf=[y_InitSurfTrain;y_ALSurfTrain];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Update/Re-learn Hyperparameters after Active Surface Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.LearningMode='surface';
if size(R_surf,2)==4
% gpoptions.covarianceKernelsParams=[1;1;0.1];% for 4D the initial values are set like this;
    gpoptions.covarianceKernelsParams=[1;1;0.25];% for 4D the initial values are set like this;
end
outparam= learnGPhyp( R_train_surf, y_train_surf, gpoptions );
gpoptions.surfHyperParams=outparam;

TsurfTrain=toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Error and Prediction Phase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
R_test=TestData.gk;
y_test=TestData.APDtrue;

%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%% Classifier errors %%%%%%%%%%%%%%%%%%%
gpoptions.classHyperParams.UQ=0;
[y_star_class, R_test_AP, y_test_AP] = boundaryDetector(R_train_class, y_train_class, R_test, gpoptions.classHyperParams, y_test);

%%%%%%%%%% True Class Labels %%%%%%%%%%%%%%%%%%
for i=1:length(R_test)
    if y_test(i)==1000
        y_test_class(i)=1;
    elseif y_test(i)==0
        y_test_class(i)=-1;
    else
        y_test_class(i)=0;
    end
end
%%%%%%%%%% Predicted Class Labels %%%%%%%%%%%%%%%%%%
MisClassP=0;%%%%build confusion
y_test_class=y_test_class+1;y_star_class=y_star_class+1;
    for i=1:length(R_test)
        if y_test_class(i)~=y_star_class(i)
            MisClassP=MisClassP+1;
        end
    end
ClassifierError=MisClassP; 
PercClassifierError=100*(ClassifierError/length(R_test));
TclassPred=toc;
%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%% Surface errors %%%%%%%%%%%%%%%%%%%
tic;
gpoptions.surfHyperParams.minimize=0;
[y_star_AP,Entropy]= surfaceGP(R_surf, Y_surf, R_test_AP, gpoptions.surfHyperParams);
SurfaceError=mean(abs(y_test_AP'-y_star_AP));
TsurfPred=toc;
%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%% Plot the Final results/surface %%%%%%%%%
plot3(R_test_AP(:,1),R_test_AP(:,2),y_test_AP,'*','MarkerSize',1);
hold on;
plot3(R_test_AP(:,1),R_test_AP(:,2),y_star_AP,'g*','MarkerSize',1);
% Clean-up
command='rm -rf *.txt';
system(command);

