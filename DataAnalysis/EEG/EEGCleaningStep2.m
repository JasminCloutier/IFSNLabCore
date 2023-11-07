SUB = {'S2', 'S3', 'S4', 'S8','S9', 'S10','S11', 'S12', 'S13', 'S14', 'S15', 'S16', 'S17', 'S18', 'S19','S20','S21','S22','S23','S24','S25','S26','S27','S28','S29','S30','S31','S32','S33','S34','S35','S36','S37','S38','S39','S40','S41','S42'};
numsubjects = length(SUB);  
parentfolder = 'C:\Users\Sam\Documents\MATLAB\RS-EEG_ReRun';

%Load the Excel file with the list of channels to interpolate for each subject 
[ndata1, text1, alldata1] = xlsread([parentfolder filesep 'Interpolate_Channels_RSEEG']);


for i=1:numsubjects
   [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    Subject_Path = [parentfolder filesep SUB{i} filesep];

     EEG = pop_loadset( 'filename', [SUB{i} '_filt_ds_trimmed.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', [SUB{i} '_filt_ds_trimmed.set'], 'gui', 'off'); 

    
    
  %Interpolate channel(s) specified in Excel file Interpolate_Channels_RSEEG.xls; any channels without channel locations (e.g., the eye channels) should not be included in the interpolation process and are listed in ignored channels
    %EEG channels that will later be used for measurement of the ERPs should not be interpolated
    ignored_channels = [1 19 45 54 64 85 100 115 125 129:136];        
    DimensionsOfFile1 = size(alldata1);
    for j = 1:DimensionsOfFile1(1);
        if isequal(SUB{i},num2str(alldata1{j,1}));
           badchans = (alldata1{j,2});
           if ~isequal(badchans,'none') | ~isempty(badchans)
           	  if ~isnumeric(badchans)
                 badchans = str2num(badchans);
              end
              EEG  = pop_erplabInterpolateElectrodes( EEG , 'displayEEG',  0, 'ignoreChannels',  ignored_channels, 'interpolationMethod', 'spherical', 'replaceChannels', badchans);
           end
           [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', [SUB{i} '_filt_ds_trimmed_interpolated'], 'savenew', [Subject_Path SUB{i} '_filt_ds_trimmed_interpolated.set'], 'gui', 'off'); 
        end
    end

end;
