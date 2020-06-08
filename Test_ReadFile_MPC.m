clc; clear;
fclose('all');

%% Config
% General
fs = 200;   % sampling rate for UKF/MPC
r = 0.2;    % target reference
f = 8;      % Hz

% Path
basepath = 'C:\MPC\';
filename_u = [basepath 'u.bin'];
filename_y = [basepath 'y.bin'];
filename_lock = [basepath 'lock'];


%% Initialize UKF
X0 = [ 0.2 7 ];
ukf = UKF_setup(X0);

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
i = 1;
N = 300*fs; % expected number of cycles (buffer size)
D = 2;      % number of states
y_meas = nan(1,N);      % measured data (input)
a_mpc  = nan(1,N);      % control parameter
x_ukf  = nan(D,N);      % estimated states
S_ukf  = nan(D,D,N);    % estimated covariances
times  = nan(2,N);      % loop times
dt = 1/fs;
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
    ii = i-1 + (1:n);
    times(1,ii) = now;
    %fprintf('Read %d values\n', n);

    try
        % Create control input vector
        u = [a*ones(n,1) cos(2*pi*f*dt*(ii-1))'];

        % Obtain UKF estimate
        UKF_update(ukf, y, u, n);
        x = ukf.State;
        S = ukf.StateCovariance;

        % Write control parameters
        a_ = MPC_update(x, r);
        n_ = fwrite(fid_u, a_, 'double');
        times(2,ii) = now;
        %fprintf('Wrote %d values\n', n_);
    catch
%         switch ME.identifier
%             case 'MATLAB:UndefinedFunction'
%         end
        warning(ME.identifier);
        warning(getReport(ME));
    end

    try
        % Save state for next cycle
        y_meas(ii) = y;
        x_ukf(:,ii) = repmat(x(:), 1,n);
        S_ukf(:,:,ii) = repmat(S, 1,1,n);
        a_mpc(ii) = a;
    catch ME
        warning(ME.identifier);
        warning(getReport(ME));
    end
    
    i = i + n;
    a = a_;

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
clf;
t = dt*(1:N);
y_pred = nan(1,N);
u = [a_mpc; cos(2*pi*f*dt*(0:N-1))];
for k = 1:N
    y_pred(k) = ukf.MeasurementFcn(x_ukf(:,k), u(:,k));
end
subplot(211);
plot(t, u);
subplot(212);
plot(t, [y_meas; y_pred]);


%% Functions
function a = MPC_update(x, r)
    g = x(1);
    b = x(2);
    
%     % Calculate desired control
    %r = g*(1 - exp(-b*a));
    a = -log(1 - r/g) / b;
    a = min(max(0.0, abs(a)), 1.0);
end
