%% Overview
%
% This script will:
%                   1.) load data
%                   2.) preprocess (clean up data)
%                   3.) find peaks (what we are interested in)
%                   4.) plot data
%                   5.) statistical tests
%                   6.) save data
%
%   Author: Diar Karim
%   Date: 05/12/2016
%   Version: 9.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WristOribit_v7()

% Get user input
handles.edit1 = str2num(input('Please input the participant number: '));
handles.popupmenu1 = str2num(input('Flex-Ext (1) // Pro-Sup (2) // Uln-Rad (3): '));
handles.popupmenu2 = str2num(input('Trial number 1-5: '));
handles.edit3= input('Path directory to recorded data: '); % This is also where the files are stored

% Declare loop variables
ParticipantNumber = handles.edit1;
testType = handles.popupmenu1;
trialNum = handles.popupmenu2;
pathDirectory = handles.edit3; 

cd(pathDirectory)
%% 1.) Load data (Make sure to only use the right hand trials)
if testType ==1
    filez = dir(sprintf('Subject_%02d_F_R_*',ParticipantNumber));  
    load(filez(trialNum).name)
elseif testType == 2
    filez = dir(sprintf('Subject_%02d_PS_R_*',ParticipantNumber));  
    load(filez(trialNum).name)
elseif testType == 3
    filez = dir(sprintf('Subject_%02d_U_R_*',ParticipantNumber));  
    load(filez(trialNum).name)
end

%% 2.) Preprocess
% Preprocessing of Liberty
D = snip(D,nan);

% Run prerequisite scripts
if testType == 2 
    tiltang = sqrt(D(:,12).^2); % This is only for pronation
else
    tiltang = handOrient_v6(D); % This separate script will output the tilt angle from Liberty (tiltang)
end

% Correct for zero offset of liberty channels
flexdiff = D(1,5);
prodiff = D(1,6);
ulndiff = D(1,4);
tiltdiff = tiltang(1,1);

flex = D(:,5)-flexdiff;
pro= D(:,6)-prodiff;
uln = D(:,4)-ulndiff;
tiltang = tiltang - tiltdiff;
tiltang = tiltang.*2;

% Preprocessing of Leapmotion now
for i = 2:2:length(leapDat)
    
    try
        
        inFlx = strfind(leapDat{i},'pitch');
        pitch(i,:) = str2num(leapDat{i}(inFlx+7:inFlx+12));
        
        inRol = strfind(leapDat{i},'roll');
        roll(i,:) = str2num(leapDat{i}(inRol+7:inRol+12));
        
        inYaw = strfind(leapDat{i},'yaw');
        yaw(i,:) = str2num(leapDat{i}(inYaw+4:inYaw+10));
        
    catch
    end
end

% Clean up Leap data as we did with Liberty (D)
pitch(pitch==0) = nan;
pitch = snip(pitch,nan);
roll(roll==0) = nan;
roll = snip(roll,nan);
yaw(yaw==0) = nan;
yaw = snip(yaw,nan);

% Correct for Leapmotion zero offset
pitchdiff = pitch(1,:);
rolldiff = roll(1,:);
yawdiff = yaw(1,:);

pitch = pitch - pitchdiff;
roll = roll- rolldiff;
yaw = yaw - yawdiff;

% Make all the values positive
pitch = sqrt(pitch.^2);
roll = sqrt(roll.^2);
yaw = sqrt(yaw.^2);

% Filter leapmotion signals
[b,a] = butter(6,0.1);
pitch = filtfilt(b,a,pitch);
roll = filtfilt(b,a,roll);
yaw = filtfilt(b,a,yaw);

% Downsample
samplez = fix(size(uln)/size(pitch)); % Downsampling constant for liberty and leap to be on the same page
tiltang = downsample(tiltang,samplez);

%% 3.) Find peaks
if testType == 1
    LeapAng = pitch;
    minPeak = 60;
elseif testType == 2
    LeapAng = roll;
    minPeak = 40;
elseif testType == 3
    LeapAng = yaw;
    minPeak = 20;
end

