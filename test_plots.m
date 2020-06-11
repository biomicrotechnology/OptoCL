%% Load data
fid = fopen('C:\MPC\test.smr');
[y,h] = SONGetADCChannel(fid, 9, 'scale');
ch0 = 0;
u = SONGetRealMarkerChannel(fid, ch0+1);
r = SONGetRealMarkerChannel(fid, ch0+2);
w = SONGetRealMarkerChannel(fid, ch0+3);
s = SONGetRealMarkerChannel(fid, ch0+4);
l = SONGetRealMarkerChannel(fid, ch0+5);
fclose(fid);

ts = h.sampleinterval*1e-6;
fs = 1/ts;
ny = length(y);
ty = h.start + ts*(0:ny-1);

t0 = l.timings(1) + ts;
t_ = t + t0;

%% Plot timings
fig = figure;
h_ = 6; w_ = 1;
ha = gobjects(h_,w_);

ha(1) = subplot(h_,w_,1); hold on;
plot(t_, [y_meas; y_pred], '.-');
plot(ty, y, 'k');
ylabel('y');

markers_ = {u, r, w, s, l};
labels_ = {'u', 'r', 'w', 's', 'l'};
for p = 1:length(markers_)
    m_ = markers_{p};
    ha(1+p) = subplot(h_,w_,1+p);
    plot(m_.timings, m_.real, '.-');
    ylabel(labels_{p});
end

linkaxes(ha, 'x');


%% Plot optimal control fit
ukf_h = @ukf.MeasurementFcn;
mpc_u = @MPC_update;
g_ = [.1 -.1];
b = 3;

fig = clf;
h = 2;
w = 3;

a_ = -.1:.05:1.1;
r_ = -2*abs(g):.01:2*abs(g);

for p = 1:h
    g = g_(p);
    x_ = [g b];
    subplot(h,w,(p-1)*w+1);
    plot(a_, arrayfun(@(a) ukf_h(x_,[a 1]), a_));
    ylim(abs(g)*[-1 1]);
    xlabel('a');
    ylabel('a_y');
    grid on;

    subplot(h,w,(p-1)*w+2);
    plot(r_, arrayfun(@(r) mpc_u(x_,r), r_));
    xlabel('r');
    ylabel('a');
    grid on;
    title(sprintf('g: %f, b: %f', g, b));

    subplot(h,w,(p-1)*w+3);
    plot(r_, arrayfun(@(r) ukf_h(x_,[mpc_u(x_,r) 1]), r_));
    ylim(abs(g)*[-1 1]);
    ylabel('a_y');
    xlabel('r');
    grid on;
end


%% Functions
function a = MPC_update(x, r)
    g = x(1);
    b = x(2);
    
    % Calculate desired control
    %r = g*(1 - exp(-b*a));
    a = -log(max(0, 1 - r/g)) / b;
    a = min(max(0.0, a), 1.0);
end
