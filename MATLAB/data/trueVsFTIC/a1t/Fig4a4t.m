
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

ActiveData=load('classActive4D4t.mat');
TestData=load('Alearning_4D_100k_Test.mat');%Change this with 'Alearning_4D_100k_Test.mat' for 4D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pass al GP related information using the gpoptions structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.NumInducingClass=300;
gpoptions.sparseMargin=5000;
gpoptions.classHyperParams.minimize=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load up the initial, random training, and test dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X_init=ActiveData.x_InitTrain;  %initial training data
Y_init=ActiveData.y_InitTrain;


X_train=ActiveData.X_train;    % random training data
Y_train=ActiveData.Y_train;

X_test=TestData.gk;           % test dataset
Y_test=TestData.APDtrue;

nu = fix(length(ActiveData.x_train)); cu = randperm(length(X_train)); cu = cu(1:nu); 
x_train = X_train(cu,:);
y_train = Y_train(cu);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Test surface error on random data (draw 10 times to get average)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CScale=[length(X_init):50:length(ActiveData.x_train)];
[t1,t2] = ndgrid(linspace(0,1,100)); 
grid2D = [t1(:),t2(:)];
for k=1:10
        nu = fix(length(ActiveData.x_train)); cu = randperm(length(X_train)); cu = cu(1:nu); 
        x_train = X_train(cu,:);
        y_train = Y_train(cu);
    for j=1:length(CScale)
        if j==1
        x_dumb=X_init;
        y_dumb=Y_init;  
        X_active=X_init;%%% For viz contour
        Y_active=Y_init;
        else
        x_dumb=[X_init; x_train(1:CScale(j)-CScale(1),:)];
        y_dumb=[Y_init; y_train(1:CScale(j)-CScale(1))]; 
        X_active=ActiveData.x_train(1:CScale(j),:);
        Y_active=ActiveData.y_train(1:CScale(j)); 
        
        end
       if k==1 && size(x_dumb,2)==2
        contMapD=certainty( x_dumb, y_dumb, grid2D, ActiveData.outparam );
        contMapA=certainty( X_active, Y_active, grid2D, ActiveData.outparam );
        swarm=[X_active x_dumb];
        plotDumbContours( swarm,j,contMapA, contMapD, 'classifier' )
       end 
        gpoptions.classHyperParams=ActiveData.outparam;
        gpoptions.classHyperParams.minimize=0;
        [Yp, RepG, yRepG ] = build_multi_domains( x_dumb, y_dumb, X_test, Y_test, gpoptions.classHyperParams );
        for i=1:length(X_test)
            if Y_test(i)==1000
                Yt(i)=1;
            elseif Y_test(i)==0
                Yt(i)=-1;
            else
                Yt(i)=0;
            end
        end
        dumbMisClassP=0;
        Yt=Yt+1;Yp=Yp+1;
            for i=1:length(X_test)
                if Yt(i)~=Yp(i)
                    dumbMisClassP=dumbMisClassP+1;
                end
            end
        ClassifierErrorDumb(j,k)=(100*dumbMisClassP)/length(X_test); 
        clear Yt; clear Yp;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Test surface error on active learning data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:length(CScale)
        if j==1
        X_active=X_init;
        Y_active=Y_init;
        else
        X_active=ActiveData.x_train(1:CScale(j),:);
        Y_active=ActiveData.y_train(1:CScale(j)); 
        
        end
        gpoptions.classHyperParams=ActiveData.outparam;
        gpoptions.classHyperParams.minimize=0;
        [Yp, RepG, yRepG ] = build_multi_domains( X_active, Y_active, X_test, Y_test, gpoptions.classHyperParams );

        %%%%%%%%%% True Class Labels %%%%%%%%%%%%%%%%%%
        for i=1:length(X_test)
            if Y_test(i)==1000
                Yt(i)=1;
            elseif Y_test(i)==0
                Yt(i)=-1;
            else
                Yt(i)=0;
            end
        end
        activeMisClassP=0;%%%%build confusion
        Yt=Yt+1;Yp=Yp+1;
            for i=1:length(X_test)
                if Yt(i)~=Yp(i)
                    activeMisClassP=activeMisClassP+1;
                end
            end
        ClassifierErrorActive(j)=(100*activeMisClassP)/length(X_test); 
        clear Yt; clear Yp;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot Error Curves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save('resultTrue4.mat');
exit;


