%   Tao Du
%   taodu@stanford.edu
%   May 29, 2014

%   Xp coordinates:
%   [0, 0]...    [nx-1, 0]
%   .
%   .
%   .
%   [0, ny-1]    [nx-1, ny-1]

function [ Xp ] = camera_to_pixel( XXc, kc, KK )
x = XXc(1) / XXc(3);
y = XXc(2) / XXc(3);
Xn = [x; y];
r = norm(Xn);
dx = [2*kc(3)*x*y+kc(4)*(r^2+2*x^2); kc(3)*(r^2+2*y^2)+2*kc(4)*x*y];
Xd = (1 + kc(1) * r^2 + kc(2) * r^4 + kc(5) * r^6)*Xn + dx;
Xp = KK * [Xd; 1];
Xp = Xp(1:2);
end