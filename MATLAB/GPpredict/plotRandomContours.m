function plotted = plotRandomContours( swarm,Batch,contMapActive,contMapDumb,mode,ActiveData)

            Batch=Batch-1;
            [t1,t2] = ndgrid(linspace(0,1,100)); 
            t = [t1(:),t2(:)]; 
           
            if strcmp(mode,'classifier')
                    subplot(1,2,1)                              
                    ax=gca;
                    hold on;
                    contour(t1, t2, reshape(contMapActive, size(t1)), 10);
                    colorbar
%                     colormap(hot)
                    scatter(swarm(:,1),swarm(:,2),100,...,
                        'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0],'LineWidth',2);
                    set(ax, 'XLimMode', 'manual', 'YLimMode', 'manual');
                     xlim([0 1]);ylim([0 1]);
                     title(strcat('Active--',num2str(Batch)));
                    set(gcf, 'Position', get(0, 'Screensize'),'PaperPositionMode','auto'); 
                    drawnow;
                    axis tight manual;

                    subplot(1,2,2)                              
                    ax=gca;
                    hold on;
                    contour(t1, t2, reshape(contMapDumb, size(t1)), 10);
                    colorbar
%                     colormap(hot)
                    scatter(swarm(:,3),swarm(:,4),100,...,
                        'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0],'LineWidth',2);
                    set(ax, 'XLimMode', 'manual', 'YLimMode', 'manual');
                     xlim([0 1]);ylim([0 1]);
                     title(strcat('Dumb--',num2str(Batch)));
                    set(gcf, 'Position', get(0, 'Screensize'),'PaperPositionMode','auto'); 
                    drawnow;
                    axis tight manual;

                    fname = '/home/sanosh/work_oxford/ApPredict_GPmat/Figure/videos/compareClassifier2D';
                    zlabel('Certainty');
                    saveas(gcf,fullfile(fname,strcat('CompareContours--',num2str(Batch))),'fig')
            else
                
                    labgrid=dlmread('GridLabels.txt');
                    cordOutside=find(labgrid(:,2)==-1);
                    subplot(1,2,1)                              
                    ax=gca;
                    hold on;
                     contourf(t1, t2, reshape(contMapActive, size(t1)), 10);
                    colorbar
%                     colormap(hot)
                    cordOutside = ActiveData.labelGrid(:,2);
                    contourf(t1, t2, reshape(cordOutside, size(t1)), 'LineWidth',3,'LineColor','w','LevelList',[-1 -0.5 0 0.5],'Fill','Off');

%                     scatter(t(cordOutside,1),t(cordOutside,2),15,...,
%                         'MarkerFaceColor','g','MarkerEdgeColor',[0 0 0],'LineWidth',2);
                    scatter(swarm(:,1),swarm(:,2),100,...,
                        'MarkerFaceColor','b','MarkerEdgeColor',[0 0 0],'LineWidth',2);
                    set(ax, 'XLimMode', 'manual', 'YLimMode', 'manual');
                     xlim([0 1]);ylim([0 1]);
                    set(gcf, 'Position', get(0, 'Screensize'),'PaperPositionMode','auto'); 
                    drawnow;
                    axis tight manual;
                    title(strcat('Active--',num2str(Batch)));

                    
                    subplot(1,2,2)                              
                    ax=gca;
                    hold on;
                     contourf(t1, t2, reshape(contMapDumb, size(t1)), 10);
                    colorbar
%                     colormap(hot)
                    contourf(t1, t2, reshape(cordOutside, size(t1)), 'LineWidth',3,'LineColor','w','LevelList',[-1 -0.5 0 0.5],'Fill','Off');
%                     scatter(t(cordOutside,1),t(cordOutside,2),15,...,
%                         'MarkerFaceColor','g','MarkerEdgeColor',[0 0 0],'LineWidth',2);
                    scatter(swarm(:,3),swarm(:,4),100,...,
                        'MarkerFaceColor','b','MarkerEdgeColor',[0 0 0],'LineWidth',2);
                    set(ax, 'XLimMode', 'manual', 'YLimMode', 'manual');
                     xlim([0 1]);ylim([0 1]);
                    set(gcf, 'Position', get(0, 'Screensize'),'PaperPositionMode','auto'); 
                    drawnow;
                    axis tight manual;
                    title(strcat('Dumb--',num2str(Batch)));
                    
                    
                    fname = '/home/sanosh/work_oxford/ApPredict_GPmat/Figure/videos/compareSurface2D';
                    zlabel('Entropy');
                    saveas(gcf,fullfile(fname,num2str(Batch)),'fig');
            end
            plotted=0;
            pause(2.5)
            close
end

