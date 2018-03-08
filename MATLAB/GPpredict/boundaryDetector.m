function [y_star_class, R_star_AP, y_star_AP] = boundaryDetector(R, y, R_star, HyperParams, y_true)
 
disp('Using Correct multidomain')
[ R_train,y_train ] = labelFinder( R, y);
HyperParams.hyp=HyperParams.hyp1;
[s1, lpNR ] = classifierGP( R_train, y_train(:,1), R_star, HyperParams);
HyperParams.hyp=HyperParams.hyp2;
[s2, lpD ] = classifierGP( R_train, y_train(:,2), R_star, HyperParams);
HyperParams.hyp=HyperParams.hyp3;
[s3, lpND ] = classifierGP( R_train, y_train(:,3), R_star, HyperParams);

lp1=lpNR;lp2=lpD;lp3=lpND;
    
% for i=1:length(R_star)
%  [a,b]=max([exp(lp1(i)),exp(lp2(i)),exp(lp3(i))]);
% %      [c,d]=max([s1(i),s2(i),s3(i)]);
%     if b==1 
%         certainty(i)=exp(lp1(i))-max([exp(lp2(i)),exp(lp3(i))]); 
%     elseif b==2  
%         certainty(i)=exp(lp2(i))-max([exp(lp1(i)),exp(lp3(i))]);
%     elseif b==3 
%         certainty(i)=exp(lp3(i))-max([exp(lp1(i)),exp(lp2(i))]);
%     end
% 
% end
% certainty=certainty';


%%%%%% Find seperate domains
j=1;
k=1;
l=1;
for i=1:length(R_star)
 [a,b]=max([exp(lpNR(i)),exp(lpD(i)),exp(lpND(i))]);
    if b==1 
        y_star_class(i)=1;        
    elseif b==2 
        if HyperParams.UQ==1 || nargin < 5
            R_star_AP(k,:)=R_star(i,:);
            k=k+1;
        else    
            if y_true(i)~=0 && y_true(i)~=1000 
                R_star_AP(k,:)=R_star(i,:);
                y_star_AP(k)=y_true(i);
                k=k+1;
            end
        end
        y_star_class(i)=0;
    elseif b==3 
        y_star_class(i)=-1;
    end
end


end

