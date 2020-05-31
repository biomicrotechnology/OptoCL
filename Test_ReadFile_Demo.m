% First run this file in MATLAB, then run Test_WriteFile_Demo in Spike2
% 
clc; clear;
fclose('all');

% Config
fs = 100;
N = 120*fs;
y_all = nan(N,1);

basepath = 'C:\MPC\';
filename_u = [basepath 'u.bin'];
filename_y = [basepath 'y.bin'];
filename_lock = [basepath 'lock'];

% Create output file
if ~isfolder(basepath), mkdir (basepath); end
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
    pause(0); % sleep 1 ms
end

% Read
tic
pos = 0;
while true
    [y,n] = fread(fid_y, 'double');
    if n == 0
        % check if input is finished (no more lock)
        if ~isfile(filename_lock)
            break;
        end
        
        % wait for more data
        pause(0); % sleep 1 ms
        continue;
    end
    y_all(pos+(1:n)) = y;
    pos = pos+n;
    %fprintf('Read %d values\n', n);

    n = fwrite(fid_u, y, 'double');
    %fprintf('Wrote %d values\n', n);
end
toc

fclose(fid_u);
fclose(fid_y);

%% Plot
clf;
t = (1:length(y_all))'/fs;
plot(t, y_all);