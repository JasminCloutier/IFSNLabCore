function behavior = Ultimatum_RESP(subjectName, gender, istest, scanner);

%Usage: subjectData = SunkCost(subjectName, istest, scanner);

% gender can be 'm' or 'f
%if istest = 1; task only runs 2 trials for testing
%A typical test session would use the following function:
% behavior = SunkCost('test',1)

%if istest = 0; task has 80 trials for each session
%A typical real session would then be:
% behavior = SunkCost('080101', 0, 0/1);

% scanner option is to deal with the fact that subjects can only use
% button-box in the scanner (they can't enter the WTP numerically).
% scanner == 0 --> keyboard entry for WTP
% scanner == 1 --> button box entry for WTP

%Due to the fact that different monitor has different resolutions,
%it might be the case that code needs to be modified for better
%presentation effect. 

%Currently the code works best for 1024*768.

if nargin < 4
    scanner = 0;
    if nargin < 3;
            subjectName = 'Dummy';
            istest = 1;
            gender = 'm';
    end
end


if ispc;
    addpath(genpath('C:\Toolboxes\Psychtoolbox')); %make sure the code can be run on Matlab 7.5
    %addpath('stimuli');
    path('C:\Toolboxes\Psychtoolbox\PsychBasic\MatlabWindowsFilesR2007a\', path);
elseif ismac;
    addpath(genpath('/Applications/Psychtoolbox'));
elseif isunix;
    addpath(genpath(input('Please specify the path for Psychtoolbox folder\n', 's')));
end

% Add this at top of new scripts for maximum portability due to unified names on all systems:
KbName('UnifyKeyNames');

%Debug GetChar
PsychJavaTrouble;

%# of pics in each group
nWhite = 60;
nBlack = 60;
nOther = 40;
endowment = 10;

if istest;
    numRepeat = 2;
else 
    numRepeat = (nWhite+nBlack+nOther)/2;
end

behavior.name = subjectName; %write down subject Name
behavior.istest = istest;
behavior.scanner = scanner;
behavior.gender = gender;

%proposer pics
allPics = dir('All/*.bmp');

%offer amounts
bOffers = [0 2.5 5 7.5 10 11 12 13 14 15 16 17 18 19 20 20.667 21.333 22 ...
            22.667 23.333 24 24.667 25.333 26 26.667 27.333 28 28.667 29.333 30 ...
            30 30.667 31.333 32 32.667 33.333 34 34.667 35.333 36 36.667 37.333 38 ...
            38.667 39.333 40 41 42 43 44 45 46 47 48 49 50 52.5 55 57.5 60]'./10;

wOffers = [0 2.5 5 7.5 10 11 12 13 14 15 16 17 18 19 20 20.667 21.333 22 ...
            22.667 23.333 24 24.667 25.333 26 26.667 27.333 28 28.667 29.333 30 ...
            30 30.667 31.333 32 32.667 33.333 34 34.667 35.333 36 36.667 37.333 38 ...
            38.667 39.333 40 41 42 43 44 45 46 47 48 49 50 52.5 55 57.5 60]'./10;


oOffers = [0 3 6 9 10 12 14 16 18 19 20 21 22 ...
           23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40  ...
           42 44 46 48 49 50 53 56 60]'./10;
       
%Sequence of pics for each category
picSeq = randperm(nWhite+nBlack+nOther);
raceInd = [];
for i = 1:length(allPics);
    raceInd = [raceInd; allPics(i).name(1)];
    picNames{i} = allPics(i).name;
end

behavior.raceInd = raceInd(picSeq);
behavior.picNames = picNames(picSeq);


    %experiment variables
    %YesKey = {'q' '6^' '7&' '8*' '9(' '0)'}; %press 1 for agreeing to pay entry fee
    %NoKey = {'p' '1!' '2@' '3#' '4$' '5%'}; %press 2 for denying to pay entry fee
        yesKey = {'1' '1!'};
        noKey  = {'2' '2@'};
        
    % button configuration
    bbutton1 = '1!'; %define button "1"
    bbutton2 = '2@'; %define button "2"
    bbutton3 = '3#';
    bbutton4 = '4$';
    bbutton5 = '5%';
    bbutton6 = '6^';
    bbutton7 = '7&';
    bbutton8 = '8*';
    bbutton9 = '9(';
    bbutton10 = '0)';
    
    
     % Set keys.
    KbName('UnifyKeyNames');
    yKey = KbName(yesKey);
    nKey = KbName(noKey);
    button1 = KbName(bbutton1);
    button2 = KbName(bbutton2);
    button3 = KbName(bbutton3);
    button4 = KbName(bbutton4);
    button5 = KbName(bbutton5);
    button6 = KbName(bbutton6);
    button7 = KbName(bbutton7);
    button8 = KbName(bbutton8);
    button9 = KbName(bbutton9);
    button10 = KbName(bbutton10);
    escapeKey = KbName('ESCAPE');
    if ispc;
        backtick = KbName('`');
    else
        backtick = KbName('`~');
    end
    
    
   
 % --- Initialize Screen --- %
 try
    AssertOpenGL;
    
    %Supress keyboard input to Matlab command window
    ListenChar(2);


    % find how many displays
    screens = Screen('Screens');
    screenNumber = max(screens);
    
    % open a window
    %windowPtr=Screen('OpenWindow', screennr, [,color] [,rect][,depth][,buffers][,stereo]);
    %w--> screen
    %wRect --> screen rectangle
    [w, wRect] = Screen('OpenWindow', screenNumber, 0, [],[], 2);
    [xcenter,ycenter] = RectCenter(wRect)
    HideCursor;
    
    fontSize = 40;
    Screen('TextFont', w, 'Geneva');
    Screen('TextSize', w, fontSize);           % text size
    
    black = BlackIndex(w);               % Retrieves the CLUT color code for black.
    white = WhiteIndex(w);              % Retrieves the CLUT color code for white.
    gray = (black+white)/2;
    red = [255 0 0];
    green = [0 255 0];
    darkGreen = [0 100 0];
    blue = [0 191 255];
    Screen('FillRect', w, black);          % sets background to gray
    
    %set priority for the program
    priorityLevel = MaxPriority(w);    % set priority
    Priority(priorityLevel);
    
    % - Create Fixation Screen with Brief Instructions- %
    DrawFormattedText(w, 'Press any key to indicate you are ready to start the game', 'center', 'center', white);
    %Screen('gluDisk', w, white, xcenter, ycenter, 8); 
    Screen('Flip', w);
    
    while KbCheck; end % Wait until all keys are released
    while 1
        [ keyIsDown, seconds, keyCode] = KbCheck;
        if (keyIsDown & size(find(keyCode), 2) == 1);
            fprintf('You pressed key %i which is %s\n', find(keyCode), KbName(keyCode));
            if keyCode(escapeKey)
                error('experiment aborted by user');
            else
                break;
            end
            while KbCheck; end
        end
    end

    
    nBlocks = 2;
    tDecMax = 5;
    
    pTOffer = []; %with format of [time, actualOffer]
    uTDecision = []; %with format of [time, actualDec]
    TOutcome = [];
    origOffer = [];
    
   for i = 1:nBlocks;
       
       DrawFormattedText(w, sprintf('Session   #%d', i), 'center', 'center', white);
       Screen('Flip', w);
       
       WaitSecs(2);
       
       startTime = GetSecs;  %dummy start time for testing sessions.
       
       %Waiting for the trigger
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%%start receiving scanner trigger signal%%%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
       if scanner;
           DrawFormattedText(w, 'The scanner is starting...', 'center', 'center', white);
           Screen('Flip', w);

           while KbCheck; end
            while 1
                [keyIsDown, seconds, keyCode] = KbCheck;
                if (keyIsDown & size(find(keyCode), 2) == 1);
                    fprintf('You pressed key %i which is %s\n', find(keyCode), KbName(keyCode));
                    if keyCode(backtick);
                        startTime = GetSecs;
                        behavior.scannerStart = startTime;
                        break;
                    end
                    while KbCheck; end
                end
            end

           DrawFormattedText(w, 'Please Get Ready!', 'center', 'center', white);
           Screen('Flip', w);
           WaitSecs(2); %stay on screen for 2s

           Screen('gluDisk', w, white, xcenter, ycenter, 8);
           Screen('Flip',w);
       end
       
       %load male and female avatar images 
       fAvatarFile = 'femaleAvatar.jpg';
       fAvatarPic = imread(fAvatarFile);
       
       mAvatarFile = 'maleAvatar.jpg';
       mAvatarPic = imread(mAvatarFile);

       for j = 1:numRepeat; %80 trials each block
          
            %get proposer pic file
            proposerFile = ['All/' behavior.picNames{(i-1)*numRepeat+j}];
            %load proposer pic
            proposerPic = imread(proposerFile);
            
            %determine offer level
            if strcmp(behavior.raceInd((i-1)*numRepeat+j), 'w');
                pOffer = randsample(wOffers, 1);
                wOffers = setdiff(wOffers, pOffer);
            elseif strcmp(behavior.raceInd((i-1)*numRepeat+j), 'b');
                pOffer = randsample(bOffers, 1);
                bOffers = setdiff(bOffers, pOffer);
            elseif strcmp(behavior.raceInd((i-1)*numRepeat+j), 'o');
                pOffer = randsample(oOffers, 1);
                oOffers = setdiff(oOffers, pOffer);
            end
            
            origOffer = [origOffer; pOffer];
            pOffer = pOffer+(rand-.5)/10; %add some randomness to the proposer offer
            if pOffer < 0;
               pOffer = 0;
            end
            
            DrawFormattedText(w, ' OFFER', 'center', ycenter-360, white);
            
            Screen('PutImage', w, proposerPic, [xcenter-110 ycenter-200 xcenter ycenter-50]);
            %DrawFormattedText(w, 'You', xcenter-70, ycenter+50, white);
            if strcmp(gender, 'm');
                Screen('PutImage', w, mAvatarPic, [xcenter-110 ycenter+50 xcenter ycenter+200]);
            elseif strcmp(gender, 'f');
                Screen('PutImage', w, fAvatarPic, [xcenter-110 ycenter+50 xcenter ycenter+200]);
            end
            
            DrawFormattedText(w, sprintf('%2.2f', endowment-pOffer), xcenter+50, ycenter-135, white);
            DrawFormattedText(w, sprintf('%2.2f', pOffer), xcenter+50, ycenter+115, white);
            
            DrawFormattedText(w, '1 - Accept', round(.5*xcenter), round(ycenter*7/4), green);
            DrawFormattedText(w, '2 - Reject', round(1.5*xcenter), round(ycenter*7/4), red);
            Screen('Flip', w);
            
            offerTime = GetSecs;
            pTOffer = [pTOffer; [offerTime-startTime pOffer]];
            
            while KbCheck; end % Wait until all keys are released
            
            while GetSecs - offerTime <= tDecMax;
                
                [keyIsDown, seconds, keyCode] = KbCheck;
                if (keyIsDown & size(find(keyCode), 2) == 1);
                    fprintf('You pressed key %i which is %s\n', find(keyCode), KbName(keyCode));
                    if keyCode(escapeKey)
                        error('experiment aborted by user');
                    elseif any(keyCode([yKey nKey]));
                        break;
                    end
                    while KbCheck; end
                end
            end

            if ~keyIsDown;
                %show warning info+
                DrawFormattedText(w, 'Reaction window expired. Please respond faster next time!', 'center', 'center', red);
                Screen('Flip', w);
                WaitSecs(3);
                
                uTDecision = [uTDecision; [NaN NaN]];
                TOutcome = [TOutcome; [NaN NaN NaN]];

                %show the fixation    
                Screen('gluDisk', w, white, xcenter, ycenter, 8);
                Screen('Flip',w);

                %wait 2 extra seconds such that the total duration for each
                %trial is 9 sec
                WaitSecs(4*rand);
                
            else
                
                if (ismember({KbName(keyCode)}, yesKey));
                    uTDecision = [uTDecision; [GetSecs-startTime 1]]; %1 -->Accept
                    %show the fixation    
                    %Screen('gluDisk', w, white, xcenter, ycenter, 8);
                    %Screen('Flip',w);
                    DrawFormattedText(w, sprintf('%2.2f', endowment-pOffer), xcenter+50, ycenter-135, blue);
                    DrawFormattedText(w, sprintf('%2.2f', pOffer), xcenter+50, ycenter+115, blue);
                    trialOutcome = [endowment-pOffer pOffer];
                elseif (ismember({KbName(keyCode)}, noKey));
                    uTDecision = [uTDecision; [GetSecs-startTime 2]]; %2 -->Reject
                    
                    %show the fixation    
                    %Screen('gluDisk', w, white, xcenter, ycenter, 8);
                    %Screen('Flip',w);
                    DrawFormattedText(w, sprintf('%2.2f', 0), xcenter+50, ycenter-135, blue);
                    DrawFormattedText(w, sprintf('%2.2f', 0), xcenter+50, ycenter+115, blue);
                    trialOutcome = [0 0];
                end
                
                %WaitSecs(3);
                DrawFormattedText(w, 'OUTCOME', 'center', ycenter-360, blue);
                Screen('PutImage', w, proposerPic, [xcenter-110 ycenter-200 xcenter ycenter-50]);
                %DrawFormattedText(w, 'You', xcenter-70, ycenter+50, white);
                if strcmp(gender, 'm');
                    Screen('PutImage', w, mAvatarPic, [xcenter-110 ycenter+50 xcenter ycenter+200]);
                elseif strcmp(gender, 'f');
                    Screen('PutImage', w, fAvatarPic, [xcenter-110 ycenter+50 xcenter ycenter+200]);
                end
                Screen('Flip', w);
                
                TOutcome = [TOutcome; [GetSecs-startTime  trialOutcome]]; %with format: time/proposer outcome/responder outcome
            
                %outcome on screen for 1.5s
          %      WaitSecs(1.5);


                %show the fixation    
                Screen('gluDisk', w, white, xcenter, ycenter, 8);
                Screen('Flip',w);
          %      WaitSecs(1+4*rand+(tDecMax-(uTDecision(end,1)-pTOffer(end,1))));  %compensate time  
            end
       end
       if scanner;
            WaitSecs(8); %collect additional scans
       else
           WaitSecs(1); %behavioral test only needs to wait 3 secs
       end
   end
   
   behavior.pTOffer = pTOffer;
   behavior.uTDecision = uTDecision;
   behavior.TOutcome = TOutcome;
   behavior.origOffer = origOffer;
   
   DrawFormattedText(w, sprintf('Session   #%d', nBlocks+1), 'center', 'center', white);
   Screen('Flip', w);
   
   WaitSecs(2);
   
   if ~istest,
       futureTrialN = 5;
   else
       futureTrialN = 2;
   end
   
   for i = 1:futureTrialN;
       futureOffers{i} = Ask(w, sprintf('Future trial %d - Your Offer (0%%-100%%)?   ', i), white, black, 'GetChar', [xcenter-160 ycenter-140 xcenter+80 ycenter], 'center', 40); %, wRect(3), wRect(4));
   end
   
   behavior.futureOffers = futureOffers;
            
   if ~istest,
       DrawFormattedText(w, 'Experiment is Over!', 'center', ycenter-100, white);
       rndTrialNumber = randi(nWhite+nBlack+nOther, [3,1]);
       behavior.actualPayoff = nansum(behavior.TOutcome(rndTrialNumber,3));
       DrawFormattedText(w, sprintf('Your payoff from the experiement is: $%2.2f !', behavior.actualPayoff), 'center', ycenter+50, white);
   else
       DrawFormattedText(w, 'Test Session is Over!', 'center', ycenter-100, white);
   end
  
   Screen('Flip',w); %display experiment over info
   
   if ~istest,
        save(subjectName, 'behavior');
   end

   KbWait;
   while KbCheck; end
   while 1;
       [keyIsDown, seconds, keyCode] = KbCheck;
       if (keyIsDown & size(find(keyCode), 2) == 1);
          break;
       end
   end
       
   fprintf('You pressed key %i which is %s\n and task is over', find(keyCode), KbName(keyCode));
   ListenChar(0); % restore keyboard response in Matlab command window
   Screen('CloseAll');
   
   
catch
    Screen('CloseAll');
    ShowCursor;
    ListenChar(0);% restore keyboard response in Matlab command window
    psychrethrow(psychlasterror);
   
end

