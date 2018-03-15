
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This script compares the active learning with random learning for
    % classifier prediction. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
startup

ActiveData=load('classActiveCurrent.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pass al GP related information using the gpoptions structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.NumInducingClass=300;
gpoptions.sparseMargin=5000;
gpoptions.classHyperParams.minimize=0;
Dimension=ActiveData.gpoptions.Dimension;
if strcmp(Dimension,'2D')
    TestData=load('Alearning_2D_10k_Grid.mat');
elseif strcmp(Dimension,'4D')
    TestData=load('Alearning_4D_100k_Test.mat');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load up the initial, random training, and test dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R_init=ActiveData.R_InitClassTrain;  %initial training data
y_init=ActiveData.y_InitClassTrain;


R_train=ActiveData.R_random;    % random training data
y_train=ActiveData.y_random;

R_test=TestData.gk;           % test dataset
y_test=TestData.APDtrue;

nu = fix(length(ActiveData.R_ALtrain)); cu = randperm(length(R_train)); cu = cu(1:nu); 
R_random = R_train(cu,:);
y_random = y_train(cu);


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
       if k==1 && size(R_rand,2)==2
            contMapD=certainty( R_rand, y_rand, grid2D, ActiveData.outparam );
            contMapA=certainty( R_active, y_active, grid2D, ActiveData.outparam );
            swarm=[R_active R_rand];
            plotRandomContours(swarm,j,contMapA, contMapD, 'classifier' )
       end 
            gpoptions.classHyperParams=ActiveData.outparam;
            gpoptions.classHyperParams.minimize=0;
            gpoptions.classHyperParams.UQ=0;
            [y_star_class, R_star_AP, y_star_AP] = boundaryDetector(R_rand, y_rand, R_test, gpoptions.classHyperParams, y_test);
        for i=1:length(R_test)
            if y_test(i)==1000
                y_test_class(i)=1;
            elseif y_test(i)==0
                y_test_class(i)=-1;
            else
                y_test_class(i)=0;
            end
        end
        randMisClassP=0;
        y_test_class=y_test_class+1;y_star_class=y_star_class+1;
        for i=1:length(R_test)
            if y_test_class(i)~=y_star_class(i)
                randMisClassP=randMisClassP+1;
            end
        end
        ClassifierErrorRand(j,k)=(100*randMisClassP)/length(R_test); 
        clear y_test_class; clear y_star_class;
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
        gpoptions.classHyperParams=ActiveData.outparam;
        gpoptions.classHyperParams.minimize=0;
        gpoptions.classHyperParams.UQ=0;
        [y_star_class, R_star_AP, y_star_AP] = boundaryDetector(R_active, y_active, R_test, gpoptions.classHyperParams, y_test);
        for i=1:length(R_test)
            if y_test(i)==1000
                y_test_class(i)=1;
            elseif y_test(i)==0
                y_test_class(i)=-1;
            else
                y_test_class(i)=0;
            end
        end
        activeMisClassP=0;
        y_test_class=y_test_class+1;y_star_class=y_star_class+1;
        for i=1:length(R_test)
            if y_test_class(i)~=y_star_class(i)
                activeMisClassP=activeMisClassP+1;
            end
        end
        ClassifierErrorActive(j)=(100*activeMisClassP)/length(R_test); 
        clear y_test_class; clear y_star_class;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot Error Curves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
m=mean(ClassifierErrorRand,2);s2=std(ClassifierErrorRand');s2=s2';CScale=CScale';
f = [m+s2; flipdim(m-s2,1)]; 
fill([CScale; flipdim(CScale,1)], f, [1 0.968627452850342 0.921568632125854]);
plot(CScale,mean(ClassifierErrorRand,2),'b','MarkerSize',8,'Marker','diamond','LineWidth',3)
plot(CScale,ClassifierErrorActive,'r','MarkerSize',8,'Marker','diamond','LineWidth',3)
xlim([CScale(1) CScale(end)])
xlabel('Training Size')
ylabel('Misclassification Rate (%)')
set(axes1,'FontSize',20);
legend('Confidence interval Random Error','Random Error (mean out of 10 runs)', 'Active Error')
title('Classifier Active Learning')

command='rm -rf *.txt';
system(command);
command='rm -rf classActiveCurrent.mat';
system(command);
