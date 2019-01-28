gk=[0.9 .1 0.5 .8; 0.9 .1 0.5 .8 ;...
    0.9 .1 0.5 .8;0.9 .1 0.5 .8];
APD = EvaluateAPD(gk,100);
TestAPD = [734.3490;  734.3490;  734.3490;  734.3490];
assert(all(APD==TestAPD),'Communication failed');
