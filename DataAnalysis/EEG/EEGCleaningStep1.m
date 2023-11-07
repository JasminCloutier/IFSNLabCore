SUB = {'S2', 'S3', 'S4','S7', 'S8','S9', 'S10','S11', 'S12', 'S13', 'S14', 'S15', 'S16', 'S17', 'S18', 'S19','S20','S21','S22','S23','S24','S25','S26','S27','S28','S29','S30','S31','S32','S33','S34','S35','S36','S37','S38','S39','S40','S41','S42'};
numsubjects = length(SUB);  
parentfolder = 'C:\Users\Sam\Documents\MATLAB\RS-EEG_ReRun';


CURRENTERP = 0;

for i=1:numsubjects
   Subject_Path = [parentfolder filesep SUB{i} filesep];


% Load in dataset using M1 (129) as the reference electrode
 EEG = pop_loadset( 'filename', [SUB{i} '.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', SUB{i} , 'gui', 'off');  

%%Step 1 filtering
%Notch Filter:
EEG  = pop_basicfilter( EEG,  1:136 , 'Boundary', 'boundary', 'Cutoff',  60, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180, 'RemoveDC',...
 'on' ); 
%Butterworth Filter:
EEG  = pop_basicfilter( EEG,  1:136 , 'Boundary', 'boundary', 'Cutoff', [ 0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  2,...
 'RemoveDC', 'on' ); 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',[SUB{i} '_filt'],'savenew',[Subject_Path SUB{i} '_filt.set'] ,'gui','off'); 
%%Step 2: Downsample
EEG=pop_resample(EEG,512);
%[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',[SUB{i} '_filt_ds'],'savenew',[Subject_Path SUB{i} '_filt_ds.set'] ,'gui','off'); 
%%Step 3: Channel Locations

%note to future self or others who use this script verify correct path 
EEG=pop_chanedit(EEG,'lookup','C:\\Users\\Sam\\Documents\\MATLAB\\BioSemi_128.elp');

%%Step 4: Removing Messy data between blocks and Blinks 
% This solution may not be the best, but it'll delete long pauses between
% blocks. Since no trials were longer than 2 seconds this should eliminate
% most of the noisy baseline data

EEG = pop_erplabDeleteTimeSegments(EEG, 'timeThresholdMS', 3000,'startEventcodeBufferMS', 100,'endEventcodeBufferMS', 200,'ignoreUseEventcodes', [],'ignoreUseType', 'ignore','displayEEG', false);
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % store changes
eeglab redraw % redraw interface
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'setname',[SUB{i} '_filt_ds_trimmed'],'savenew',[Subject_Path SUB{i} '_filt_ds_trimmed.set'] ,'gui','off'); 



end;
