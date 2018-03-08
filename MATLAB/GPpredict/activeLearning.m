function [X,APD,Enew] = activeLearning( E, x, y, gpoptions )
%%%%%% This function is used to iteratively add training points %%%%
Model=gpoptions.Model;
Batch=gpoptions.Batch;
LM=gpoptions.LearningMode;
Init_Pace=gpoptions.pacing;
ns=gpoptions.ns;
%%%%%%%%%%%% Setup the optimisation problem %%%%%%%
    if strcmp(LM,'classifier')
            HyperParams=gpoptions.classHyperParams;
            ObjectiveFunction=@(swarm) certainty( x, y, swarm, HyperParams );
    elseif strcmp(LM,'surface')
            HyperParams=gpoptions.surfHyperParams;
            ObjectiveFunction=@(swarm) surfaceCertainty( x, y, swarm, HyperParams );
    end
            dim=size(x,2);
            nvars=dim;
            LB=zeros(1,nvars);
            UB=ones(1,nvars);
            

%%%%%%%%%%%% This commented bit is for 2D vdo generation only %%%%%%%
        if strcmp(gpoptions.method,'pso')
                if dim==2
                    dlmwrite('psoBatch.txt',Batch);%%%for video
                    [t1,t2] = ndgrid(linspace(0,1,100)); 
                    grid2D = [t1(:),t2(:)];
                    contMap=certainty( x, y, grid2D, HyperParams );
                    dlmwrite('contMap.txt',contMap);
                    dlmwrite('XY.txt',[x y]);
                end
            Xinit=unifrnd(0.1,0.9,ns,dim);
            optionspso = optimoptions(@particleswarm,'OutputFcn',@pswplotranges,'MaxIter',130,...,
                'InitialSwarmSpan',0.5,'InitialSwarm',Xinit,'Vectorized','on','UseParallel',true,'Display','iter','SwarmSize',ns,'MinFractionNeighbors',0.25)
            optionspso.TolFun=1e-3;
            [xbest,fval,exitflag,output] = particleswarm(ObjectiveFunction,nvars,LB,UB,optionspso)%%% can't get the population as output
            X = dlmread('myFile.txt');
                if dim==2
                        dummy=ones(length(X),2);
                        X2d=cat(2,X,dummy);
                        APD=EvaluateAPD(X2d,Init_Pace); 
                else%%% option for toy
                        APD=EvaluateAPD(X,Init_Pace);
                end
            
%             Scattered=unifrnd(0,1,1e4,dim);
%             classUncert=certainty( X, APD, Scattered, HyperParams );
%             dlmwrite(strcat('Class2D501002K-',num2str(Batch),'classX.txt'),Scattered); For unc Integrtn
%             dlmwrite(strcat('Class2D501002K-',num2str(Batch),'classUncertainty.txt'),classUncert);
            Enew=X;
        elseif  strcmp(gpoptions.method,'grid')  %|| strcmp(gpoptions.method,'lCurveSurface') 
            [UnCert] = surfaceCertainty( x, y, E, HyperParams  );
%             dlmwrite(strcat('Surf-',num2str(Batch),'surfX.txt'),E);
%             dlmwrite(strcat('Surf-',num2str(Batch),'surfUncertainty.txt'),UnCert);
            [a,Upos]=sort(UnCert);%sort(UnCert(1:ns));
            Upos=flip(Upos);
            X=E(Upos(1:ns),:);% Enew=E(flip(Upos),:);
            APD=(1:ns)';
            %% This part for viz %%%
            disp(Batch)
                if dim==2 && gpoptions.pltDisabled==0
                        Iter=Batch;
                        if ns==1
                            if mod(Batch,10)==0 && Iter<=gpoptions.n2%(floor(Iter)==Iter)
                                [t1,t2] = ndgrid(linspace(0,1,100)); 
                                gridSurf2D = [t1(:),t2(:)];
                                [UnCertSurf2D] = surfaceCertainty( x, y, gridSurf2D, HyperParams  );
                                labgrid=dlmread('GridLabels.txt');
                                cordOutside=labgrid(:,2);%find(labgrid(:,2)==-1);
                                figure
                                ax=gca;
                                hold (ax,'on');
                                 contourf(t1, t2, reshape(UnCertSurf2D, size(t1)), 10);
                                 
                                 contourf(t1, t2, reshape(cordOutside, size(t1)), 'LineWidth',2,'LineColor','w',...
    'LevelList',[-1 -0.5 0 0.5],'Fill','Off');
                                colorbar
                                %colormap(hot)
%                                 scatter(gridSurf2D(cordOutside,1),gridSurf2D(cordOutside,2),15,...,
%                                     'MarkerFaceColor','g','MarkerEdgeColor',[0 0 0],'LineWidth',2);
                                scatter(X(:,1),X(:,2),150,...,
                                    'MarkerFaceColor','b','MarkerEdgeColor',[0 0 0],'LineWidth',2);
                                scatter(x(:,1),x(:,2),100,...,
                                    'MarkerFaceColor',[1 1 0],'MarkerEdgeColor',[0 0 0],'LineWidth',2);
                                set(ax, 'XLimMode', 'manual', 'YLimMode', 'manual');
                                 xlim([0 1]);ylim([0 1]);
                                set(gcf, 'Position', get(0, 'Screensize'),'PaperPositionMode','auto'); 
                                drawnow;
                                axis tight manual;
                                title(strcat('Surf--',num2str(Iter)));
                                fname = '/home/sanosh/work_oxford/ApPredict_GPmat/Figure/videos/surfActive2D';
                                zlabel('Certainty');
                                saveas(gcf,fullfile(fname,num2str(Iter)),'fig');
                            end
                        else 
                                [t1,t2] = ndgrid(linspace(0,1,100)); 
                                gridSurf2D = [t1(:),t2(:)];
                                [UnCertSurf2D] = surfaceCertainty( x, y, gridSurf2D, HyperParams  );
                                labgrid=dlmread('GridLabels.txt');
                                cordOutside=find(labgrid(:,2)==-1);
                                figure
                                ax=gca;
                                hold (ax,'on');
                                 contourf(t1, t2, reshape(UnCertSurf2D, size(t1)), 10);
                                colorbar
                                colormap(hot)
                                scatter(gridSurf2D(cordOutside,1),gridSurf2D(cordOutside,2),15,...,
                                    'MarkerFaceColor','g','MarkerEdgeColor',[0 0 0],'LineWidth',2);
                                scatter(X(:,1),X(:,2),100,...,
                                    'MarkerFaceColor','b','MarkerEdgeColor',[0 0 0],'LineWidth',2);
                                scatter(x(50:end,1),x(50:end,2),100,...,
                                    'MarkerFaceColor',[1 1 0],'MarkerEdgeColor',[0 0 0],'LineWidth',2);
            %                     scatter(E(:,1),E(:,2),10,...,
            %                         'MarkerFaceColor','y','MarkerEdgeColor',[0 0 0],'LineWidth',2);
                                set(ax, 'XLimMode', 'manual', 'YLimMode', 'manual');
                                 xlim([0 1]);ylim([0 1]);
                                set(gcf, 'Position', get(0, 'Screensize'),'PaperPositionMode','auto'); 
                                drawnow;
                                axis tight manual;
                                title(strcat('Surf--',num2str(Batch)));
                                fname = '/home/sanosh/work_oxford/ApPredict_GPmat/Figure/videos/surfActive2D';
                                zlabel('Certainty');
                                saveas(gcf,fullfile(fname,num2str(Batch)),'fig');
                        end
                end
            E(Upos(1:ns),:)=[];
            Enew=E;
        end

end

