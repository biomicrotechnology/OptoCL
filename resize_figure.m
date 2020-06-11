function resize_figure(dims, fig)
%resize_figure(dims, [fig]) Resize <fig> to <dims:[w h]> even when docked.

% Check optional arguments
opt_args('fig', []);
if isempty(fig), fig = gcf(); end

if strcmp(fig.WindowStyle,'docked')
    n_retries = 10;
    for i = 1:n_retries %retries
        try
            % See: https://blogs.mathworks.com/community/2007/05/18/do-you-dock-figure-windows-what-does-your-desktop-look-like/#comment-626
            desktop=com.mathworks.mde.desk.MLDesktop.getInstance;
            container=desktop.getGroupContainer('Figures').getTopLevelAncestor;
            container.setMaximized(false);
            container.setSize(dims(1),dims(2)+135); %FIXME: fixed toolbar height
            break;
        catch ME
            pause(0.1);
            if i == n_retries
                warning('Failed to resize figure window');
                warning(ME.getReport());
            end
        end
    end
else
    fig.Position(3:4) = dims;
end

%Wait until redrawn?
drawnow();
pause(0.02);  % Magic, reduces rendering errors

end
