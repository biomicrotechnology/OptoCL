function opt_args(argname1, default1, varargin)
%opt_args(argname1, default1, [argname2, default2, ...])
%   Helper function to define optional arguments in functions
%   If <argnameN> does not exists or is empty, assign value <defaultN> to
%   it in the caller workspace.

vars = evalin('caller','who');

argnames = [ {argname1} varargin(1:2:end) ];
defaults = [ {default1} varargin(2:2:end) ];

for i = 1:length(argnames)
    if ~ismember(argnames{i}, vars) || isempty(evalin('caller',argnames{i}))
        assignin('caller', argnames{i}, defaults{i});
    end
end

end
