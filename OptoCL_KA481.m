% README
% First run this file, then run the corresponding OptoCL_*.s2s in Spike2
% See also OptoCL_run.m

clear;
fclose('all');


%% Initialize and run OptoCL
%KA481 (OL: 0.12)
%r = 0.1;                           % target reference
r = 0.16;                           % target reference
X0 = [  0.1787   12.5395 ];         % initial estimate
% S0 = [  3.5693e-05 -5.6263e+03
%        -5.6263e+03  1.2648e+12 ];   % initial estimate covariances
% S  = [  5.7902e-10 -1.1789e-01
%        -1.1789e-01  2.0140e+08 ];   % process noise
S0 = [  2.0808e-05 -3.2438e-04
       -3.2438e-04  1.2366e-01 ];   % initial estimate covariances
S  = [  1.6696e-10 -3.7457e-08
       -3.7457e-08  4.6408e-05 ];   % process noise
W  = 0.0338;                        % measurement noise variance


%% Run MPC
OptoCL_run(r, X0, S0, S, W);