% Updated version 
% Find first peaks (flextion/ pronation/ ulnar) from leapmotion and liberty
[lep_e,lep_f] = peakdet(LeapAng,minPeak);
% Find second peaks (extension/ supination/ radial) from leapmotion and liberty
[lty_e,lty_f] = peakdet(tiltang,minPeak);


%% 4.) Plot raw data
subplot(2,1,1)
cla
plot(LeapAng,'b') % Leap
hold on
plot(tiltang,'m') % Liberty

%plot(downsample(uln,samplez),'m') % Uln
title('Wrist Movements','FontSize',16)
xlabel('Time Steps','FontSize',14)
ylabel('Angle/ deg','FontSize',14)
%legend('Flex','Pro','Uln','FlexL','ProL','UlnL')
legend('Leapmotion','Liberty')

x= 200;
y=-20;

%plot(lep_f(:,1),lep_f(:,2),'gd');
%text(x,y,'Select leap flexion'); [lep_flxX,lep_flxY] = getpts(1); 
%plot(lty_f(:,1),lty_f(:,2),'gd');
%text(x,y,'Select liberty flexion'); [lty_flxX,lty_flxY] = getpts(1); 
plot(lep_e(:,1),lep_e(:,2),'r*');
%text(x,y,'Select leap extension'); [lep_extX,lep_extY] = getpts(1); 
plot(lty_e(:,1),lty_e(:,2),'g*');
%text(x,y,'Select leap extension'); [lty_extX,lty_extY] = getpts(1); 

% Store peak angles in variables for saving
leapPeak_dir1 = lep_e(1:2:end,:);
libtyPeak_dir1 = lty_e(1:2:end,:);
leapPeak_dir2 = lep_e(2:2:end,:);
libtyPeak_dir2 = lty_e(2:2:end,:);

% 5.2)Compute averages, standard errors etc. and plot as bar charts
% Average
m_lep_f = nanmean(leapPeak_dir1(:,2));
m_lty_f = nanmean(libtyPeak_dir1(:,2));
m_lep_e = nanmean(leapPeak_dir2(:,2));
m_lty_e = nanmean(libtyPeak_dir2(:,2));
% Standard error
ste_lep_f = std(leapPeak_dir1(:,2))/sqrt(length(leapPeak_dir1(:,2)));
ste_lty_f = std(libtyPeak_dir1(:,2))/sqrt(length(libtyPeak_dir1(:,2)));
ste_lep_e = std(leapPeak_dir2(:,2))/sqrt(length(leapPeak_dir2(:,2)));
ste_lty_e = std(libtyPeak_dir2(:,2))/sqrt(length(libtyPeak_dir2(:,2)));

subplot(2,1,2)
cla
hold on
bar1 = bar([-m_lep_f, -m_lty_f],'g');
errorbar([1 2],[-m_lep_f, -m_lty_f],[ste_lep_f,ste_lty_f],'.')
bar2 = bar([m_lep_e, m_lty_e],'r');
errorbar([1 2],[m_lep_e, m_lty_e],[ste_lep_e,ste_lty_e],'.')
legend('Direction 1',' ','Direction 2')

title('Average Range of Wrist Motion','FontSize',16)
xlabel('Device','FontSize',14)
set(gca,'XTick',1:2,'XTickLabel',{'Leapmotion','Liberty'})
ylabel('Angle/ deg','FontSize',14)
xlim([0.5 2.5])

%% 5.) Statistical tests
[hf,pf] = ttest2(leapPeak_dir1(:,2),libtyPeak_dir1(:,2));
[he,pe] = ttest2(leapPeak_dir2(:,2),libtyPeak_dir2(:,2));


%% 6.) Save data to file 
if testType == 1
    conditionz = 'Flex_Ext';
elseif testType ==2 
    conditionz = 'Pro_Supi';
elseif testType == 3
    conditionz = 'Uln_Rad';
end

save(sprintf('%s/Results_Participant_%02d_%s_Trial_%02d',pathDirectory,ParticipantNumber,conditionz,trialNum),'LeapAng','tiltang','leapPeak_dir1','libtyPeak_dir1','leapPeak_dir2','libtyPeak_dir2','hf','pf','he','pe')
