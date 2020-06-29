% README
% First run this file, then run the corresponding OptoCL_*.s2s in Spike2
% See also OptoCL_run.m

clear;
fclose('all');


%% Initialize and run OptoCL
%KA487 (OL: 0.1007)
load('KA487_200604_000_21000_105000.mat', 'X0','S0','V','W');
r = 0.04;	% target reference
x = X0;
S = S0;


%% Optimal u_a
u_a = -log(max(0, 1 - r/x(1))) / x(2);
disp(u_a)


%% Scale V
% vs = diag([1 0.1]);
vs = diag([10 1]);
V = vs*V*vs;


%% Run MPC
[x, S] = OptoCL_run(r, x, S, V, W);

