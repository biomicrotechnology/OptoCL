% README
% First run this file, then run the corresponding OptoCL_*.s2s in Spike2
% See also OptoCL_run.m

clear;
fclose('all');


%% Initialize and run OptoCL
%KA487 (OL: 0.11)
r = 0.04;                           % target reference
X0 = [  0.1333    3.2853 ];         % initial estimate
S0 = [  3.0249e-05 -7.9457e-04
       -7.9457e-04  3.0057e-02 ];   % initial estimate covariances
S  = [  1.2917e-09 -5.7918e-08
       -5.7918e-08  3.1897e-06 ];   % process noise
W  = 0.0080;                        % measurement noise variance


%% Run MPC
OptoCL_run(r, X0, S0, S, W);
