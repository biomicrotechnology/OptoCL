%% Load data
filename = '200601_KA480_KA487_KA486_001_500Hz.mat';
ch = 'HC1_2';
channels = { ch };
load(filename, 'data');


%% Model parameters
fs = data.(ch).fs;
ii = 1:110*fs;
t_ = data.(ch).t(ii);
y_ = data.(ch).y(ii);
%u_ = data.Stim.y(ii);

f = 8;
amps = [16 0 10 5 1 11 8 2 15 19 20 13 9 17 12 18 7 3 14 4 6]./20;
ii_stim = 5*fs + (1:105*fs)';
u_ = zeros(length(y_), 2);
u_(ii_stim, 1) = reshape(repmat(amps,[5*fs 1]), [], 1);
u_(ii_stim, 2) = cos(2*pi*f*(t_(ii_stim) - t_(ii_stim(1))));

%X0 = [ 0.1654    7.7019 ];
X0 = [ 0.2 10 ];
ukf = UKF_setup(X0);S  = [ 1e-6 1e-6 ]; % noise covariances



%% Run UKF
N = length(u_);
n_pred = 125;
n_step = 125;
i0_step = (1:n_step:N-n_pred);
i0_pred = i0_step+n_step;
ni_pred = length(i0_pred);
y_pred = nan(n_pred, ni_pred);
x_ukf = nan(ni_pred, 2);
s_ukf = nan(ni_pred, 2);
tic
%profile on -nohistory
for j = 1:ni_pred
    k = i0_step(j);
    ii_ = k+(0:n_step-1);
    y = y_(ii_,:);
    u = u_(ii_,:);
    
    % Update UKF
    ukf = UKF_update(ukf, y, u, n_step);
    x_ukf(j,:) = ukf.State;
    s_ukf(j,:) = diag(ukf.StateCovariance);
    
    for i = 1:n_pred
        k = i0_pred(j)+i-1;
        y_pred(i,j) = ukf.MeasurementFcn(x_ukf(j,:), u_(k,:));
    end
end
toc
%profile off
%profile viewer

ii_pred = (1:n_pred)' + i0_pred - 1;
t_pred  = t_(ii_pred);


%% Plot simulation and ukf state estimation with prediction
h = 4;
w = 1;

%fig = clf();
fig = figure;
set(fig, 'DefaultLineLineWidth', 1);

ha = [];
ha(1) = subplot(h,w,1);
plot(t_, u_);
xticklabels([]);
ylabel('u');

ha(2) = subplot(h,w,2); hold on;
plot(t_, y_);
ylim(ylim);
plot(as_single(t_pred), as_single(y_pred), 'Color',[0.9290 0.6940 0.1250]);
plot(t_pred(1,:), y_pred(1,:), '>r', 'MarkerSize',3);
xticklabels([]);
ylabel('y [mV]');
legend({'y', 'y_{ukf}'});

ha(3) = subplot(h,w,3); hold on;
plot_errorarea(t_pred(1,:), x_ukf(:,1), s_ukf(:,1));
xticklabels([]);
ylabel('g');

ha(4) = subplot(h,w,4); hold on;
plot_errorarea(t_pred(1,:), x_ukf(:,2), s_ukf(:,2));
ylabel('b');

linkaxes(ha, 'x');