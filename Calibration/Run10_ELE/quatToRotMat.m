function R = quatToRotMat(q)
    % q: 1x4 quaternion [w x y z] -> 3x3 rotation matrix R (body->world)
    w = q(1); x = q(2); y = q(3); z = q(4);
    % normalize
    n = sqrt(w^2+x^2+y^2+z^2);
    w=w/n; x=x/n; y=y/n; z=z/n;
    R = [1-2*(y^2+z^2),   2*(x*y - z*w),    2*(x*z + y*w);
         2*(x*y + z*w),   1-2*(x^2+z^2),    2*(y*z - x*w);
         2*(x*z - y*w),   2*(y*z + x*w),    1-2*(x^2+y^2)];
end
