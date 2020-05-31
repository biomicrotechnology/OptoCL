function plot_errorarea(x, y, neg, pos, step, varargin)
%plot_errorarea(x, y, neg, [pos], [step], ...) Plot line and shaded area.
%       Plot line given by <x,y> and shaded area given by <neg> and <pos>
%       every <step> samples and variable arguments passed to plot.

% Make vectors upright
if size(x,1) == 1, x = x'; end
if size(y,1) == 1, y = y'; end
if size(neg,1) == 1, neg = neg'; end

% Indices for x (may be Nx1 or NxD)
D = size(y, 2);
if size(x, 2) == 1
    ix = ones(1, D);
else
    ix = 1:D;
end

% Optional arguments
opt_args('pos',[], 'step',1);
if isempty(pos)
    pos = y + abs(neg);
    neg = y - abs(neg);
elseif size(pos,1) == 1
    pos = pos';
end

% Plot shaded areas
hold on;
c = get(gca, 'ColorOrder');
o = get(gca, 'ColorOrderIndex');
for i = 1:D 
    x_ = x(1:step:end, ix(i));
    n_ = neg(1:step:end, i);
    p_ = pos(1:step:end, i);
    
    o_ = get(gca, 'ColorOrderIndex');
    fill([x_; flip(x_)], [n_; flip(p_)], c(o_,:), 'LineStyle','none', 'FaceAlpha',.5, 'HandleVisibility','off');
end

% Plot data
set(gca, 'ColorOrderIndex', o);
p = plot(x, y, varargin{:});
end
