function ukf = UKF_update(ukf, y, u, n)
% Update estimation

for k = 1:n
    predict(ukf, u(k,:));
    correct(ukf, y(k,:), u(k,:));
end

end
