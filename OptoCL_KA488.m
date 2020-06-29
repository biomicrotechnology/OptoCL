% README
% First run this file, then run the corresponding OptoCL_*.s2s in Spike2
% See also OptoCL_run.m

clear;
fclose('all');


%% Initialize and run OptoCL
%KA488 (OL: 0.8578)
load('KA488_200603_000_21000_105000.mat', 'X0','S0','V','W');
r = -0.1;	% target reference
x = X0;
S = S0;


%% Scale V
vs = diag([1 0.1]);
V = vs*V*vs;


%% Optimal u_a
u_a = -log(max(0, 1 - r/x(1))) / x(2);
disp(u_a)


%% Run MPC
[x, S] = OptoCL_run(r, x, S, V, W);
