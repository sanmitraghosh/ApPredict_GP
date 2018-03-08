
%%%%%%%%%%%%% This script runs the iterative active learning for
%%%%%%%%%%%%% accumulating training points for the O'hara model. NB: the
%%%%%%%%%%%%% dataset contains pretrained hyperparameters of a GP
%%%%%%%%%%%%% classifier and the APD90 dataset 0f 100K
% rsync -avz /home/sanosh/work_oxford/Arcus-GP coml0640@arcus-b.arc.ox.ac.uk:/data/coml-cardiac/coml0640


%%%%%%%%%%%%%%%%%%%%%%%
    % Set random seed
%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
addpath(genpath('/data/coml-cardiac/coml0640/Backup/ApPredict_GPmat'))
startup
load('Alearning_4D_100k_Train.mat');
TestData=load('Alearning_4D_100k_Test.mat');
% tic;
a=pwd;
if strcmp(a(end-1),'a')
	num=str2num(a(end));
else 
num=str2num(a(end-1))*10 + str2num(a(end));
end
n1=num*500;
ns=50;
Telapsed=zeros(1000,1);
STOPCLASS=n1 + 4*ns;
STOPSURF=n1 + 2*4*ns;
gpoptions.pacing=100;
gpoptions.NumInducingClass=300;
gpoptions.sparseMargin=1000;
gpoptions.NumInducingSurf=1000;
% if n1 >10000 && n1<=25000
% gpoptions.NumInducingSurf=5000;
% elseif n1 >25000
% gpoptions.NumInducingSurf=10000;
% end
gpoptions.sparseMarginSurf=10500;
gpoptions.classHyperParams.minimize=0;
gpoptions.surfHyperParams.minimize=0;
gpoptions.covarianceKernels=@covRQiso;
gpoptions.covarianceKernelsParams=[0.1;0.1;1];
gpoptions.likelihoodParams=0.015;
tic;
R_train=gk;
Y_train=APDtrue;
[ ~, labelTrain ] = labelFinder( R_train, Y_train );
CordTrain=find(labelTrain(:,2)==1);
R_train= R_train(CordTrain,:);
Y_train=Y_train(CordTrain);

R_test=TestData.gk;
Y_test=TestData.APDtrue;
[ ~, labelTest ] = labelFinder( R_test, Y_test );
CordTest=find(labelTest(:,2)==1);
R_test= R_test(CordTest,:);
Y_test=Y_test(CordTest);


nu = fix(n1); cu = randperm(length(R_train)); cu = cu(1:nu); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R_train = R_train(cu,:);
y_train=Y_train(cu,:); %%% Start with random n1 points
gpoptions.LearningMode='surface';
outparam= learnGPhyp( R_train, y_train, gpoptions );%these training points should include Dep region only
TrainTime=toc;
gpoptions.surfHyperParams=outparam;
tic;
gpoptions.surfHyperParams.minimize=0;
[PredFinal,UnCert]= pred_scatter_sparse( R_train, y_train, R_test, gpoptions.surfHyperParams );
SurfaceError=mean(abs(Y_test-PredFinal));
predTime=toc;
totalTime=TrainTime + predTime;
data=strcat(num2str(n1),'.mat');
save (data)
exit;


