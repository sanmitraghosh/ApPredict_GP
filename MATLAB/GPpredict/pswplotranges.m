function [stop,op] = pswplotranges(optimValues,state)
%% this is a function modified from MATLAB tutorial for scatter plots of poulations%%%

stop = false; % This function does not stop the solver
switch state
    case 'init'
        if size(optimValues.swarm,2)==2
             figure
        end
    case 'iter'
      if size(optimValues.swarm,2)==2

            [t1,t2] = ndgrid(linspace(0,1,100)); 
            t = [t1(:),t2(:)]; 
            contMap=dlmread('contMap.txt');
            xy=dlmread('XY.txt');x=xy(:,1:2);y=xy(:,3);
            [ ~, label ] = labelFinder( x,y );
                Cord1=find(label(:,2)==-1);
                Cord2=find(label(:,2)==1);
%                 Cord3=find(label(:,3)==1);
             contBound=dlmread('GridLabels.txt');  

%             scatter(optimValues.swarm(:,1),optimValues.swarm(:,2),180,...,
%                 'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0],'LineWidth',2);
            IterNum=(num2str(optimValues.iteration));
            ax=gca;
            hold (ax,'on');

            scatter(x(Cord1,1),x(Cord1,2),150,...,
                'MarkerEdgeColor','green',...,
            'MarkerFaceColor',[0.831372559070587 0.815686285495758 0.7843137383461],...,
            'Marker','square','LineWidth',2);

            scatter(x(Cord2,1),x(Cord2,2),150,...,
                'MarkerEdgeColor','green',...,
            'MarkerFaceColor',[0.831372559070587 0.815686285495758 0.7843137383461],...,
            'Marker','diamond','LineWidth',2);
             contour(t1, t2, reshape(contMap, size(t1)), 'LevelList',[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]);
%              contour(t1, t2, reshape(contBound(:,3), size(t1)), 2, 'm');
%              contour(t1, t2, reshape(contBound(:,2), size(t1)), 2, 'm');
            scatter(optimValues.swarm(:,1),optimValues.swarm(:,2),180,...,
                'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0],'LineWidth',2);
            legend('No-AP', 'AP','Certainty','Swarm Points')
            set(ax, 'XLimMode', 'manual', 'YLimMode', 'manual');
             xlim([0 1]);ylim([0 1]);xlabel('R_{Na}');ylabel('R_{Kr}');
            set(ax,'FontSize',20);
            set(gcf, 'Position', get(0, 'Screensize'),'PaperPositionMode','auto'); 
            drawnow;
            axis tight manual;
            Batch=num2str(dlmread('psoBatch.txt'));
            title(strcat('Round r=',Batch,' PSO Iteration--',IterNum));
            fname = '/home/sanosh/work_oxford/ApPredict_GPmat/Figure/videos/psoActive2D';
            zlabel('Certainty');
            saveas(gcf,fullfile(fname,strcat(Batch,'Iter','--',IterNum)),'fig')

            pause(0.05)
            close

      end



        if optimValues.meanfval <0.5
            stop=true;
            dlmwrite('myFile.txt',optimValues.swarm);

        end  
        
        
    case 'done'
                dlmwrite('myFile.txt',optimValues.swarm);

        
end