function save_figure(fig, name, formats, dims, fontsizes, dpi)
%   save_figure(fig, name, [formats], [dims], [fontsizes], [dpi])
%       Saves <fig> to 'Figures/<name>.<format>, for <format> in <formats>
%       (default: {'png'}), with optional <dims> (default: 1920x1080 @150 dpi).

% Check optional argument formats
opt_args('formats',{'png'}, 'dims',[1920 1080], 'fontsizes',false, 'dpi',150);

% Set default size
scaling = get(0,'ScreenPixelsPerInch')/150;  % saveas default: 150 dpi
resize_figure(scaling*dims);

% Change font size
if fontsizes
    for a = findobj(gcf,'Type','Text'); set(a,'FontSize',fontsizes(1)); end
    for a = findobj(gcf,'Type','Axes'); set(a,'FontSize',fontsizes(2)); end 
    for a = findobj(gcf,'Type','Legend'); set([a.ItemText],'FontSize',fontsizes(3)); end
end

% Check 'nosave' flag in base workspace
if ismember('nosave',evalin('base','who')), warning('"nosave"'); return; end

% Save
folder = 'Figures/';
for i = 1:length(formats)
    format = formats{i};
    options = {};
    switch(format)
        case 'epsc',    ext = 'eps';    options = {'-painters'};
        otherwise,      ext = format;
    end
    %exts = getfield(imformats(format), 'ext');
    path = [fullfile(folder, name) '.' ext];
    %saveas(fig, path, format); % default: 150 dpi
    print(fig, path, "-r"+dpi, "-d"+format, options{:});
end

end