%% Config
n_pred = 100;
n_step = 50;


%% Load data
filenames = {   'KA395_170621_001_500Hz.mat' };
channels = {'Stim', 'HC1' };
l=1;
load(filenames{l}, 'data');
nchannels = length(channels);

fs = data.HC1.fs;
ii = (1180*fs):(1340*fs);
t_ = data.HC1.t(ii);
y_ = data.HC1.y(ii);
u_ = data.Stim.y(ii);

UKF_Setup


%% Run UKF
N = length(u_);
i0_pred = (1:n_step:N-n_pred);
ni_pred = length(i0_pred);
y_pred = nan(n_pred, ni_pred);
%tic
%profile on -nohistory
for j = 1:ni_pred
    k = i0_pred(j);
    ii_ = k+(0:n_step-1);
    y = y_(ii_);
    u = u_(ii_);
    
    % Update UKF
    UKF_Update;
end
%toc
%profile off
%profile viewer

ii_pred = (1:n_pred)' + i0_pred;
t_pred  = t_(ii_pred);


%% Plot simulation and ukf state estimation with prediction
h = 2;
w = 1;

fig = figure();
set(fig, 'DefaultLineLineWidth', 2);

ha = [];
ha(1) = subplot(h,w,1);
plot(t_, u_);
xticklabels([]);
ylabel('u [V]');
legend({'u'});

ha(2) = subplot(h,w,2); hold on;
plot(t_, y_);
%plot_errorarea(t_, X_ukf(:,1), s_ukf(:,1));
ylim(ylim);
plot(as_single(t_pred), as_single(y_pred), 'LineStyle','--', 'Color',[0.9290 0.6940 0.1250]);
plot(t_pred(1,:), y_pred(1,:,1), '>r', 'MarkerSize',3);
xticklabels([]);
ylabel('y [mV]');
legend({'y', 'y_{ukf}'});

linkaxes(ha, 'x');