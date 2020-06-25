function ukf = UKF_setup(X0, S0, S, W)
% Model definition
% y = g * (1 - exp(-b*a_u)) * cos(phi_u);
% u = [ cos_u a_u  ]
% x = [ g b ]
% x(k+1) = x(k) + N(0, S)
ukf_f = @(x, ~) x;
ukf_h = @(x, u) x(1) * (1 - exp(-x(2)*u(1))) * u(2);

% Object definition
ukf = unscentedKalmanFilter(ukf_f, ukf_h, X0);
ukf.MeasurementNoise = diag(W);
ukf.ProcessNoise = S;
ukf.StateCovariance = S0;

end
