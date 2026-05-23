function q_new = madgwickAHRSupdate(q_prev, gyro, acc, mag, beta, dt)
% q_prev : previous quaternion [w x y z] (1x4 row vector)
% gyro   : current gyroscope measurement [gx gy gz] in rad/s (row or col)
% acc    : current accelerometer measurement [ax ay az] in m/s^2 (row or col)
% mag    : current magnetometer measurement [mx my mz] in uT (row or col)
% beta   : algorithm gain (default: 0.1-0.3)
% dt     : time step in seconds
%
% Returns:
% q_new : updated quaternion [w x y z]

%% 0. Ensure inputs are row vectors
gyro = gyro(:)';  % make 1x3 row
acc  = acc(:)';   % make 1x3 row
mag  = mag(:)';   % make 1x3 row

%% 1. Normalize accelerometer measurement
if norm(acc) == 0
    acc = [0 0 0]; % avoid division by zero
else
    acc = acc / norm(acc);
end

%% 2. Normalize magnetometer measurement
if norm(mag) == 0
    mag = [0 0 0];
else
    mag = mag / norm(mag);
end

%% 3. Quaternion derivative from gyroscope
omega = [0, gyro]; % pure quaternion [w x y z]
qDot_omega = quatmultiply_toolboxfree(q_prev, omega); % see below

%% 4. Gradient descent correction (Madgwick)
f = [...
    2*(q_prev(2)*q_prev(4) - q_prev(1)*q_prev(3)) - acc(1); ...
    2*(q_prev(1)*q_prev(2) + q_prev(3)*q_prev(4)) - acc(2); ...
    2*(0.5 - q_prev(2)^2 - q_prev(3)^2) - acc(3)];

J = [...
   -2*q_prev(3)  2*q_prev(4) -2*q_prev(1)  2*q_prev(2); ...
    2*q_prev(2)  2*q_prev(1)  2*q_prev(4)  2*q_prev(3); ...
    0           -4*q_prev(2) -4*q_prev(3)  0];

step = J' * f;
if norm(step) > 0
    step = step / norm(step);
end

%% 5. Integrate to update quaternion
q_dot = qDot_omega - beta*step';
q_new = q_prev + q_dot * dt;
q_new = q_new / norm(q_new); % normalize

end