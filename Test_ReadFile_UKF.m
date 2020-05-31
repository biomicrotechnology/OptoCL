clc; clear;
fclose('all');

% Config
basepath = 'C:\MPC\';
filename_u = [basepath 'u.bin'];
filename_y = [basepath 'y.bin'];
filename_lock = [basepath 'lock'];

% Initialize UKF
fs = 5e3;
skip = 10;
dt = skip/fs;
ukf = UKF_setup();

% Create output file
fid_u = fopen(filename_u, 'w');
fprintf('Opened %s for writing\n', filename_y);

% Wait for input file
if isfile(filename_y), delete(filename_y); end
fprintf('Waiting for %s...\n', filename_y);
while true
    fid_y = fopen(filename_y, 'r');
    if fid_y ~= -1
        fprintf('Opened %s for reading\n', filename_y);
        break;
    end
    pause(1e-3); % sleep 1 ms
end

% Read
tic
i = 1;
N = 200;
n_ = 25;
y_meas = nan(N*n_,1);
X_ukf = cell(N,1);
S_ukf = cell(N,1);
while true
    [y,n] = fread(fid_y, 'double');
    if n == 0
        % check if input is finished (no more lock)
        if ~isfile(filename_lock)
            break;
        end
        
        % wait for more data
        pause(1e-6); % sleep 1 ms
        continue;
    end
    
    y_ = y(1:skip:n) - 1;
    %n_ = length(y_);
    u_ = y_;
    UKF_update(ukf, y_, u_, dt, n_);
    X_ukf{i} = ukf.State;
    S_ukf{i} = ukf.StateCovariance;
    y_meas((i-1)*n_+(1:n_)) = y_;
    i = i + 1;
    %fprintf('Read %d values\n', n);

    n = fwrite(fid_u, u_, 'double');
    %fprintf('Wrote %d values\n', n);
    %toc
end
toc

% %% Plot
% clf;
% t = dt*(1:N*n_);
% plot(t, y_meas);


%% Calculate predictions
N = length(X_ukf);
D = 5;
X_pred = nan(N*n_,D);
s_pred = nan(N*n_,D);
for i = 1:(N-1)
    i0 = i*n_;
    ukf.State = X_ukf{i};
    ukf.StateCovariance = S_ukf{i};
    for k = 1:n_
        predict(ukf, u_(k), dt);
        X_pred(i0+k,:) = ukf.State;
        s_pred(i0+k,:) = diag(ukf.StateCovariance);
    end
end

t = dt*(1:N*n_);
u_meas = zeros(N*n_,1);


%% Plot estimate and states
clf;
hold on;
t = dt*(1:N*n_);
y_pred = X_pred(:,1);
plot(t, [y_meas y_pred]);
ii = 1+n_*(0:N-1);
plot(t(ii), y_pred(ii), 'k.');


%% Plot simulation and ukf state estimation with prediction
h = 6;
w = 1;

fig = figure();
set(fig, 'DefaultLineLineWidth', 2);

ha = [];
ha(1) = subplot(h,w,1);
plot(t, u_meas);
xticklabels([]);
ylabel('u [V]');
legend({'u'});

ha(2) = subplot(h,w,2); hold on;
ii = 1+n_*(0:N-1);
plot(t, y_meas);
plot_errorarea(t, X_pred(:,1), s_pred(:,1));
plot(t(ii), y_pred(ii), 'k.');
ylim(ylim);
xticklabels([]);
ylabel('y [mV]');
legend({'y', 'y_{ukf}'});

ha(3) = subplot(h,w,3); hold on;
set(gca, 'ColorOrderIndex',2)
plot_errorarea(t, X_pred(:,2), s_pred(:,2));
xticklabels([]);
ylabel('x_{ukf} [mV]');

ha(4) = subplot(h,w,4); hold on;
set(gca, 'ColorOrderIndex',2)
plot_errorarea(t, X_pred(:,3)/(2*pi), s_pred(:,3)/(2*pi));
ylabel('^{w_{ukf}}/_{2\pi} [Hz]');
xticklabels([]);

ha(5) = subplot(h,w,5); hold on;
set(gca, 'ColorOrderIndex',2)
plot_errorarea(t, X_pred(:,4), s_pred(:,4));
xticklabels([]);
ylabel('k1_{ukf} [mV/V]');

ha(6) = subplot(h,w,6); hold on;
set(gca, 'ColorOrderIndex',2)
plot_errorarea(t, X_pred(:,5), s_pred(:,5));
ylabel('k2_{ukf} [mV/V]');
xlabel('t [s]');

%linkaxes(ha(2:3), 'y');
linkaxes(ha, 'x');

%suptitle('Online Unscented Kalman Filter (UKF) esimation');

