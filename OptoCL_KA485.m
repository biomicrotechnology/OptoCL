% README
% First run this file, then run the corresponding OptoCL_*.s2s in Spike2
% See also OptoCL_run.m

clear;
fclose('all');


%% Initialize and run OptoCL
%KA485 (OL: 0.043)
r = 0.11;                           % target reference
%X0 = [  0.2386   14.3538 ];         % initial estimate
X0 = [  0.2759   25.7603 ];
S0 = [  2.0808e-05 -3.2438e-04
       -3.2438e-04  1.2366e-01 ];   % initial estimate covariances
S  = [  1.6696e-10 -3.7457e-08
       -3.7457e-08  4.6408e-05 ];   % process noise
W  = 0.0258;                        % measurement noise variance


%% Run MPC
OptoCL_run(r, X0, S0, S, W);
