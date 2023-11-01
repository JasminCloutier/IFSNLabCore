function lct(subNo, MR)
    Screen('Preference', 'SkipSyncTests', 1);
    % ISI = 500ms +/- 200 ms (Gaussian distribution)
    % ITI = 1000 ms +/- 400 ms (Gaussian distribution)
    % Prime = 5s
    % Show choices (~3s)
    % Cue to make decision (at 3s, will remain on screen for 2s)
    % 3 min with countdown between blocks

    % MR = 0 is for 'non-scanning' version
    % MR = 1 is for 'scanning' version

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%% Preliminary checks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Clear Matlab/Octave window:
    clc;

    % check for Opengl compatibility, abort otherwise:
    AssertOpenGL;

    % Check if all needed parameters given:
    if nargin < 2
        error('Must provide required input parameters "subNo" and "MR"!');
    end

    % Reseed the random-number generator for each expt.
    rand('state',sum(100*clock));

    % Make sure keyboard mapping is the same on all supported operating systems
    % Apple MacOS/X, MS-Windows and GNU/Linux:
    KbName('UnifyKeyNames');

    % TTL signal from scanner
    MRTTL=KbName('5%');

    % Signals to be sent to biopac
    % biopac = 139;

    % Load in the sound to be played for biopac trigger
    [y,Fs] = audioread('testsound2.mp3');

    % Keyboard inputs
    keep=KbName('1!');      % left pie choice
    invest=KbName('2@');    % right pie choice

    advancetrial = KbName('space');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%% File handling
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    trialfilename = 'parameters_withambiguity.txt';                        % text list to read from
    datafilename = strcat('C:\Users\experiments\Desktop\LCT_runcopy\iTOI LCT Task Data\','lct_',num2str(subNo),'.dat'); % name of data file to write to

    % check for existing result file to prevent accidentally overwriting
    % files from a previous subject/session
    if (subNo<99999) && (fopen(datafilename, 'rt')~=-1)
        fclose('all');
        error('Result data file already exists! Choose a different subject number.');
    else
        datafilepointer = fopen(datafilename,'wt'); % open ASCII file for writing
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%% Experiment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    bankamt = 0;
    blocks = [1,2,3];  % 1 is neutral, 2 is threat 3 is disease
    nblocks = length(blocks);
    blocks=blocks(randperm(nblocks));  % shuffle the blocks

    nconditions = 4;
    nrepeats = 15;
    ntrials = nconditions * nrepeats;

    winamt_block=zeros(1,ntrials);                    % amount won for each trial in each block. cleared after each block is over
    winamt = zeros(1,nblocks);

    % Embed core of code in try ... catch statement. If anything goes wrong
    % inside the 'try' block (Matlab error), the 'catch' block is executed to
    % clean up, save results, close the onscreen window etc.
    try
        % Get screenNumber of stimulation display. We choose the display with
        % the maximum index, which is usually the right one, e.g., the external
        % display on a Laptop:
        screens=Screen('Screens');
        screenNumber=max(screens);

        % Hide the mouse cursor (ShowCursor is the antidote):
        HideCursor;

        % Create colors to be used:
        % gray=GrayIndex(screenNumber);
        % black=BlackIndex(screenNumber);
        % white=WhiteIndex(screenNumber);
        gray=[127  127  127];
        black=[0  0  0];
        white=[255  255  255];
        blue=[0   0  255];
        red=[191  0   0];
        green=[0  127  0];

        % Open a double buffered fullscreen window on the stimulation screen
        % 'screenNumber' and choose/draw a black background. 'window' is the handle
        % used to direct all drawing commands to that window - the "Name" of
        % the window. 'rect' is a rectangle defining the size of the window.

        [width, height]=Screen('WindowSize', screenNumber);
        res=[width height];
        clrdepth=32;
        [window,rect]=Screen('OpenWindow',screenNumber,0,[0 0 res(1) res(2)], clrdepth);    
        
        xcent = rect(3)/2;
        ycent = rect(4)/2;
        xsize = rect(3);
        ysize = rect(4);

        % write heading to file (subNo, round, etc.)
        
        % scale text size to window size
        txtsize = round(ysize/30);
        Screen('TextSize', window, txtsize);
        Screen('TextFont', window, 'Arial');

        % Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
        % they are loaded and ready when we need them - without delays
        % in the wrong moment:
        KbCheck;
        WaitSecs(0.1);
        GetSecs;

        % Set priority for script execution to realtime priority:
        priorityLevel=MaxPriority(window);
        Priority(priorityLevel);   

        % read list of stimulus information
        % endowment     ranging from $5-15
        % ambiguity     proportion of pie that needs to be gray
        % smallpie_amt  low repay
        % smallpie_prob probability of low repay
        % bigpie_amt    high repay
        % bigpie_prob   probability of high repay
        % type          1:social, 2: nonsocial, -1: socialcut, -2: nonsocialcut
        % condition     1: social unambiguous, 2: socialambiguous, 3: nonsocial unambiguous, 4: nonsocial ambiguous
        [endowment, ambiguity, smallpie_amt, smallpie_prob, bigpie_amt, bigpie_prob, type, condition] = textread(trialfilename,'%f %f %f %f %f %f %f %f');

        % Because we are using the same amounts and probabilities for 6
        % rounds (3 social, 3 nonsocial for each endowment level), we
        % use this method and the addition of 20 "cut" rounds to throw
        % off the participant so the numbers look more variable.
        % +- 20 cents variability (approximately 1 std, so that amounts are
        % slightly different across rounds to make them more believable)
        % dev = floor(3*rand(ntrials,1)-1) * 0.20;    % std = 0.24, -0.20, 0, +0.20 variability
        % smallpie_amt = smallpie_amt+dev;
        % bigpie_amt = bigpie_amt+dev;
        
        faces = randperm(ntrials);
        faces = transpose(faces);
        nonfaces = [1 2 3 4 5 6 7 8 9 10 11];
        nonfaces = repelem(nonfaces, 6);
        nonfaces = nonfaces(randperm(ntrials));
        nonfaces = transpose(nonfaces);

        % Create stim matrix to shuffle so that faces are always paired with the same info
        stim_matrix = [endowment, ambiguity, smallpie_amt, smallpie_prob, bigpie_amt, bigpie_prob, type, condition, faces, nonfaces];

        %%%%%%%%%%%%%%%%%%%%%%%%% Create psuedorandom array for block 1

        randind = randperm(ntrials);
        stim_matrix_block1 = stim_matrix(randind, : );

        condition = stim_matrix_block1(:,8);
        condition_new = zeros(3,length(condition));
        condition_new(1,:) = condition;
        
        for c = 1:length(condition)-2
            repeat_counter = 0;
            if (condition(c) == condition(c + 1)) && (condition(c + 1) == condition(c + 2))
                repeat_counter = repeat_counter + 1
                condition_new(2,c+2) = repeat_counter
            end;
        end;

        repeat_ind = find(condition_new(2,:) == 1);

        if length(repeat_ind) > 1
            repeat_ind_flipped = fliplr(repeat_ind);

            ind = 1;

            for c = 1:length(condition)
                if condition_new(2,c) == 0
                    condition_new(3,c) = c;
                else
                    condition_new(3,c) = repeat_ind_flipped(ind);
                    ind = ind+1;
                end;
            end;
        else
            for c = 1:length(condition)
                condition_new(3,c) = c;
            end;
        end;

        new_ind = condition_new(3,:);
        stim_matrix_block1 = stim_matrix_block1(new_ind, : );

        %%%%%%%%%%%%%%%%%%%%%%%%% Create psuedorandom array for block 2

        randind = randperm(ntrials);
        stim_matrix_block2 = stim_matrix(randind, : );

        condition = stim_matrix_block2(:,8);
        condition_new = zeros(3,length(condition));
        condition_new(1,:) = condition;
        
        for c = 1:length(condition)-2
            repeat_counter = 0;
            if (condition(c) == condition(c + 1)) && (condition(c + 1) == condition(c + 2))
                repeat_counter = repeat_counter + 1
                condition_new(2,c+2) = repeat_counter
            end;
        end;

        repeat_ind = find(condition_new(2,:) == 1);

        if length(repeat_ind) > 1
            repeat_ind_flipped = fliplr(repeat_ind);

            ind = 1;

            for c = 1:length(condition)
                if condition_new(2,c) == 0
                    condition_new(3,c) = c;
                else
                    condition_new(3,c) = repeat_ind_flipped(ind);
                    ind = ind+1;
                end;
            end;
        else
            for c = 1:length(condition)
                condition_new(3,c) = c;
            end;
        end;

        new_ind = condition_new(3,:);
        stim_matrix_block2 = stim_matrix_block2(new_ind, : );

        %%%%%%%%%%%%%%%%%%%%%%%%% Create psuedorandom array for block 1

        randind = randperm(ntrials);
        stim_matrix_block3 = stim_matrix(randind, : );

        condition = stim_matrix_block3(:,8);
        condition_new = zeros(3,length(condition));
        condition_new(1,:) = condition;
        
        for c = 1:length(condition)-2
            repeat_counter = 0;
            if (condition(c) == condition(c + 1)) && (condition(c + 1) == condition(c + 2))
                repeat_counter = repeat_counter + 1
                condition_new(2,c+2) = repeat_counter
            end;
        end;

        repeat_ind = find(condition_new(2,:) == 1);

        if length(repeat_ind) > 1
            repeat_ind_flipped = fliplr(repeat_ind);

            ind = 1;

            for c = 1:length(condition)
                if condition_new(2,c) == 0
                    condition_new(3,c) = c;
                else
                    condition_new(3,c) = repeat_ind_flipped(ind);
                    ind = ind+1;
                end;
            end;
        else
            for c = 1:length(condition)
                condition_new(3,c) = c;
            end;
        end;

        new_ind = condition_new(3,:);
        stim_matrix_block3 = stim_matrix_block3(new_ind, : );

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%% Instructions page
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % write message to subject
        if (MR==1)
            start_message = 'Remember, press LEFT to KEEP ENDOWMENT. \n\nPress RIGHT to INVEST. \n\nClick to continue.';
        elseif (MR==0)
            start_message = 'Remember, press 1 to KEEP ENDOWMENT. \n\nPress 2 to INVEST. \n\nClick to continue.';
        end
        
        % Write instruction message for subject, nicely centered in the
        % middle of the display, in white color.
        DrawFormattedText(window, start_message, 'center', 'center', white);

        % INSERT SOUND TRIGGER - INSTRUCTION ONSET
        sound(y,Fs);
        
        % Update the display to show the instruction text:
        [VBLinstr1 instr1rt instr1fliprt] = Screen('Flip', window);

        % Wait for mouse click:
        GetClicks(window);

        % INSERT SOUND TRIGGER - INSTRUCTION OFFSET
        sound(y,Fs);

        % GET TIME
        instr1endrt=GetSecs;
        
        % initialize KbCheck and variables to make sure they're properly initialized/allocted by Matlab to avoid time delays'
        [KeyIsDown, endrt, KeyCode]=KbCheck;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%% Initial Scan
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if (MR == 1)
            % while loop to wait for '5', indicating the MR scanner has saved the first image:
            while (GetSecs > 0)
                % poll for a resp
                if (KeyCode(MRTTL)==1)
                    break;
                end
                [KeyIsDown, endrt, KeyCode]=KbCheck;

                % Wait 1 ms before checking the keyboard again to prevent overload of the machine at elevated Priority():
                WaitSecs(0.002);

            end

            MRstartrt = endrt;
            fprintf(datafilepointer,'%s %i\n', 'MRstart', MRstartrt);
            % Wait 10 seconds before starting trial
            WaitSecs(2.000);

        else

            MRstartrt = -1;

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%% Instructions page
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if (MR == 1)
            relax_message = 'You can relax, but please do not move\n\nPress either button to begin.';
        elseif (MR==0)
            relax_message = 'You can relax, but please do not move\n\nPress either 1 or 2 to begin.';

        end

        % Write instruction message for subject, nicely centered in the middle of the display, in white color.
        DrawFormattedText(window, relax_message, 'center', 'center', white);

        % INSERT SOUND TRIGGER - INSTRUCTION TEXT ONSET
        sound(y,Fs);

        % Update the display to show the instruction text:
        [VBLinstr2 instr2rt instr2fliprt] = Screen('Flip', window);

        % Check for key press as long as screen has been shown for more than 0 seconds
        while GetSecs > 0
            % poll for a response
            if (KeyCode(keep)==1 || KeyCode(invest)==1)
                break;
            end
            [KeyIsDown, endrt, KeyCode]=KbCheck;

            % Wait 1 ms before checking the keyboard again to prevent
            % overload of the machine at elevated Priority():
            WaitSecs(0.002);
        end

        expstartrt = endrt;

        % Keep track of block number for end of block message
        block_number = 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%% Loop through blocks
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        for block=blocks % which prime block

            % create random array of primes to scroll through  
            primes = randperm(ntrials);    % 60 per priming condition (neutral, threat, disease)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%% Relax page
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            start_message = 'Please relax for a few minutes before the next block begins. \n\nYou will see a countdown before the next block begins.';
            
            % Write instruction message for subject, nicely centered in the
            % middle of the display, in white color.
            DrawFormattedText(window, start_message, 'center', 'center', white);

            % INSERT SOUND TRIGGER - INSTRUCTION ONSET
            sound(y,Fs);

            % Update the display to show screen:
            [VBLrest restrt restfliprt] = Screen('Flip', window);

            % Wait 2 minutes (120 seconds) before starting trial
            WaitSecs(120.000);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%% Countdown
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%% 10
            start_message = '10';
            DrawFormattedText(window, start_message, 'center', 'center', white);

            % INSERT SOUND TRIGGER - INSTRUCTION ONSET
            sound(y,Fs);

            % Update the display to show screen:
            [VBLcountdown10 countdown10rt countdown10fliprt] = Screen('Flip', window);

            % Wait 1 seconds before next number
            WaitSecs(1.000);
            
            %%%%%%%%%%%%%%%%%%%%%%%%% 9
            start_message = '9';
            DrawFormattedText(window, start_message, 'center', 'center', white);

            % INSERT SOUND TRIGGER - INSTRUCTION ONSET
            sound(y,Fs);

            % Update the display to show screen:
            [VBLcountdown9 countdown9rt countdown9fliprt] = Screen('Flip', window);

            % Wait 1 seconds before next number
            WaitSecs(1.000);
            
            %%%%%%%%%%%%%%%%%%%%%%%%% 8
            start_message = '8';
            DrawFormattedText(window, start_message, 'center', 'center', white);

            % INSERT SOUND TRIGGER - INSTRUCTION ONSET
            sound(y,Fs);

            % Update the display to show screen:
            [VBLcountdown8 countdown8rt countdown8fliprt] = Screen('Flip', window);

            % Wait 1 seconds before next number
            WaitSecs(1.000);
            
            %%%%%%%%%%%%%%%%%%%%%%%%% 7
            start_message = '7';
            DrawFormattedText(window, start_message, 'center', 'center', white);

            % INSERT SOUND TRIGGER - INSTRUCTION ONSET
            sound(y,Fs);

            % Update the display to show screen:
            [VBLcountdown7 countdown7rt countdown7fliprt] = Screen('Flip', window);

            % Wait 1 seconds before next number
            WaitSecs(1.000);
            
            %%%%%%%%%%%%%%%%%%%%%%%%% 6
            start_message = '6';
            DrawFormattedText(window, start_message, 'center', 'center', white);

            % INSERT SOUND TRIGGER - INSTRUCTION ONSET
            sound(y,Fs);

            % Update the display to show screen:
            [VBLcountdown6 countdown6rt countdown6fliprt] = Screen('Flip', window);

            % Wait 1 seconds before next number
            WaitSecs(1.000);
            
            %%%%%%%%%%%%%%%%%%%%%%%%% 5
            start_message = '5';
            DrawFormattedText(window, start_message, 'center', 'center', white);

            % INSERT SOUND TRIGGER - INSTRUCTION ONSET
            sound(y,Fs);

            % Update the display to show screen:
            [VBLcountdown5 countdown5rt countdown5fliprt] = Screen('Flip', window);

            % Wait 1 seconds before next number
            WaitSecs(1.000);
            
            %%%%%%%%%%%%%%%%%%%%%%%%% 4
            start_message = '4';
            DrawFormattedText(window, start_message, 'center', 'center', white);

            % INSERT SOUND TRIGGER - INSTRUCTION ONSET
            sound(y,Fs);

            % Update the display to show screen:
            [VBLcountdown4 countdown4rt countdown4fliprt] = Screen('Flip', window);

            % Wait 1 seconds before next number
            WaitSecs(1.000);
            
            %%%%%%%%%%%%%%%%%%%%%%%%% 3
            start_message = '3';
            DrawFormattedText(window, start_message, 'center', 'center', white);

            % INSERT SOUND TRIGGER - INSTRUCTION ONSET
            sound(y,Fs);

            % Update the display to show screen:
            [VBLcountdown3 countdown3rt countdown3fliprt] = Screen('Flip', window);

            % Wait 1 seconds before next number
            WaitSecs(1.000);
            
            %%%%%%%%%%%%%%%%%%%%%%%%% 2
            start_message = '2';
            DrawFormattedText(window, start_message, 'center', 'center', white);

            % INSERT SOUND TRIGGER - INSTRUCTION ONSET
            sound(y,Fs);

            % Update the display to show screen:
            [VBLcountdown2 countdown2rt countdown2fliprt] = Screen('Flip', window);

            % Wait 1 seconds before next number
            WaitSecs(1.000);
            
            %%%%%%%%%%%%%%%%%%%%%%%%% 1
            start_message = '1';
            DrawFormattedText(window, start_message, 'center', 'center', white);

            % INSERT SOUND TRIGGER - INSTRUCTION ONSET
            sound(y,Fs);

            % Update the display to show screen:
            [VBLcountdown1 countdown1rt countdown1fliprt] = Screen('Flip', window);

            % Wait 1 seconds before next number
            WaitSecs(1.000);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%% ITI
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            % Here we set the size of the arms of our fixation cross
            fixCrossDimPix = 40;
            % Set the line width for our fixation cross
            lineWidthPix = 4;

            % Now we set the coordinates (these are all relative to zero we will let the drawing routine center the cross in the center of our monitor for us)
            xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
            yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
            allCoords = [xCoords; yCoords];
            
            % Draw the fixation cross in white, set it to the center of our screen and set good quality antialiasing
            Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawLines', window, allCoords, lineWidthPix, white, [xcent ycent], 2);

            % INSERT SOUND TRIGGER - ITI ONSET
            sound(y,Fs);
            
            % Flip to the screen
            [VBLiti itirt itifliprt]=Screen('Flip', window);
            
            % Wait for 1000 ms +/- 400 ms
            WaitSecs(normrnd(1.000, 0.400));

            % Flip to blank screen
            [VBLitiend itiendrt itiendfliprt]=Screen('Flip', window);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%% Trials
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            for trial = 1:ntrials

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%% Set Stim Matrix
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%% Neutral block
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (block == 1) % Neutral
                    % separate stim matrix for this block into arrays
                    endowment = stim_matrix_block1(:,1)
                    ambiguity = stim_matrix_block1(:,2)
                    smallpie_amt = stim_matrix_block1(:,3)
                    smallpie_prob = stim_matrix_block1(:,4)
                    bigpie_amt = stim_matrix_block1(:,5)
                    bigpie_prob = stim_matrix_block1(:,6)
                    type = stim_matrix_block1(:,7)
                    faces = stim_matrix_block1(:,9)
                    nonfaces = stim_matrix_block1(:,10)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%% Threat block
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                elseif (block == 2) % Threat
                    % separate stim matrix for this block into arrays
                    endowment = stim_matrix_block2(:,1)
                    ambiguity = stim_matrix_block2(:,2)
                    smallpie_amt = stim_matrix_block2(:,3)
                    smallpie_prob = stim_matrix_block2(:,4)
                    bigpie_amt = stim_matrix_block2(:,5)
                    bigpie_prob = stim_matrix_block2(:,6)
                    type = stim_matrix_block2(:,7)
                    faces = stim_matrix_block2(:,9)
                    nonfaces = stim_matrix_block2(:,10)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%% Disease block
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                else % block == 3 % Disease
                    endowment = stim_matrix_block3(:,1)
                    ambiguity = stim_matrix_block3(:,2)
                    smallpie_amt = stim_matrix_block3(:,3)
                    smallpie_prob = stim_matrix_block3(:,4)
                    bigpie_amt = stim_matrix_block3(:,5)
                    bigpie_prob = stim_matrix_block3(:,6)
                    type = stim_matrix_block3(:,7)
                    faces = stim_matrix_block3(:,9)
                    nonfaces = stim_matrix_block3(:,10)
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%% Prime screen
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%% Neutral block
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (block == 1) % Neutral
                    % place primes   % need nprimes in each primes folder
                    primedata=imread(strcat('primes/neutral/prime',num2str(primes(trial)),'.jpg'));  % neutral primes
                    primetex=Screen('MakeTexture', window, primedata);
                    Screen('DrawTexture', window, primetex, [],[(xcent - xsize/6.5), (ycent - ysize/4), (xcent + xsize/6.5), (ycent + ysize/4)],0);
                    % INSERT SOUND TRIGGER - PRIME ONSET
                    sound(y,Fs);
                    [VBLprime primert primefliprt]=Screen('Flip', window);
                    WaitSecs(5.000);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%% Threat block
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                elseif (block == 2) % Threat
                    % place primes   % need nprimes in each primes folder
                    primedata=imread(strcat('primes/threat/prime',num2str(primes(trial)),'.jpg'));  % neutral primes
                    primetex=Screen('MakeTexture', window, primedata);
                    Screen('DrawTexture', window, primetex, [],[(xcent - xsize/6.5), (ycent - ysize/4), (xcent + xsize/6.5), (ycent + ysize/4)],0);
                    % INSERT SOUND TRIGGER - PRIME ONSET
                    sound(y,Fs);
                    [VBLprime primert primefliprt]=Screen('Flip', window);
                    WaitSecs(5.000);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%% Disease block
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                else % block == 3 % Disease
                    % place primes   % need nprimes in each primes folder
                    primedata=imread(strcat('primes/disease/prime',num2str(primes(trial)),'.jpg'));  % neutral primes
                    primetex=Screen('MakeTexture', window, primedata);
                    Screen('DrawTexture', window, primetex, [],[(xcent - xsize/6.5), (ycent - ysize/4), (xcent + xsize/6.5), (ycent + ysize/4)],0);
                    % INSERT SOUND TRIGGER - PRIME ONSET
                    sound(y,Fs);
                    [VBLprime primert primefliprt]=Screen('Flip', window);
                    WaitSecs(5.000);
                end
            
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%% ISI
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % Here we set the size of the arms of our fixation cross
                fixCrossDimPix = 40;
                % Set the line width for our fixation cross
                lineWidthPix = 4;

                % Now we set the coordinates (these are all relative to zero we will let the drawing routine center the cross in the center of our monitor for us)
                xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
                yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
                allCoords = [xCoords; yCoords];
                
                % Draw the fixation cross in white, set it to the center of our screen and set good quality antialiasing
                Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawLines', window, allCoords, lineWidthPix, white, [xcent ycent], 2);

                % INSERT SOUND TRIGGER - PRIME OFFSET, ISI ONSET
                sound(y,Fs);
                
                % Flip to the screen
                [VBLisi1 isi1rt isi1fliprt]=Screen('Flip', window);
                
                % Wait for 500 ms +/- 200 ms
                WaitSecs(normrnd(0.500, 0.200));

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%% Choice screen
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % initialize KbCheck and variables to make sure they're properly initialized/allocted by Matlab to avoid time delays'
                [KeyIsDown, endrt, KeyCode]=KbCheck;
                smallpie_probability = smallpie_prob(trial);
                bigpie_probability = bigpie_prob(trial);
                % xsize = 1440
                % ysize = 900
                % xsize/3 = 480 = xsize*0.33
                % ysize/6 = 150 = ysize*0.17
                % xsize/3 - ysize/6 = 330 = xsize*0.23
                % xsize/3 + ysize/6 = 630 = xsize*0.44
                % ysize*2/3 = 600 = ysize*0.67
                % ysize*2/3 - ysize/6 = 450 = ysize*0.5
                % ysize*2/3 + ysize/6 = 750 = ysize*0.83
                % xsize*2/3 = 960 = xsize*0.67
                % xsize*2/3 - ysize/6 = 810 = xsize*0.56
                % xsize*2/3 + ysize/6 = 1110 = xsize*0.77

                % draw left pie (sure choice)
                Screen('FillArc',  window, red,[(xsize*0.23) (ysize*0.5) (xsize*0.44) (ysize*0.83)],0,360);
                Screen('FrameArc', window, white,[(xsize*0.23) (ysize*0.5) (xsize*0.44) (ysize*0.83)],0,360,ysize/100,ysize/100);
                
                % draw left pie amount
                str=sprintf(['KEEP\n$' num2str(endowment(trial),'%.2f')]); 
                DrawFormattedText(window, str, (xsize/3.15)-(ysize/30), (ysize*(2/3))-(ysize/24), white);

                % draw right pie  (risky choice)
                if (ambiguity(trial) == 0) % no ambiguity
                    % smallpie
                    Screen('FillArc',  window, red,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],-(smallpie_probability*360/2),smallpie_probability*360);
                    Screen('FrameArc', window, white,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],-(smallpie_probability*360/2),smallpie_probability*360,ysize/100,ysize/100);
                    % bigpie
                    Screen('FillArc', window, blue,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],(smallpie_probability*360/2),bigpie_probability*360);
                    Screen('FrameArc', window, white,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],(smallpie_probability*360/2),bigpie_probability*360,ysize/100,ysize/100);
                    
                else % certain amount of ambiguity
                    ambiguity_proportion = ambiguity(trial); % 60% ambiguity in this case, but makes it flexible for future use cases
                    % smallpie
                    Screen('FillArc',  window, red,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],-(smallpie_probability*360/2),smallpie_probability*360);
                    Screen('FrameArc', window, white,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],-(smallpie_probability*360/2),smallpie_probability*360,ysize/100,ysize/100);
                    % bigpie
                    Screen('FillArc', window, blue,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],(smallpie_probability*360/2),bigpie_probability*360);
                    Screen('FrameArc', window, white,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],(smallpie_probability*360/2),bigpie_probability*360,ysize/100,ysize/100);
                    % ambiguous pie
                    Screen('FillArc', window, gray,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],(smallpie_probability*360/4),ambiguity_proportion*360); 
                    Screen('FrameArc', window, white,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],(smallpie_probability*360/4),ambiguity_proportion*360,ysize/100,ysize/100);
                end

                % draw right pie amount
                if (type(trial) == 1 || type(trial) == -1)  % social (put face)
                    repay_message = 'REPAY\n$';

                elseif (type(trial) == 2 || type(trial) == -2)  % non-social (put neutral non-face lottery)
                    repay_message = '*WIN*\n$';
                end
                if (ambiguity(trial) == 0) % no ambiguity
                    % smallpie
                    str=sprintf([repay_message num2str(smallpie_amt(trial), '%.2f')]);
                    DrawFormattedText(window, str, (xsize*(2/3.1))-(ysize/30), (ysize*(2/3))-(ysize/6)+(ysize/25), white);
                    % bigpie
                    str=sprintf([repay_message num2str(bigpie_amt(trial), '%.2f')]);
                    DrawFormattedText(window, str, (xsize*(2/3.1))-(ysize/30), (ysize*(2/3))+(ysize/50), white);
                else % certain amount of ambiguity
                    % smallpie
                    str=sprintf([repay_message num2str(smallpie_amt(trial), '%.2f')]);
                    DrawFormattedText(window, str, (xsize*0.62), (ysize*0.57), white); 
                    % bigpie
                    str=sprintf([repay_message num2str(bigpie_amt(trial), '%.2f')]);
                    DrawFormattedText(window, str, (xsize*0.58), (ysize*0.65), white);
                end

                % draw initial dot
                Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawDots', window, [0 0], ysize/100, white, [((ysize/6)-((ysize/100)/2))*cos(1.5*pi)+(xsize*(2/3)) ((ysize/6)-((ysize/100)/2))*sin(1.5*pi)+(ysize*(2/3))], 1);

                % draw own face
                ownface = 'YOU';
                DrawFormattedText(window, ownface, (xsize/2.7)-(ysize/8), (ysize/2.2)-(ysize/6)-(ysize/30), white);
                
                % draw partner face
                if (type(trial) == 1 || type(trial) == -1)  % social (put face)
                    % initialize social face
                    face2data=imread(strcat('faces/face',num2str(faces(trial)),'.jpg'));
                    facetex2=Screen('MakeTexture', window, face2data);
                    Screen('DrawTexture', window, facetex2, [], [(xsize*(2/2.85))-(ysize/4.5) (ysize/2.2)-(ysize/6)-(ysize/30) (xsize*(2/3))+(ysize/8) (ysize/3)+(ysize/6)-(ysize/30)]);
                elseif (type(trial) == 2 || type(trial) == -2)  % non-social (put neutral non-face lottery)
                    % initialize nonface
                    nonfacedata=imread(strcat('faces/nonface',num2str(nonfaces(trial)),'.png'));
                    nonface=Screen('MakeTexture', window, nonfacedata);
                    Screen('DrawTexture', window, nonface, [], [(xsize*(2/2.85))-(ysize/4.5) (ysize/2.2)-(ysize/6)-(ysize/30) (xsize*(2/3))+(ysize/8) (ysize/3)+(ysize/6)-(ysize/30)]);
                end

                % INSERT SOUND TRIGGER - GAMBLE ONSET
                sound(y,Fs);
                
                % Display gamble
                [VBLchoice choicert choicefliprt]=Screen('Flip', window, 0, 1);
                WaitSecs(1.000);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%% Decision screen
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % give go signal
                DrawFormattedText(window, 'KEEP OR INVEST?', 'center', ysize/5.5, white);

                % INSERT SOUND TRIGGER - SIGNAL ONSET
                sound(y,Fs);

                % Display screen
                [VBLmakedecision makedecisionrt makedecisionfliprt]=Screen('Flip', window);

                % Display prompt screen for up to 2s (or response, whichever is sooner):
                % while loop to show stimulus until subjects response or until
                % "duration" seconds elapsed.
                resp = 0;
                while (GetSecs - makedecisionrt <= 3.000) % sets response window duration
                    % poll for a resp
                    if KeyCode(keep)==1
                        resp = 1;
                        break;
                    elseif KeyCode(invest)==1
                        resp = 2;
                        break;
                    end
                    [KeyIsDown, endrt, KeyCode]=KbCheck;

                    % Wait 2 ms before checking the keyboard again to prevent overload of the machine at elevated Priority():
                    WaitSecs(0.002);
                end
                resprt = endrt;

                % if no response in alloted time, set rt = -1
                if (resp == 0)
                    resprt = -1;
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%% Waiting for outcome screen
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                if (resp == 1)

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%% ISI
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    % Here we set the size of the arms of our fixation cross
                    fixCrossDimPix = 40;
                    % Set the line width for our fixation cross
                    lineWidthPix = 4;

                    % Now we set the coordinates (these are all relative to zero we will let the drawing routine center the cross in the center of our monitor for us)
                    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
                    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
                    allCoords = [xCoords; yCoords];
                    
                    % Draw the fixation cross in white, set it to the center of our screen and set good quality antialiasing
                    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    Screen('DrawLines', window, allCoords, lineWidthPix, white, [xcent ycent], 2);

                    % INSERT SOUND TRIGGER - ISI
                    sound(y,Fs);
                    
                    % Flip to the screen
                    [VBLisi2 isi2rt isi2fliprt]=Screen('Flip', window);
                    
                    % Wait for 500 ms +/- 200 ms
                    WaitSecs(normrnd(0.500, 0.200));

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%% Outcome
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    % Update amount won and amount banked
                    winamt_block(trial) = endowment(trial);
                    bankamt = bankamt + winamt_block(trial);

                    DrawFormattedText(window, 'YOU KEPT YOUR ENDOWMENT.', 'center', ysize/5.5, white);
                    % draw left pie (sure choice)
                    Screen('FillArc',  window, red,[(xsize*0.23) (ysize*0.5) (xsize*0.44) (ysize*0.83)],0,360);
                    Screen('FrameArc', window, white,[(xsize*0.23) (ysize*0.5) (xsize*0.44) (ysize*0.83)],0,360,ysize/100,ysize/100);
                    % draw left pie amount
                    str=sprintf(['KEEP\n$' num2str(endowment(trial),'%.2f')]);
                    DrawFormattedText(window, str, (xsize/3.15)-(ysize/30), (ysize*(2/3))-(ysize/24), white);

                    % INSERT SOUND TRIGGER - OUTCOME ONSET
                    sound(y,Fs);
                    
                    % Update the display to show no decision made:
                    [VBLdecision decisionrt decisionfliprt]=Screen('Flip', window);
                    % Display screen for 2s
                    WaitSecs(2.000);

                elseif (resp == 2)

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%% ISI
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    % Here we set the size of the arms of our fixation cross
                    fixCrossDimPix = 40;
                    % Set the line width for our fixation cross
                    lineWidthPix = 4;

                    % Now we set the coordinates (these are all relative to zero we will let the drawing routine center the cross in the center of our monitor for us)
                    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
                    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
                    allCoords = [xCoords; yCoords];
                    
                    % Draw the fixation cross in white, set it to the center of our screen and set good quality antialiasing
                    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    Screen('DrawLines', window, allCoords, lineWidthPix, white, [xcent ycent], 2);

                    % INSERT SOUND TRIGGER - ISI ONSET
                    sound(y,Fs);
                    
                    % Flip to the screen
                    [VBLisi2 isi2rt isi2fliprt]=Screen('Flip', window);
                    
                    % Wait for 500 ms +/- 200 ms
                    WaitSecs(normrnd(0.500, 0.200));

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%% Outcome
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    % Update amount won and amount banked
                    dotdeg = rand()*2*pi;
                    if (dotdeg >= 1.5*pi - (smallpie_prob(trial)*360/2)*(pi/180)) && (dotdeg < 1.5*pi + (smallpie_prob(trial)*360/2)*(pi/180))
                        % draw smallpie amount
                        winamt_block(trial) = smallpie_amt(trial);
                        bankamt = bankamt + winamt_block(trial);
                    else
                        % draw bigpie amount
                        winamt_block(trial) = bigpie_amt(trial);
                        bankamt = bankamt + winamt_block(trial);
                    end

                    % draw partner face
                    if (type(trial) == 1 || type(trial) == -1)  % social (put face)
                        Screen('DrawTexture', window, facetex2, [], [(xsize*(2/2.85))-(ysize/4.5) (ysize/2.2)-(ysize/6)-(ysize/30) (xsize*(2/3))+(ysize/8) (ysize/3)+(ysize/6)-(ysize/30)]);
                        repay_message = 'REPAY\n$';

                    elseif (type(trial) == 2 || type(trial) == -2)  % non-social (put neutral non-face lottery)
                        Screen('DrawTexture', window, nonface, [], [(xsize*(2/2.85))-(ysize/4.5) (ysize/2.2)-(ysize/6)-(ysize/30) (xsize*(2/3))+(ysize/8) (ysize/3)+(ysize/6)-(ysize/30)]);
                        repay_message = '*WIN*\n$';
                    
                    end

                    % draw right pie  (risk choice)                    
                    % smallpie
                    Screen('FillArc',  window, red,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],-(smallpie_prob(trial)*360/2),smallpie_prob(trial)*360);
                    Screen('FrameArc', window, white,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],-(smallpie_prob(trial)*360/2),smallpie_prob(trial)*360,ysize/100,ysize/100);
                    % bigpie
                    Screen('FillArc', window, blue,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],(smallpie_prob(trial)*360/2),bigpie_prob(trial)*360);
                    Screen('FrameArc', window, white,[(xsize*0.56) (ysize*0.5) (xsize*0.77) (ysize*0.83)],(smallpie_prob(trial)*360/2),bigpie_prob(trial)*360,ysize/100,ysize/100);
                    DrawFormattedText(window, 'YOU INVESTED.', 'center', ysize/5.5, white);
                    
                    % draw right pie amount
                    % smallpie
                    str=sprintf([repay_message num2str(smallpie_amt(trial), '%.2f')]);
                    DrawFormattedText(window, str, (xsize*(2/3.1))-(ysize/30), (ysize*(2/3))-(ysize/6)+(ysize/25), white);
                    % bigpie
                    str=sprintf([repay_message num2str(bigpie_amt(trial), '%.2f')]);
                    DrawFormattedText(window, str, (xsize*(2/3.1))-(ysize/30), (ysize*(2/3))+(ysize/50), white);

                    % INSERT SOUND TRIGGER - OUTCOME ONSET
                    sound(y,Fs);

                    % Go to next screen
                    [VBLdecision decisionrt decisionfliprt]=Screen('Flip', window);
                    % Display screen for 2s
                    WaitSecs(2.000);
                
                else

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%% No ISI !!!
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    isi2rt = -1;
                    VBLisi2 = -1;
                    isi2fliprt = -1;

                    DrawFormattedText(window, 'TOO LATE! NO DECISION MADE!', 'center', ysize/5.5, white);

                    % INSERT SOUND TRIGGER - OUTCOME ONSET
                    sound(y,Fs);

                    % Update the display to show no decision made:
                    [VBLdecision decisionrt decisionfliprt]=Screen('Flip', window);
                    % Display screen for 2s
                    WaitSecs(2.000);

                end

                [VBLtrialend trialendrt trialendfliprt] = Screen('Flip', window);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%% ITI
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
                % Here we set the size of the arms of our fixation cross
                fixCrossDimPix = 40;
                % Set the line width for our fixation cross
                lineWidthPix = 4;

                % Now we set the coordinates (these are all relative to zero we will let the drawing routine center the cross in the center of our monitor for us)
                xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
                yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
                allCoords = [xCoords; yCoords];
                
                % Draw the fixation cross in white, set it to the center of our screen and set good quality antialiasing
                Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawLines', window, allCoords, lineWidthPix, white, [xcent ycent], 2);

                % INSERT SOUND TRIGGER - ITI ONSET
                sound(y,Fs);
                
                % Flip to the screen
                [VBLiti2 iti2rt iti2fliprt]=Screen('Flip', window);
                
                % Wait for 1000 ms +/- 400 ms
                WaitSecs(normrnd(1.000, 0.400));

                % Flip to blank screen
                [VBLiti2end iti2endrt iti2endfliprt]=Screen('Flip', window);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%% Calculate length of time for important pages
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                primeduration = isi1rt - primert;
                isi1duration = choicert - primert;
                gambleduration = makedecisionrt - choicert;
                decisionduration = 0;
                if (resp == 1) || (resp == 2)
                    decisionduration = isi2rt - makedecisionrt;
                else
                    decisionduration = decisionrt - makedecisionrt;
                end
                itiduration = itiendrt - itirt;
                iti2duration = iti2endrt = iti2rt;


                % write to file (save data)
                fprintf(datafilepointer, '%i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i\n', ...
                    subNo, ...
                    trial, ...
                    endowment(trial), ...
                    ambiguity(trial), ...
                    smallpie_amt(trial), ...
                    smallpie_prob(trial), ...
                    bigpie_amt(trial), ...
                    bigpie_prob(trial), ...
                    type(trial), ...
                    winamt_block(trial), ...
                    primes(trial), ...
                    faces(trial), ...
                    nonfaces(trial), ...
                    instr1rt, ...
                    VBLinstr1, ...
                    instr1fliprt, ...
                    instr1endrt, ...
                    instr2rt, ...
                    VBLinstr2, ...
                    instr2fliprt, ...
                    restrt, ...
                    VBLrest, ...
                    restfliprt, ...
                    countdown10rt, ...
                    VBLcountdown10, ...
                    countdown10fliprt, ...
                    countdown9rt, ...
                    VBLcountdown9, ...
                    countdown9fliprt, ...
                    countdown8rt, ...
                    VBLcountdown8, ...
                    countdown8fliprt, ...
                    countdown7rt, ...
                    VBLcountdown7, ...
                    countdown7fliprt, ...
                    countdown6rt, ...
                    VBLcountdown6, ...
                    countdown6fliprt, ...
                    countdown5rt, ...
                    VBLcountdown5, ...
                    countdown5fliprt, ...
                    countdown4rt, ...
                    VBLcountdown4, ...
                    countdown4fliprt, ...
                    countdown3rt, ...
                    VBLcountdown3, ...
                    countdown3fliprt, ...
                    countdown2rt, ...
                    VBLcountdown2, ...
                    countdown2fliprt, ...
                    countdown1rt, ...
                    VBLcountdown1, ...
                    countdown1fliprt, ...
                    itirt, ...
                    VBLiti, ...
                    itifliprt, ...
                    itiendrt, ...
                    VBLitiend, ...
                    itiendfliprt, ...
                    primert, ...
                    VBLprime, ...
                    primefliprt, ...
                    isi1rt, ...
                    VBLisi1, ...
                    isi1fliprt, ...
                    choicert, ...
                    VBLchoice, ...
                    choicefliprt, ...
                    makedecisionrt, ...
                    VBLmakedecision, ...
                    makedecisionfliprt, ...
                    isi2rt, ...
                    VBLisi2, ...
                    isi2fliprt, ...
                    decisionrt, ...
                    VBLdecision, ...
                    decisionfliprt, ...
                    resp, ...               % 1 for keep, 2 for invest, 0 no choice
                    resprt, ...
                    trialendrt, ...
                    VBLtrialend, ...
                    trialendfliprt, ...
                    VBLiti2end, ...
                    iti2rt, ...
                    iti2fliprt, ...
                    VBLiti2end, ...
                    iti2rt, ...
                    iti2endfliprt, ...
                    iti2duration, ...
                    primeduration, ...
                    isi1duration, ...
                    gambleduration, ...
                    decisionduration, ...
                    itiduration);

                SubData(trial).subNo = subNo;
                SubData(trial).trial = trial;
                SubData(trial).endowment = endowment(trial);
                SubData(trial).ambiguity = ambiguity(trial);
                SubData(trial).smallpie_amt = smallpie_amt(trial);
                SubData(trial).smallpie_prob = smallpie_prob(trial);
                SubData(trial).bigpie_amt = bigpie_amt(trial);
                SubData(trial).bigpie_prob = bigpie_prob(trial);
                SubData(trial).type = type(trial);
                SubData(trial).winamt_block = winamt_block(trial);
                SubData(trial).primes = primes(trial); 
                SubData(trial).faces = faces(trial);
                SubData(trial).nonfaces = nonfaces(trial);
                SubData(trial).instr1rt = instr1rt;
                SubData(trial).VBLinstr1 = VBLinstr1;
                SubData(trial).instr1fliprt = instr1fliprt;
                SubData(trial).instr1endrt = instr1endrt;
                SubData(trial).instr2rt = instr2rt;
                SubData(trial).VBLinstr2 = VBLinstr2;
                SubData(trial).instr2fliprt = instr2fliprt;
                SubData(trial).restrt = restrt;
                SubData(trial).VBLrest = VBLrest;
                SubData(trial).restfliprt = restfliprt;
                SubData(trial).countdown10rt = countdown10rt;
                SubData(trial).VBLcountdown10 = VBLcountdown10;
                SubData(trial).countdown10fliprt = countdown10fliprt;
                SubData(trial).countdown9rt = countdown9rt;
                SubData(trial).VBLcountdown9 = VBLcountdown9;
                SubData(trial).countdown9fliprt = countdown9fliprt;
                SubData(trial).countdown8rt = countdown8rt;
                SubData(trial).VBLcountdown8 = VBLcountdown8;
                SubData(trial).countdown8fliprt = countdown8fliprt;
                SubData(trial).countdown7rt = countdown7rt;
                SubData(trial).VBLcountdown7 = VBLcountdown7;
                SubData(trial).countdown7fliprt = countdown7fliprt;
                SubData(trial).countdown6rt = countdown6rt;
                SubData(trial).VBLcountdown6 = VBLcountdown6;
                SubData(trial).countdown6fliprt = countdown6fliprt;
                SubData(trial).countdown5rt = countdown5rt;
                SubData(trial).VBLcountdown5 = VBLcountdown5;
                SubData(trial).countdown5fliprt = countdown5fliprt;
                SubData(trial).countdown4rt = countdown4rt;
                SubData(trial).VBLcountdown4 = VBLcountdown4;
                SubData(trial).countdown4fliprt = countdown4fliprt;
                SubData(trial).countdown3rt = countdown3rt;
                SubData(trial).VBLcountdown3 = VBLcountdown3;
                SubData(trial).countdown3fliprt = countdown3fliprt;
                SubData(trial).countdown2rt = countdown2rt;
                SubData(trial).VBLcountdown2 = VBLcountdown2;
                SubData(trial).countdown2fliprt = countdown2fliprt;
                SubData(trial).countdown1rt = countdown1rt;
                SubData(trial).VBLcountdown1 = VBLcountdown1;
                SubData(trial).countdown1fliprt = countdown1fliprt;
                SubData(trial).primert = primert;
                SubData(trial).VBLprime = VBLprime;
                SubData(trial).primefliprt = primefliprt;
                SubData(trial).isi1rt = isi1rt;
                SubData(trial).VBLisi1 = VBLisi1;
                SubData(trial).isi1fliprt = isi1fliprt;
                SubData(trial).choicert = choicert;
                SubData(trial).VBLchoice = VBLchoice;
                SubData(trial).choicefliprt = choicefliprt;
                SubData(trial).makedecisionrt = makedecisionrt;
                SubData(trial).VBLmakedecision = VBLmakedecision;
                SubData(trial).makedecisionfliprt = makedecisionfliprt;
                SubData(trial).isi2rt = isi2rt;
                SubData(trial).VBLisi2 = VBLisi2;
                SubData(trial).isi2fliprt = isi2fliprt;
                SubData(trial).decisionrt = decisionrt;
                SubData(trial).VBLdecision = VBLdecision;
                SubData(trial).decisionfliprt = decisionfliprt;
                SubData(trial).resp = resp;
                SubData(trial).resprt = resprt;
                SubData(trial).trialendrt = trialendrt;
                SubData(trial).VBLtrialend = VBLtrialend;
                SubData(trial).trialendfliprt = trialendfliprt;
                SubData(trial).itirt = itirt;
                SubData(trial).VBLiti = VBLiti;
                SubData(trial).itifliprt = itifliprt;
                SubData(trial).itiendrt = itiendrt;
                SubData(trial).VBLitiend = VBLitiend;
                SubData(trial).itiendfliprt = itiendfliprt;
                SubData(trial).primeduration = primeduration;
                SubData(trial).isi1duration = isi1duration;
                SubData(trial).gambleduration = gambleduration;
                SubData(trial).decisionduration = decisionduration;
                SubData(trial).itiduration = itiduration;

                save(['C:\Users\experiments\Desktop\LCT_runcopy\iTOI LCT Task Data\','lct_', num2str(subNo), '_', num2str(block), '.mat'],'SubData','MRstartrt');

            end % end for trial=1:ntrials
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%% Payoff screen
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            wonamt = randsample(winamt_block,1);
            winamt(block_number) = wonamt;
            str = sprintf(['This is the end of block ', num2str(block_number), ' of 3.\n\nYour randomly-selected payoff for this block is: $' num2str(wonamt,'%.2f')]);
            DrawFormattedText(window, str, 'center', 'center', white);

            % INSERT SOUND TRIGGER - BLOCK PAYOFF ONSET
            sound(y,Fs);

            % display block payoff
            [VBLoutcome outcomert outcomefliprt]=Screen('Flip', window)
            fprintf(datafilepointer,'%s %i\n', 'outcomert', outcomert);
            
            % display results for 2s
            WaitSecs(2.000);

            % INSERT SOUND TRIGGER - BLOCK OFFSET
            sound(y,Fs);
            
            % show blank screen
            [VBLblockend blockendrt blockendfliprt] = Screen('Flip', window)
            fprintf(datafilepointer,'%s %i\n', 'blockendrt', blockendrt);

            BlockData(block_number).outcomert = outcomert;
            BlockData(block_number).VBLoutcome = VBLoutcome;
            BlockData(block_number).outcomefliprt = outcomefliprt;
            BlockData(block_number).blockendrt = blockendrt;
            BlockData(block_number).VBLblockend = VBLblockend;
            BlockData(block_number).blockendfliprt = blockendfliprt;
            BlockData(block_number).winamt = wonamt;
            BlockData(block_number).block = block;

            save(['C:\Users\experiments\Desktop\LCT_runcopy\iTOI LCT Task Data\','lct_', num2str(subNo), '_BlockData', '.mat'],'BlockData');

            % update counters
            winamt_block=zeros(1,ntrials);
            block_number = block_number + 1
        
        end % end of for block=blocks

        Screen('Close');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%% Final screen
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        payoff = randsample(winamt,1);
        str=sprintf(['Experiment Complete.\n\nYour randomly-selected reward for this experiment is: $', num2str(payoff,'%.2f')]); 
        DrawFormattedText(window, str, 'center', 'center', white);

        % INSERT SOUND TRIGGER - BONUS ONSET
        sound(y,Fs);
        
        % display bonus
        [VBLbonus bonusrt bonusfliprt] = Screen('Flip', window);
        fprintf(datafilepointer,'%s %i\n', 'bonusrt', bonusrt);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%% Last scan
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if (MR == 1)
            last_scan = GetSecs;
            while (GetSecs - last_scan < 4.000)
                % poll for a resp
                if (KeyCode(MRTTL)==1)
                    last_scan = GetSecs;
                end
                [KeyIsDown, endrt, KeyCode]=KbCheck;
                % Wait 2 ms before checking the keyboard again to prevent
                % overload of the machine at elevated Priority():
                WaitSecs(0.002);
            end
            MRendrt = endrt;
            fprintf(datafilepointer,'%s %i\n', 'MRend', MRendrt);
            save(['C:\Users\experiments\Desktop\LCT_runcopy\iTOI LCT Task Data\','lct_' num2str(subNo) '.mat'], 'SubData','MRstartrt','MRendrt');
        else
            MRendrt = -1
            WaitSecs(4.000);
        end

        ExpData(1).expstartrt = expstartrt;
        ExpData(1).bonusrt = bonusrt;
        ExpData(1).VBLbonus = VBLbonus;
        ExpData(1).bonusfliprt = bonusfliprt;
        ExpData(1).MRendrt = MRendrt;

        save(['C:\Users\experiments\Desktop\LCT_runcopy\iTOI LCT Task Data\','lct_', num2str(subNo), '_ExpData', '.mat'],'ExpData');
        
        % Cleanup at end of experiment - Close window, show mouse cursor, close
        % result file, switch Matlab/Octave back to priority 0 -- normal
        % priority:
        Screen('CloseAll');
        ShowCursor;
        fclose('all');
        Priority(0);
        
        % INSERT SOUND/TRIGGER - END EXPERIMENT
        sound(y,Fs);

        % End of experiment
        return;
        
    catch 
        
        % Cleanup at end of experiment - Close window, show mouse cursor, close
        % result file, switch Matlab/Octave back to priority 0 -- normal
        % priority:
        Screen('CloseAll');
        ShowCursor;
        fclose('all');
        Priority(0);
        
        % Output the error message that describes the error:
        psychrethrow(psychlasterror);
        
    end

Screen('CloseAll');
    
    
