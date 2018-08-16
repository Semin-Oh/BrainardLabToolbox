function [A,Ainv,Q] = EllipsoidMatricesGenerate(ellParams)
% A = EllipsoidMatricesGenerate(ellParams)
% 
% Generate the 3 by 3 matrix A from a 6-vector of parameters.  When applied to points on 
% the ellipsoid it specifies, the matrix A maps these points to the unit sphere in 3D.
% Thus the matrix inv(A) maps points on the unit sphere to points on the ellipsoid.
%
% The column vector ellParams are the the diagonal entries of a 3 by 3 matrix D
% and the Euler rotation angles (in radians) for a 3D rotation matrix R.
%
% The parameter matrix can optionally by 9 entries long, in which case the
% last three entries are the coordinates of the center of the ellipsoid.
%
% The matrix D stretches the x, y, and z axes in the coordinate system of the unit sphere,
% producing the three princple axes of the ellipsoid aligned to x, y, z.
%
% The rotation matrix R rotates these axes to their desired orientations.
%
% Q is given as A'*A, and has the property that for points x on the ellipsoid,
% x'*Q*x = 1.
%
% The Euler angles are passed to eul2rotm and interpretted in its default
% 'ZYX' order.  Thus the Euler angles are in radians.
%
% The parameterization of Q follows that in 
%   Poirson AB, Wandell BA, Varner DC, Brainard DH. 1990. Surface
%   characterizations of color thresholds. J. Opt. Soc. Am. A 7: 783-89.
% See particularly pp. 784-785.
%
% 06/27/16  dhb  Back to the future.  Wrote this.  It feels like 1988.
% 08/16/18  dhb  Change parameterization to match paper.

% Handle offset case
if (length(ellParams == 9))
    ellParams = ellParams(1:6);
end

%% This was the code prior to 08/16/18.
%
% It represents a different parameterization
% of Q, but we now like the current parameterization
% better, because the current one matches how we think.

% D = diag(ellParams(1:3));
% R = eul2rotm(ellParams(4:6)');
% Ainv = R*D;
% A = inv(Ainv);

S = diag(ellParams(1:3));
V = eul2rotm(ellParams(4:6)');
A = S*V';
Ainv = inv(A);

Q = A'*A;

