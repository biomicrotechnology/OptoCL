clc; clear; fclose('all');

basepath = 'C:\MPC\';
filename_u = [basepath 'u.bin'];
filename_y = [basepath 'y.bin'];
filename_lock = [basepath 'lock'];

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
pos = 0;
N = 20*5e3;
y_all = nan(N,1);
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
    y_all(pos+(1:n)) = y;
    pos = pos+n;
    %fprintf('Read %d values\n', n);

    n = fwrite(fid_u, y, 'double');
    %fprintf('Wrote %d values\n', n);
end
toc

%% Plot
fs = 5e3;
t = (1:length(y_all))'/fs;
clf;
plot(t, y_all);