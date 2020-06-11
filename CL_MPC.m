% README
% First run this file, then run CL_MPC.s2s in Spike2
% See also CL_MPC.s2s

clear;
fclose('all');


%% Config
% General
fs = 200;   % sampling rate for UKF/MPC
r = 0.1;    % target reference
f = 8;      % Hz
dt = 1/fs;

% Path
basepath = 'C:\MPC\';
filename_u = [basepath 'u.bin'];
filename_y = [basepath 'y.bin'];
filename_lock = [basepath 'lock'];


%% Initialize UKF
%    [ g         b      ]
X0 = [ 0.1575    3.0171 ];  % initial estimate
S  = 1e-8 * [ 1 1 ];        % noise covariances
W  = 1e-2;                  % measurement noise variance
ukf = UKF_setup(X0, S, W);

% Create output file
fid_u = fopen(filename_u, 'w');
fprintf('Opened %s for writing\n', filename_u);

% Write initial output
a = MPC_update(X0, r);
fwrite(fid_u, a, 'double');

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


%% Read
tic
N = 300*fs; % expected number of loops (buffer size)
D = 2;      % number of states
y_meas = nan(1,N);      % measured data (input)
a_mpc  = nan(1,N);      % control parameter
x_ukf  = nan(D,N);      % estimated states
S_ukf  = nan(D,D,N);    % estimated covariances
times  = nan(2,N);      % loop times
a_last = a;             % last used control
a_calc = a;             % latest calculated control
i = 1;          % loop counter
c = 1;          % cycle counter
ncycle = fs/f;  % number of samples per cycle
while true
    % Wait for and read output
    [y,n] = fread(fid_y, 'double');
    if n == 0
        % check if input is finished (lockfile deleted)
        if ~isfile(filename_lock)
            break;
        end

        % wait for more data
        pause(1e-6); % sleep 1 µs
        continue;
    end
    ii = i + (0:n-1);
    times(1,ii) = now;
    %fprintf('Read %d values\n', n);

    % Create control input vector
    a_ = a_last*ones(n,1);
    a_(ceil(ii/ncycle) > c) = a_calc;
    phi_ = 2*pi*f*dt*(ii-1)';

    u = [a_ cos(phi_)];

    % Update online state estimate
    try
        % Obtain UKF estimate
        UKF_update(ukf, y, u, n);
    catch ME
        warning(getReport(ME));
    end
    
    x = ukf.State;
    S = ukf.StateCovariance;

    % Calculate optimal control
    try
        % Write control parameters
        a_calc = MPC_update(x, r);
        n_ = fwrite(fid_u, a_calc, 'double');
        times(2,ii) = now;
        %fprintf('Wrote %d values\n', n_);
    catch ME
        warning(getReport(ME));
    end

    % Save state for next cycle
    y_meas(ii) = y;
    x_ukf(:,ii) = repmat(x(:), 1,n);
    S_ukf(:,:,ii) = repmat(S, 1,1,n);
    a_mpc(ii) = a_;
    a_last = a_(end);
    
    % Next loop
    i = i + n;
    c = ceil(i/ncycle);
    
    %toc
end
toc


%% Save data
% Trim data buffer to last cycle
N = i-1;
y_meas = y_meas(1:N);
x_ukf = x_ukf(:,1:N);
S_ukf = S_ukf(:,:,1:N);
a_mpc = a_mpc(:,1:N);
times = times(:,1:N);

% Save workspace
matfile = sprintf('MPC_%s.mat', datestr(now, 30));
save(matfile);
fprintf('Saved %s\n', matfile);


%% Plot
t = dt*(1:N);
y_pred = nan(1,N);
a_calc = nan(1,N);
y_amp = nan(1,N);
for k = 1:N
    y_pred(k) = ukf.MeasurementFcn(x_ukf(:,k), [a_mpc(k); cos(2*pi*f*dt*(k-1))]);
    y_amp(k) = ukf.MeasurementFcn(x_ukf(:,k), [a_mpc(k); 1]);
    
    a_calc(k) = abs(-log(1 - r/x_ukf(1,k)) / x_ukf(2,k));
end

figure;
h = 5; w = 1;
ha = gobjects(h,w);
ha(1) = subplot(h,w,1);
plot(t, [a_mpc; a_calc]);
ylabel('u');

ha(2) = subplot(h,w,2);
plot(t, [y_meas; y_pred]);
ylabel('y');

ha(3) = subplot(h,w,3); hold on;
plot(t, y_amp);
plot(xlim, [r r], '--');
ylabel('y_amp, r');

ha(4) = subplot(h,w,4);
plot(t, x_ukf(1,:));
ylabel('g');

ha(5) = subplot(h,w,5);
plot(t, x_ukf(2,:));
ylabel('b');

linkaxes(ha, 'x');


%% Functions
function a = MPC_update(x, r)
    g = x(1);
    b = x(2);
    
    % Calculate desired control
    %r = g*(1 - exp(-b*a));
    a = -log(max(0, 1 - r/g)) / b;
    a = min(max(0.0, a), 1.0);
end
