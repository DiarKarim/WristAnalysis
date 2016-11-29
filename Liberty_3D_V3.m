%function D = Liberty_RT_2nd_PosCopie(td)

% Declare loop variables
i = 1;

%load('Subject_08_F_R_Trial_13.mat')
D = snip(D,nan);
timez = snip(timez,nan);
ratez = (timez./30);
tmz = timez./ratez(end);

initOff = sqrt((D(1,7) - D(1,1)).^2 + (D(1,8) - D(1,2)).^2 + (D(1,9) - D(1,3)).^2);

%% virtual markers offset
offx1 = 0; % marker1 x
offy1 = -initOff; % marker1 y
offz1 = 0; % marker1 z


%%
%tic
for i = 1:length(D)
    
    %% generate virtual markers
    %rm1 = ang2orth(D(i,4:6)./180*pi); % rotational matrix for marker 1
    %vm1(i,1:3) = (rm1*[offx1;offy1;offz1]).'+D(i,1:3); % virtual marker 1
    vm1(i,1:3) = ([offx1;offy1;offz1]).'+D(i,1:3); % virtual marker 1
    
end


