
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This script compares the active learning with random learning for
    % surface prediction. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
startup
ActiveData=load('surfActiveCurrent.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pass al GP related information using the gpoptions structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.NumInducingSurf=1000;
gpoptions.sparseMarginSurf=10000;
gpoptions.classHyperParams.minimize=0;
gpoptions.surfHyperParams.minimize=0;
gpoptions.covarianceKernels=@covRQiso;
gpoptions.covarianceKernelsParams=[0.1;0.21;1];

gpoptions.likelihoodParams=0.015;
Dimension=ActiveData.gpoptions.Dimension;
if strcmp(Dimension,'2D')
    TestData=load('Alearning_2D_10k_Grid.mat');
elseif strcmp(Dimension,'4D')
    TestData=load('Alearning_4D_100k_Test.mat');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load up the initial, random training, and test dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R_init=ActiveData.R_InitSurfTrain; %initial training data
y_init=ActiveData.y_InitSurfTrain;


R_train=ActiveData.R_train;    % random training data
y_train=ActiveData.y_train;

R_test=TestData.gk;           % test dataset
y_test=TestData.APDtrue;

[ ~, label ] = labelFinder( R_test, y_test );
Cord=find(label(:,2)==1);
R_test= R_test(Cord,:);
y_test= y_test(Cord);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Test surface error on random data (draw 10 times to get average)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CScale=[length(R_init):25:length(ActiveData.R_ALtrain)];
[t1,t2] = ndgrid(linspace(0,1,100)); 
grid2D = [t1(:),t2(:)];
for k=1:10
        nu = fix(length(ActiveData.R_ALtrain)); cu = randperm(length(R_train)); cu = cu(1:nu); 
        R_random = R_train(cu,:);
        y_random = y_train(cu);
    for j=1:length(CScale)
        if j==1
            R_rand=R_init;
            y_rand=y_init;  
            R_active=R_init;%%% For viz contour
            y_active=y_init;
        else
            R_rand=[R_init; R_random(1:CScale(j)-CScale(1),:)];
            y_rand=[y_init; y_random(1:CScale(j)-CScale(1))]; 
            R_active=ActiveData.R_ALtrain(1:CScale(j),:);
            y_active=ActiveData.y_ALtrain(1:CScale(j)); 
        
        end
%%%%%%%%%%%%%%%%%%%% This bit is for visualisation in the 2D case %%%%%%%%%
       if k==1
            if size(R_rand,2)==2
                contMapR=surfaceCertainty( R_rand, y_rand, grid2D, ActiveData.outparam );
                contMapA=surfaceCertainty( R_active, y_active, grid2D, ActiveData.outparam );
                swarm=[R_active R_rand];
                plotRandomContours(swarm, j, contMapA, contMapR, 'surface')
            end
       end 
        gpoptions.surfHyperParams=ActiveData.outparam;
        gpoptions.surfHyperParams.minimize=0;
        [y_star_Rand,UnCertRand]= surfaceGP( R_rand, y_rand, R_test, gpoptions.surfHyperParams );
        SurfaceErrorRand(j,k)=mean(abs(y_test-y_star_Rand));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Test surface error on active learning data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:length(CScale)
        if j==1
            R_active=R_init;
            y_active=y_init;
        else
            R_active=ActiveData.R_ALtrain(1:CScale(j),:);
            y_active=ActiveData.y_ALtrain(1:CScale(j)); 
        
        end
        gpoptions.surfHyperParams=ActiveData.outparam;
        gpoptions.surfHyperParams.minimize=0;
        
        [y_star_Active,UnCertActive]= surfaceGP( R_active, y_active, R_test, gpoptions.surfHyperParams );

        SurfaceErrorActive(j)=mean(abs(y_test-y_star_Active));

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot Error Curves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
m=mean(SurfaceErrorRand,2);s2=std(SurfaceErrorRand');s2=s2';CScale=CScale';
f = [m+s2; flipdim(m-s2,1)]; 
fill([CScale; flipdim(CScale,1)], f, [1 0.968627452850342 0.921568632125854]);
plot(CScale,mean(SurfaceErrorRand,2),'b','LineWidth',3)
plot(CScale,SurfaceErrorActive,'r','LineWidth',3)
xlim([CScale(1) CScale(end)])
xlim([CScale(1) CScale(end)])
xlabel('Training Size')
ylabel('Mean Absolute Error in APD90 (ms)')
set(axes1,'FontSize',20);
legend('Confidence interval Random Error','Random Error (mean out of 10 runs)', 'Active Error')
title('Surface Active Learning')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot predicted Surface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure 
plot3(R_test(:,1),R_test(:,2),y_star_Active,'*','MarkerSize',1)
hold on
plot3(R_test(:,1),R_test(:,2),y_test,'*','MarkerSize',1)
title('Surface Predictions')
xlabel('gNa')
ylabel('gKr')
zlabel('APD90')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot prediction errors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Error=abs(y_test-y_star_Active);
LocError=find(Error>20);
length(LocError)
figure
plot3(R_test(:,1),R_test(:,2),Error,'*','MarkerSize',1)
title('Error Surface')
xlabel('gNa')
ylabel('gKr')
zlabel('mean absolute error')
% Clean-up
command='rm -rf *.txt';
system(command);
command='rm -rf surfActiveCurrent.mat';
system(command);