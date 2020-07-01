% README
% First run this file, then run the corresponding OptoCL_*.s2s in Spike2
% See also OptoCL_run.m

clear;
fclose('all');


%% Initialize and run OptoCL
%KA480 (OL: 0.6154)
load('KA480_200604_000_21000_105000.mat', 'X0','S0','V','W');
r = -0.12;	% target reference
x = X0;
S = S0;


%% Scale b (due to different LED)
% P_{LED1}(u_a) ~ (27 mW) * (2 Vpp / 4 Vpp) * u_a
% P_{LED2}(u_a') ~ (11 mW) * (4 Vpp / 4 Vpp) * u_a'
% P_{LED2}(u_a') = P_{LED1}(u_a)
% u_a' = (27/11 mW/mW) * (2/4 Vpp/Vpp) * u_a
% b'/b = u_a/u_a'
x(2) = (11/27)*(4/2)*x(2);


%% Scale V
vs = diag([1 0.01]);
V = vs*V*vs;


%% Optimal u_a
u_a = -log(max(0, 1 - r/x(1))) / x(2);
disp(u_a)


%% Run MPC
[x, S] = OptoCL_run(r, x, S, V, W);
