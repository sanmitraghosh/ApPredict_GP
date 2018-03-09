function [outparam] = learnGPhyp(x, y, gpoptions)
%%%%%% This function is used to estimate GP hyperparameters by MLE %%%%
    
LM=gpoptions.LearningMode;
if strcmp(LM,'classifier')
     classHyper.NumInducingClass=gpoptions.NumInducingClass;
     classHyper.sparseMargin=gpoptions.sparseMargin;

%%%%%%%%%%%%% Find class labels of the random sampled data %%%%%%%%%%%%%%%%%%%
    [ x_train,y_train ] = labelFinder( x, y);
%%%%%%%%%%%%% Now Learn the Classifier hyperparameters %%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% Create inducing points for using sparse covariances %%%%%%%
    dim=size(x,2);
    Ind=classHyper.NumInducingClass
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
    meanfunc = @meanConst; 
    covfunc = @covSEard; hyp.cov = log(ones(dim+1,1));
    covfuncF = {@covFITC, {covfunc},u};%for sparse GP
    likfunc = @likErf;
    hyp1.cov=hyp.cov;hyp2.cov=hyp.cov;hyp3.cov=hyp.cov;
    hyp1.mean=0;hyp2.mean=0;hyp3.mean=0;
    if length(x)<gpoptions.sparseMargin
        inffunc = @infEP;
        cov=covfunc;
    else
        disp('SPARSE Classifier')
        hyp1.xu=u;hyp2.xu=u;hyp3.xu=u;
        inffunc = @infFITC_EP; 
        cov=covfuncF;
    end

    classHyper.hyp1 = minimize(hyp1, @gp, -300, inffunc, meanfunc, cov, likfunc, x_train, y_train(:,1));
    classHyper.hyp2 = minimize(hyp2, @gp, -300, inffunc, meanfunc, cov, likfunc, x_train, y_train(:,2));
    classHyper.hyp3 = minimize(hyp3, @gp, -300, inffunc, meanfunc, cov, likfunc, x_train, y_train(:,3));
    outparam=classHyper;
elseif strcmp(LM,'surface')
    surfHyper.NumInducingSurf=gpoptions.NumInducingSurf;
    surfHyper.sparseMarginSurf=gpoptions.sparseMarginSurf;
    dim=size(x,2);
    Ind=surfHyper.NumInducingSurf;
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
    hypSurf.xu=u;
    hypSurf.cov=gpoptions.covarianceKernelsParams;
    hypSurf.lik=gpoptions.likelihoodParams;
    hypSurf.mean = 0;

    if length(x)<surfHyper.sparseMarginSurf
        inffunc = @infExact;
        surfcovfunc=gpoptions.covarianceKernels;
        surfHyper.covfunction=surfcovfunc;

    else
        disp('SPARSE Surface')
        inffunc = @infFITC; 
        surfcovfunc=gpoptions.covarianceKernels;
        surfHyper.covfunction=surfcovfunc;
        surfcovfunc = {@covFITC,{surfcovfunc},u};%for sparse GP

    end

     surfHyper.cov=hypSurf.cov;
     surfHyper.lik=hypSurf.lik;
    %%%%%%%%%%%%% Now Learn the Surface hyperparameters %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% Find class labels of the random sampled data if non-AP points are passed %%%%%%%%%%%%%%%%%%%
    [ ~,y_train ] = labelFinder( x, y);
    Cord=find(y_train(:,2)==1);
    sx_train=x(Cord,:);
    sy_train=y(Cord);

    surflikfunc = @likGauss; 
    surfmeanfunc = @meanConst; 
    surfHyper.hyp = minimize(hypSurf, @gp, -300, inffunc, surfmeanfunc, surfcovfunc, surflikfunc, sx_train, sy_train);
    outparam=surfHyper;

end

end

