%% HandOrient
%
% This scripts takes in Polhemus Liberty 6Dof motion capture data from two
% markers and computes the angle between the y-axis of the second marker to 
% the first marker. 
% 
% Input: Motion capture data from two 6Dof objects 
% Output: Angle between the y-axis of marker 2 and the position of marker 1
%
% Author: Diar Karim
% Date: 25/11/2016
% Contact: diarkarim@gmail.com
% Credits: Ermano Arruda
% 
% Copyright: Please refer to the Apache License 2.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function angDegree = handOrient_v5(D)

for i = 1:length(D)
% Marker 1
P = D(i,1:3)';
O = D(i,4:6)';
angx = deg2rad(D(i,4));
angy = deg2rad(D(i,5));
angz = deg2rad(D(i,6));
% Marker 2
P2 = D(i,7:9)';
O2 = D(i,10:12)';
angx2 = deg2rad(D(i,10));
angy2 = deg2rad(D(i,11));
angz2 = deg2rad(D(i,12));

VRt3 = (D(1,1:3)-D(1,7:9))/norm((D(1,1:3)-D(1,7:9))); 

%%  Rot mat 1
Rx = [1, 0, 0;
    0 cos(angx), -sin(angx);
    0 sin(angx), cos(angx)];

Ry = [cos(angy), 0, sin(angy);
    0 ,1, 0;
    -sin(angy), 0, cos(angy)];

Rz = [cos(angz), -sin(angz), 0;
    sin(angz) , cos(angz), 0;
    0, 0, 1];

R = Rx*Ry*Rz;

V1 = R(:,1);
V2 = R(:,2);
V3 = R(:,3);

%%  Rot mat 2
Rx2 = [1, 0, 0;
    0 cos(angx2), -sin(angx2);
    0 sin(angx2), cos(angx2)];

Ry2 = [cos(angy2), 0, sin(angy2);
    0 ,1, 0;
    -sin(angy2), 0, cos(angy2)];

Rz2 = [cos(angz2), -sin(angz2), 0;
    sin(angz2) , cos(angz2), 0;
    0, 0, 1];

R2 = Rx2*Ry2*Rz2;

Vt1 = R2(:,1);
Vt2 = R2(:,2);
Vt3 = R2(:,3);

p1 = P + V1;
p2 = P + V2;
p3 = P + V3;

pt1 = P2 + Vt1;
pt2 = P2 + Vt2;
pt3 = P2 + Vt3;

pDist(i,:) = P-P2;
normPDist(i,:) = pDist(i,:)/norm(pDist(i,:)); 

dotV(i,:) = dot(normPDist(i,:),VRt3);
crossPro(i,:) = cross(normPDist(i,:),VRt3);
normCPro(i,:) = crossPro(i,:)/norm(crossPro(i,:));
compAngle(i,:) = acos(dotV(i,:));

end

angDegree = rad2deg(compAngle);
