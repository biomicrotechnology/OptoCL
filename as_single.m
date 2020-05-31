function y = as_single(x, sep)
%as_single(x, [sep]) Returns <x> as a single-dimension array, with
%   separator <sep:nan>, for plotting as a single line.

opt_args('sep',nan);

y = [x; repmat(sep, 1, size(x,2))];
y = reshape(y,[],1);

end

