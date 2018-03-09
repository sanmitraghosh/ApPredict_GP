function [y_star_class, R_star_AP, y_star_AP] = boundaryDetector(R, y, R_star, HyperParams, y_true)
%%%%%% This function is used multi-class classification OVR %%%%

[ R_train,y_train ] = labelFinder( R, y);
HyperParams.hyp=HyperParams.hyp1;
[s1, lpNR ] = classifierGP( R_train, y_train(:,1), R_star, HyperParams);
HyperParams.hyp=HyperParams.hyp2;
[s2, lpD ] = classifierGP( R_train, y_train(:,2), R_star, HyperParams);
HyperParams.hyp=HyperParams.hyp3;
[s3, lpND ] = classifierGP( R_train, y_train(:,3), R_star, HyperParams);


%%%%%% Perform OVR classification
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

