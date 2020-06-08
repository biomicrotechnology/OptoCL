function ukf = UKF_setup(X0)
% Model definition
% y = g * (1 - exp(-b*a_u)) * cos(phi_u);
% u = [ cos_u a_u  ]
% x = [ g b ]
% x(k+1) = x(k) + N(0, S)
ukf_f = @(x, ~) x;
ukf_h = @(x, u) x(1) * (1 - exp(-x(2)*u(1))) * u(2);

% Initial parameters
%    [ g    b ]
%S  = [ 1e-6 1e-6 ]; % noise covariances
S  = 1e-9 * [ 1 1 ]; % noise covariances
W = 1e-1; % measurement noise variance

% Object definition
ukf = unscentedKalmanFilter(ukf_f, ukf_h, X0);
ukf.MeasurementNoise = diag(W);
ukf.ProcessNoise = diag(S);
ukf.StateCovariance = diag(S);

end
