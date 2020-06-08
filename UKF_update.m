function ukf = UKF_update(ukf, y, u, n)
% Update estimation

for k = 1:n
    correct(ukf, y(k,:), u);
    predict(ukf, u);
end

end
