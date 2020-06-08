%% Load data
fid = fopen('C:\MPC\test.smr');
[y,h] = SONGetADCChannel(fid, 1, 'scale');
ch0 = 1;
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

%%
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