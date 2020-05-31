function ukf = UKF_setup()
% Initial parameters
X0 = [ 0 .1 2*pi*8 -1e1 1e1 ];
S = [ 1e-2 1e-2 1e-1 1e0 1e0 ]; % noise covariances
W = 1e-1; % measurement noise variance

%% Unscented Kalman Filter (ukf)
% Object definition
ukf = unscentedKalmanFilter(@ukf_f, @(X,~,~) X(1), X0);
ukf.MeasurementNoise = W;
ukf.ProcessNoise = diag(S);
ukf.StateCovariance = diag(S);
end

%% Model definition
% d/dt y =  x*w + y*(a - x^2 - y^2)/(tau*a) + k*u + n_y
% d/dt x = -y*w + x*(a - x^2 - y^2)/(tau*a)       + n_x
% d/dt w = 0 + n_w
% d/dt a = 0 + n_a
% d/dt k = 0 + n_k

%1
% d/dt y =  x*w + y*(a - x^2 - y^2)/(tau) + k1*u + n_y, decrease tau
% d/dt x = -y*w + x*(a - x^2 - y^2)/(tau) + k2*u + n_x
% d/dt w = 0 + n_w
% d/dt a = 0 + n_a
% d/dt k = 0 + n_k

%2
% d/dt y =  x*w + k1*u + n_y
% d/dt x = -y*w + k2*u + n_x
% d/dt w = 0 + n_w
% d/dt k1 = 0 + n_k1
% d/dt k2 = 0 + n_k2


%% Function definitions
function X = ukf_f(X, u, dt)
    % State transition function f, specified as a function handle.
    % The function calculates the Ns-element state vector of the system at
    % time step k, given the state vector at time step k-1.
    % Ns is the number of states of the nonlinear system.
    y = X(1);
    x = X(2);
    w = X(3);
    k1 = X(4);
    k2 = X(5);
    
    % Calculate derivatives
    y_ =  x*w + k1*u;
    x_ = -y*w + k2*u;
    
    X = X + dt*[y_ x_ 0 0 0]';
end
