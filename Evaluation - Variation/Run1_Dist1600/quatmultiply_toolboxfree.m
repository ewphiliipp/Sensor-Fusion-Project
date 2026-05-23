%% -------------------------------------------------------------------------
%% Quaternion multiplication WITHOUT Aerospace Toolbox
%% -------------------------------------------------------------------------
function q = quatmultiply_toolboxfree(q, r)
% Multiply two quaternions q and r (1x4 row vectors [w x y z])
w1 = q(1); x1 = q(2); y1 = q(3); z1 = q(4);
w2 = r(1); x2 = r(2); y2 = r(3); z2 = r(4);

w = w1*w2 - x1*x2 - y1*y2 - z1*z2;
x = w1*x2 + x1*w2 + y1*z2 - z1*y2;
y = w1*y2 - x1*z2 + y1*w2 + z1*x2;
z = w1*z2 + x1*y2 - y1*x2 + z1*w2;

q = [w x y z];
end