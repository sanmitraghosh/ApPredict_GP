function [cert, lp1, lp2, lp3, s1, s2, s3] = certainty(x, y, xp, HyperParams)
%%%%%% This function returns the certainty metric  %%%%

 hyp1=HyperParams.hyp1;
 hyp2=HyperParams.hyp2;
 hyp3=HyperParams.hyp3;
 [ x_train,y_train ] = labelFinder( x, y);

%%%%%%%%%%%% Create inducing points for using sparse covariances %%%%%%%
dim=size(x,2);
Ind=HyperParams.NumInducingClass;
sparse=nthroot(Ind,dim);
switch dim
   case 4
    [u1,u2,u3,u4] = ndgrid(linspace(0,1,sparse)); 
    u = [u1(:),u2(:),u3(:), u4(:)]; 
    clear u1; clear u2;clear u3;
   case 3
    [u1,u2,u3] = ndgrid(linspace(0,1,sparse)); 
    u = [u1(:),u2(:),u3(:)]; 
    clear u1; clear u2;clear u3;
   case 2
    [u1,u2] = ndgrid(linspace(0,1,sparse)); 
    u = [u1(:),u2(:)]; 
    clear u1; clear u2;
end
    
    
%%%%%%%%%%%% Prepare GP %%%%%%%
meanfunc = @meanConst; 
covfunc = @covSEard;  
covfuncF = {@covFITC, {covfunc},u};
likfunc = @likErf;

nt=length(xp);
if length(x)<HyperParams.sparseMargin
    inffunc = @infEP;
    cov=covfunc;

else
    inffunc = @infFITC_EP; 
    cov=covfuncF;
end
disp(inffunc)
[a1 s1 c d lpNR] = gp(hyp1, inffunc, meanfunc, cov, likfunc, x_train, y_train(:,1),xp, ones(nt, 1));
[a2 s2 c d lpD] = gp(hyp2, inffunc, meanfunc, cov, likfunc, x_train, y_train(:,2),xp, ones(nt, 1));
[a3 s3 c d lpND] = gp(hyp3, inffunc, meanfunc, cov, likfunc, x_train, y_train(:,3),xp, ones(nt, 1));

lp1=lpNR;lp2=lpD;lp3=lpND;
%%% Calculate certainty metric at test locations
for i=1:nt
 [a,b]=max([exp(lp1(i)),exp(lp2(i)),exp(lp3(i))]);
    if b==1 
        cert(i)=exp(lp1(i))-max([exp(lp2(i)),exp(lp3(i))]); 
    elseif b==2  
        cert(i)=exp(lp2(i))-max([exp(lp1(i)),exp(lp3(i))]);
    elseif b==3 
        cert(i)=exp(lp3(i))-max([exp(lp1(i)),exp(lp2(i))]);
    end

end
cert=cert';
end


