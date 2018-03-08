function [ R_train, y_train ] = sequentialDesign( R_InitTrain, y_InitTrain, gpoptions )
        counter=0;
        time=1;
        gpoptions.Batch=0;
        LM=gpoptions.LearningMode;
        n1=gpoptions.n1;
        E=unifrnd(0,1,1e4,size(R_InitTrain,2));
        if strcmp(LM,'surface')
            if gpoptions.twoStep==1
                R_ClassTrain=R_InitTrain(1:n1,:);
                y_ClassTrain=y_InitTrain(1:n1);
                R_InitTrainSurf=R_InitTrain(n1+1:end,:);
                y_InitTrainSurf=y_InitTrain(n1+1:end);
            else
                R_ClassTrain=R_InitTrain;
                y_ClassTrain=y_InitTrain;
                R_InitTrainSurf=R_InitTrain;
                y_InitTrainSurf=y_InitTrain;
            end

            if gpoptions.surfAlClass==1
                 lab=justClassifier(R_ClassTrain, y_ClassTrain, E, gpoptions.classHyperParams ) ; 
                 Cord=find(lab==1);
                 E= E(Cord,:);
            end
                 [ ~, label ] = labelFinder( R_InitTrainSurf, y_InitTrainSurf );
                 Cord=find(label(:,2)==1);
                 R_InitTrain= R_InitTrainSurf(Cord,:);
                 y_InitTrain= y_InitTrainSurf(Cord);
                 
        end
        R_Active=R_InitTrain;
        APDpermute=y_InitTrain;
        APDtrain=APDpermute; %%% these will be grown intelligently
        R_Activetrain=R_Active; %%% same for these
        Telapsed=zeros(500,1);

                while length(R_Active)<gpoptions.STOP%% Now iterate until you accumulate desired no. of training pnts
                    gpoptions.Batch=gpoptions.Batch+1;
                    [Rnew,APDnew,Enew] = activeLearning(E, R_Active, APDpermute, gpoptions );
                    time=time+1;
                    if strcmp(LM,'classifier')
                    	APDpermute=[APDpermute;APDnew]; % this is when we use all points grown so far
                    	R_Active=[R_Active;Rnew];
                    	tu=randperm(length(APDpermute));
                    	R_Active=R_Active(tu,:);
                    	APDpermute=APDpermute(tu); %% Shuffle them
                    	APDtrain=[APDtrain;APDnew]; % this is when we use all points grown so far
                    	R_Activetrain=[R_Activetrain;Rnew];
                    elseif strcmp(LM,'surface')
                    	APDpermute=[APDpermute;APDnew]; % this is when we use all points grown so far
                    	R_Active=[R_Active;Rnew];
                    	R_Activetrain=[R_Activetrain;Rnew];
                    	E=Enew;
                    end
                    counter=counter+gpoptions.ns;
                    disp('loop')
                    disp(length(R_Active))
                end
                    if strcmp(LM,'classifier')
                         R_train=R_Activetrain; 
                         y_train=APDtrain;
                    elseif strcmp(LM,'surface') 
                         R_train=R_Activetrain;
                         HyperParams=gpoptions.classHyperParams;
                         lab=justClassifier(R_ClassTrain, y_ClassTrain, R_train, HyperParams ) ; %
                         Cord=find(lab==1);
                         R_train= R_train(Cord,:);
                            if size(R_train,2)==2
                                    dummy=ones(length(R_train),2);
                                    R_train2d=cat(2,R_train,dummy);
                                    y_train=EvaluateAPD(R_train2d,gpoptions.pacing); 
                            else%%% option for toy
                                    y_train=EvaluateAPD(R_train,gpoptions.pacing);
                            end
                           
                    end

end

