% README
% First run this file, then run the corresponding OptoCL_*.s2s in Spike2
% See also OptoCL_run.m

clear;
fclose('all');


%% Initialize and run OptoCL
%KA486 (OL: 0.53)
r = 0.02;                           % target reference
X0 = [  0.0277    2.4148 ];         % initial estimate
S0 = [  6.5699e-03 -2.8323e-02
       -2.8323e-02  5.5761e-01 ];   % initial estimate covariances
S  = [   2.7755e-05 -3.1238e-06
        -3.1238e-06  2.2216e-05 ];  % process noise
W  = 0.0065;                        % measurement noise variance


%% Run MPC
OptoCL_run(r, X0, S0, S, W);
