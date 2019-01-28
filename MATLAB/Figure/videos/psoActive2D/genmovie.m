clear k;clear l; clear m;clear n;
fps= 1;
outfile = sprintf('%s','Fig10b');
mov = VideoWriter(outfile,'Motion JPEG AVI');%'fps',fps,'quality',100);
mov.FrameRate=1;
CompressionRatio = 100;
open(mov);
% set(fig1,'NextPlot','replacechildren');
fileIndex=[12,3,17,3,14,5,4,4];
% fileIndex=[1,1,1,1];

b={1:fileIndex(1),1:fileIndex(2),1:fileIndex(3),1:fileIndex(4),...,
    1:fileIndex(5),1:fileIndex(6),1:fileIndex(7),1:fileIndex(8)};
numframes = sum(fileIndex);
k=1;l=1;m=1;n=1;o=1;p=1;q=1;r=1;
for i=1:numframes
    if i<=fileIndex(1)
        BatchName=1;
        ind=b{1,1}(k);
        fig1=openfig(strcat(num2str(BatchName),'Iter','--',num2str(ind),'.fig'));
            axis tight manual

        k=k+1;
    elseif i>fileIndex(1) && i<= sum(fileIndex(1:2))
        BatchName=2;
        ind=b{1,2}(l);
        fig1=openfig(strcat(num2str(BatchName),'Iter','--',num2str(ind),'.fig'));
    axis tight manual
        l=l+1;
    elseif i>sum(fileIndex(1:2)) && i<= sum(fileIndex(1:3))
        BatchName=3;
        ind=b{1,3}(m);
        fig1=openfig(strcat(num2str(BatchName),'Iter','--',num2str(ind),'.fig'));
    axis tight manual
        m=m+1;
    elseif i>sum(fileIndex(1:3)) && i<=sum(fileIndex(1:4))
        BatchName=4;
        ind=b{1,4}(n);
        fig1=openfig(strcat(num2str(BatchName),'Iter','--',num2str(ind),'.fig'));
    axis tight manual
        n=n+1;
        
        
    elseif i>sum(fileIndex(1:4)) && i<=sum(fileIndex(1:5))
        BatchName=5;
        ind=b{1,5}(o);
        fig1=openfig(strcat(num2str(BatchName),'Iter','--',num2str(ind),'.fig'));
    axis tight manual
        o=o+1;
    elseif i>sum(fileIndex(1:5)) && i<=sum(fileIndex(1:6))
        BatchName=6;
        ind=b{1,6}(p);
        fig1=openfig(strcat(num2str(BatchName),'Iter','--',num2str(ind),'.fig'));
    axis tight manual
        p=p+1;
    elseif i>sum(fileIndex(1:6)) && i<=sum(fileIndex(1:7))
        BatchName=7;
        ind=b{1,7}(q);
        fig1=openfig(strcat(num2str(BatchName),'Iter','--',num2str(ind),'.fig'));
    axis tight manual
        q=q+1;
    elseif i>sum(fileIndex(1:7)) && i<=sum(fileIndex(1:end))
        BatchName=8;
        ind=b{1,8}(r);
        fig1=openfig(strcat(num2str(BatchName),'Iter','--',num2str(ind),'.fig'));
    axis tight manual
        r=r+1;
    
    
    
    
    
    end
           ax = gca;
        ax.Units = 'pixels';
        pos = ax.Position
        marg = 35;
        rect = [-marg, -marg, pos(3)+2*marg, pos(4)+2*marg]; 
    
%     hold (ax,'on')

% %         strcat('1','Iter','--',num2str(b),'.fig')
%         fig1=openfig(strcat(num2str(BatchName),'Iter','--',num2str(b),'.fig'));
        pause(1);% put this plot in a movieframe
        % In case plot title and axes area are needed
          set(gcf,'Color',[1 1 1],'nextplot','replacechildren', 'Visible','off')
%           xlim(ax,[0 1]);
%           ylim(ax,[0 1]);
%  drawnow;             
F = getframe(gcf);
% ax.Units = 'normalized';

%         F = getframe(fig1);
        % For clean plot without title and axes
        %F = getframe;
        writeVideo(mov,F);
        %pause(1);
end
% save movie
close(mov);

% scatter(XX(1:18),YY(1:18))