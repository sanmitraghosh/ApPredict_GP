function [PredSurface, Entropy, PredVar]= surfaceGP(x, y, xstar, HyperParams )
%%%%%%%%%%%% This function carries out GP regression and is the surface GP %%%%%%%

dim=size(x,2);n=length(x);

%%%%%%%%%%%%%%%%%%%% Hyperparameters %%%%%%%%%%%%%%%%%%%
covfunc =HyperParams.covfunction;
hyp2.cov =HyperParams.cov;
hyp2.lik = HyperParams.lik;
hyp2.mean = 0;
likfunc = @likGauss; 
meanfunc = @meanConst; 

%%%%%%%%%%%% Prepare inducing points %%%%%%%

Ind=HyperParams.NumInducingSurf;
sparse=nthroot(Ind,dim);
if dim==4
    [u1,u2,u3,u4] = ndgrid(linspace(0,1,sparse)); 
    u = [u1(:),u2(:),u3(:), u4(:)]; 
    clear u1; clear u2;clear u3;
elseif dim==3
    [u1,u2,u3] = ndgrid(linspace(0,1,sparse)); 
    u = [u1(:),u2(:),u3(:)]; 
    clear u1; clear u2;clear u3;
    else
    [u1,u2] = ndgrid(linspace(0,1,sparse)); 
    u = [u1(:),u2(:)]; 
    clear u1; clear u2;
end
nu = size(u,1);
hyp2.xu=u;
covfuncF = {@covFITC, {covfunc},u};
%%%%%%%%%%%% Carry out GP regression %%%%%%%

if n<HyperParams.sparseMarginSurf
    disp('FULL')
    if HyperParams.minimize==1
        hyp2 = minimize(hyp2, @gp, -500, @infExact, meanfunc, covfunc, likfunc, x, y);
    end
    [PredSurface,PredVar] = gp(HyperParams.hyp, @infExact, meanfunc, covfunc, likfunc, x, y, xstar);
else
    disp('SPARSE')
    if HyperParams.minimize==1
        hyp2 = minimize(hyp2, @gp, -500, @infFITC, meanfunc, covfuncF, likfunc, x, y);
    end
    [PredSurface,PredVar] = gp(HyperParams.hyp, @infFITC, meanfunc, covfuncF, likfunc, x, y, xstar);
end
%%%%%%%%%%%% Calculate entropy %%%%%%%

    Entropy=0.5*log(PredVar) + 0.5*(log(2*pi) +1);
end




