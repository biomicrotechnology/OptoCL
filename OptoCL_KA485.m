% README
% First run this file, then run the corresponding OptoCL_*.s2s in Spike2
% See also OptoCL_run.m

clear;
fclose('all');


%% Initialize and run OptoCL
%KA485 (OL: 0.0269)
load('KA485_200603_000_21000_105000.mat', 'X0','S0','V','W');
r = 0.11;	% target reference
x = X0;
S = S0;


%% Run MPC
[x, S] = OptoCL_run(r, x, S, V, W);


%% Optimal u_a
u_a = -log(max(0, 1 - r/x(1))) / x(2);
disp(u_a)


%% Scale V
Vs = diag([1 .1]);
V = Vs*V*Vs;
