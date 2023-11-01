#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy3 Experiment Builder (v2021.1.4),
    on Fri Jun 11 03:46:02 2021
If you publish work using this script the most relevant publication is:

    Peirce J, Gray JR, Simpson S, MacAskill M, Höchenberger R, Sogo H, Kastman E, Lindeløv JK. (2019) 
        PsychoPy2: Experiments in behavior made easy Behav Res 51: 195. 
        https://doi.org/10.3758/s13428-018-01193-y

"""

###############################################################################################
############################################ SETUP ############################################
###############################################################################################

# --- Import packages ---
from psychopy import locale_setup
from psychopy import prefs
from psychopy import sound, gui, visual, core, data, event, logging, clock, colors, layout
from psychopy.constants import (NOT_STARTED, STARTED, PLAYING, PAUSED,
                                STOPPED, FINISHED, PRESSED, RELEASED, FOREVER)
import psychopy.iohub as io
from psychopy.hardware import keyboard

import pandas as pd # whole pandas lib is available, prepend 'pd.'
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import (sin, cos, tan, log, log10, pi, average,
                   sqrt, std, deg2rad, rad2deg, linspace, asarray)
from numpy.random import random, randint, normal, shuffle, choice as randchoice

import os  # handy system and path functions
import sys  # to get file system encoding
import re

# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)

# Store info about the experiment session
psychopyVersion = '2022.2.4'
expName = 'LCT'  # from the Builder filename that created this script
participants_list = list(np.arange(1,129))
participants_list.append('test')

expInfo = {
    'Participant': participants_list, 
    'Simultaneous/fMRI/EEG/Behavioral?': ['Simultaneous', 'fMRI', 'EEG', 'Behavioral']
}
dlg = gui.DlgFromDict(dictionary=expInfo, sortKeys=False, title=expName)
if dlg.OK == False:
    core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr(format="%Y-%m-%d_%H-%M", fractionalSecondDigits=0)  # add a simple timestamp
expInfo['expName'] = expName
expInfo['psychopyVersion'] = psychopyVersion

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
filename = _thisDir + os.sep + u'data/ARL2_%s_%s' % (expInfo['Participant'], expInfo['date'])
scriptname = _thisDir + os.sep + os.path.basename(__file__)

# An ExperimentHandler isn't essential but helps with data saving
thisExp = data.ExperimentHandler(
    name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath=scriptname,
    savePickle=True, saveWideText=True,
    dataFileName=filename)
# save a log file for detail verbose info
logFile = logging.LogFile(filename+'.log', level=logging.DEBUG)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

endExpNow = False  # flag for 'escape' or other condition => quit the exp
frameTolerance = 0.001  # how close to onset before 'same' frame

# Setup the Window
win = visual.Window(
    size=[1920, 1080], fullscr=True, screen=0, 
    winType='pyglet', allowGUI=False, allowStencil=False,
    monitor='testMonitor', color=[1,1,1], colorSpace='rgb',
    blendMode='avg', useFBO=True, 
    units='height')

win.recordFrameIntervals=True
# store frame rate of monitor if we can measure it
expInfo['frameRate'] = win.getActualFrameRate()
if expInfo['frameRate'] != None:
    frameDur = 1.0 / round(expInfo['frameRate'])
else:
    frameDur = 1.0 / 60.0  # could not measure, so guess

# store frame duration of monitor
expInfo['frameDur'] = frameDur

# create a default keyboard (e.g. to check for escape)
defaultKeyboard = keyboard.Keyboard()

# save TR as object to calculate post-run padding
tr = 2.45

# create flags
if expInfo['Simultaneous/fMRI/EEG/Behavioral?'] == 'Simultaneous':
    fMRIflag=1
    EEGflag=1
elif expInfo['Simultaneous/fMRI/EEG/Behavioral?'] == 'fMRI':
    fMRIflag=1
    EEGflag=0
elif expInfo['Simultaneous/fMRI/EEG/Behavioral?'] == 'EEG':
    fMRIflag=0
    EEGflag=1
elif expInfo['Simultaneous/fMRI/EEG/Behavioral?'] == 'Behavioral':
    fMRIflag=0
    EEGflag=0
    
if EEGflag == 1:
    import serial
    import time
    port = serial.Serial("COM4")

df_run1 = f"df/df_{expInfo['Participant']}_1.csv"
df_run2 = f"df/df_{expInfo['Participant']}_2.csv"
results = [] # list to save results from each trial

####################################################################################################
############################################ INITIALIZE ############################################
####################################################################################################

##################################
########## INSTRUCTIONS ##########
##################################

# Initialize components for Routine "Instructions"
Instr_Txt = visual.TextStim(
    win=win, name='Instr_Txt',
    text='Now you will play 88 rounds of the Lottery Choice Task with 44 unique players.\n\nPress any key to continue', font='Open Sans', languageStyle='LTR',
    pos=(0, 0), height=0.05, wrapWidth=1.0, ori=0.0, 
    color='black', colorSpace='rgb', opacity=1, depth=0.0);
Instr_Key = keyboard.Keyboard()

######################################
########## WAIT FOR SCANNER ##########
######################################

# Initialize components for Routine "WaitForScanner"
WaitForScanner_Txt = visual.TextStim(
    win=win, name='WaitForScanner_Txt',
    text='Waiting for scanner...', font='Open Sans',
    pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
    color='black', colorSpace='rgb', opacity=None, 
    languageStyle='LTR', depth=0.0);
WaitForScanner_Key = keyboard.Keyboard()

############################
########## JITTER ##########
############################

jitter = visual.TextStim(
    win=win, name='jitter',
    text='+', font='Open Sans', height=0.3, color='black', colorSpace='rgb', languageStyle='LTR',
    opacity=1, depth=0.0, pos=(0, 0), ori=0.0, 
    wrapWidth=None);

############################
########## CHOICE ##########
############################
df = pd.read_csv(df_run1)
endowment_list = df["Endowment"].drop_duplicates().tolist()
you_dict = {}
for endowment in endowment_list:
    img_name = f"self/Initial{int(endowment)}.png"
    you_dict[endowment] = visual.ImageStim(
        win=win, name=endowment,
        image=img_name, pos=[0, 0], size=(0.35, 0.35), flipHoriz=False, flipVert=False,
        color=[1,1,1], colorSpace='rgb', opacity=1, depth=0.0,
        texRes=128.0, interpolate=True)

you_Txt = visual.TextStim(
    win=win, name="you_Txt", 
    text='YOU', font='Open Sans', height=0.1, color='black', colorSpace='rgb', languageStyle='LTR', 
    opacity=1, depth=0.0, pos=[0, 0], ori=0.0, 
    wrapWidth=None)

or_Txt = visual.TextStim(
    win=win, name='or_Txt',
    text='OR', font='Open Sans', height=0.1, color='black', colorSpace='rgb', languageStyle='LTR',
    opacity=1, depth=0.0, pos=(0, 0), ori=0.0, 
    wrapWidth=None);

make_a_decision = visual.TextStim(
    win=win, name='make_a_decision',
    text='MAKE A DECISION', font='Open Sans', height=0.07, color='black', colorSpace='rgb', languageStyle='LTR',
    opacity=1, depth=0.0, pos=(0, -0.4), ori=0.0, 
    wrapWidth=None);

keep = visual.TextStim(
    win=win, name='keep',
    text='KEEP',font='Open Sans', height=0.07, color='black', colorSpace='rgb', languageStyle='LTR', 
    opacity=1, depth=0.0, pos=[0, 0], ori=0.0, 
    wrapWidth=None)

invest = visual.TextStim(
    win=win, name='invest',
    text='INVEST', font='Open Sans', height=0.07, color='black', colorSpace='rgb', languageStyle='LTR', 
    opacity=1, depth=0.0, pos=[0, 0], ori=0.0,
    wrapWidth=None)

partner_list = df["Stimuli"].tolist()
partner_dict = {}
for partner in partner_list:
    if "nonface" in partner:
        size_y = 0.22
    else:
        size_y = 0.30
    partner_dict[partner] = visual.ImageStim(
        win=win, name=partner,
        image=partner, pos=[0, 0], size=(0.40, size_y), flipHoriz=False, flipVert=False,
        color=[1,1,1], colorSpace='rgb', opacity=1, depth=0.0,
        texRes=128.0, interpolate=True)

pie_dict = {}
for endowment in endowment_list:
    img_name = f"probabilities/pie{int(endowment)}_0.png"
    key = f"{endowment}_0"
    pie_dict[key] = visual.ImageStim(
        win=win, name=key,
        image=img_name, pos=[0, 0], size=(0.35, 0.35), flipHoriz=False, flipVert=False, 
        color=[1,1,1], colorSpace='rgb', opacity=1, depth=0.0,
        texRes=128.0, interpolate=True)
    
    img_name = f"probabilities/pie{int(endowment)}_6.png"
    key = f"{endowment}_6"
    pie_dict[key] = visual.ImageStim(
        win=win, name=key,
        image=img_name, pos=[0, 0], size=(0.35, 0.35), flipHoriz=False, flipVert=False, 
        color=[1,1,1], colorSpace='rgb', opacity=1, depth=0.0,
        texRes=128.0, interpolate=True)

# Initialize components for Routine "choice1"
Choice_Key = keyboard.Keyboard()

#############################
########## OUTCOME ##########
#############################

results_list = df["Results"].drop_duplicates().tolist()
outcome_invest_dict = {}
for result in results_list:
    img_name = f"results/invest{round(float(result), 1)}.png"
    outcome_invest_dict[str(round(float(result), 1))] = visual.ImageStim(
        win=win, name=result, 
        image=img_name, ori=0.0, pos=(0, 0), size=(0.5, 0.5), flipHoriz=False, flipVert=False, 
        mask=None, color=[1,1,1], colorSpace='rgb', 
        opacity=1, texRes=128.0, interpolate=True, depth=0.0)

outcome_keep_dict = {}
for endowment in endowment_list:
    img_name = f"results/keep{int(endowment)}.png"
    outcome_keep_dict[endowment] = visual.ImageStim(
        win=win, name = endowment, 
        image=img_name, ori=0.0, pos=(0, 0), size=(0.5, 0.5), flipHoriz=False, flipVert=False, 
        mask=None, color=[1,1,1], colorSpace='rgb', 
        opacity=1, texRes=128.0, interpolate=True, depth=0.0)

outcome_Txt = visual.TextStim(
    win=win, name="outcome_Txt",
    text='', font='Open Sans', color='black', colorSpace='rgb', languageStyle='LTR', 
    pos=(0, 0.4), ori=0.0, height=0.07, wrapWidth=None, opacity=1, depth=0.0)

skipped = visual.ImageStim(
    win=win, name="skipped",
    image="trial_skipped.png", size=(0.5, 0.5), 
    ori=0.0, pos=(0, 0), flipHoriz=False, flipVert=False,
    color=[1,1,1], colorSpace='rgb', opacity=1, depth=0.0,
    texRes=128.0, mask=None, interpolate=True)

################################
########## RUN 1 OVER ##########
################################

Run1Over_Txt = visual.TextStim(
    win=win, name='Run1Over_Txt',
    text='Great job! Please take a break.\n\nWhen you are ready, press any key to continue the rest of the task.', font='Open Sans',
    pos=[0,0], height=0.07, wrapWidth=None, ori=0.0, 
    color='black', colorSpace='rgb', opacity=None, 
    languageStyle='LTR', depth=0.0);
Run1Over_Key = keyboard.Keyboard()

###########################
########## BONUS ##########
###########################

youBonus = visual.TextStim(
    win=win, name='youBonus',
    text='', font='Open Sans',
    pos=[0,0], height=0.07, wrapWidth=None, ori=0.0, 
    color='black', colorSpace='rgb', opacity=None, 
    languageStyle='LTR', depth=0.0);
TaskOver_Key = keyboard.Keyboard()

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 

####################################################################################################
############################################ EXPERIMENT ############################################
####################################################################################################

############################################
############### INSTRUCTIONS ###############
############################################

# ------Prepare to start Routine "Instructions"-------
continueRoutine = True
routineForceEnded = False

# update component parameters for each repeat
Instr_Key.keys = []
Instr_Key.rt = []
_Instr_Key_allKeys = []

# keep track of which components have finished
InstructionsComponents = [Instr_Txt, Instr_Key]
for thisComponent in InstructionsComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# -------Run Routine "Instructions"-------
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *Instr_Txt* updates
    if Instr_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        Instr_Txt.tStart = t  # local t and not account for scr refresh
        Instr_Txt.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(Instr_Txt, 'tStartRefresh')  # time at next scr refresh
        Instr_Txt.setAutoDraw(True)
    
    # *Instr_Key* updates
    waitOnFlip = False
    if Instr_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        Instr_Key.tStart = t  # local t and not account for scr refresh
        Instr_Key.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(Instr_Key, 'tStartRefresh')  # time at next scr refresh
        Instr_Key.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(Instr_Key.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(Instr_Key.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if Instr_Key.status == STARTED and not waitOnFlip:
        theseKeys = Instr_Key.getKeys(keyList=None, waitRelease=False)
        _Instr_Key_allKeys.extend(theseKeys)
        if len(_Instr_Key_allKeys):
            Instr_Key.keys = _Instr_Key_allKeys[-1].name  # just the last key pressed
            Instr_Key.rt = _Instr_Key_allKeys[-1].rt
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in InstructionsComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# -------Ending Routine "Instructions"-------
for thisComponent in InstructionsComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# save page onset
thisExp.addData('Instructions.started', Instr_Txt.tStartRefresh)
# check responses
if Instr_Key.keys in ['', [], None]:  # No response was made
    Instr_Key.keys = None
# save key pressed
thisExp.addData('Instructions.key', Instr_Key.keys)
if Instr_Key.keys != None:  # we had a response
    # save key press rt
    thisExp.addData('Instructions.rt', Instr_Key.rt)
# save page offset
if Instr_Key.keys != None:
    try:
        thisExp.addData('Instructions.stopped', float(Instr_Txt.tStartRefresh) + float(Instr_Key.rt))
    except:
        thisExp.addData('Instructions.stopped', None)
# move to next line
thisExp.nextEntry()
# the Routine "Instructions" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

if fMRIflag == 1:

    ################################################
    ############### WAIT FOR SCANNER ###############
    ################################################

    # ------Prepare to start Routine "WaitforScanner"-------
    continueRoutine = True
    routineForceEnded = False
    # update component parameters for each repeat
    WaitForScanner_Key.keys = []
    WaitForScanner_Key.rt = []
    _WaitForScanner_Key_allKeys = []

    # keep track of which components have finished
    WaitforScannerComponents = [WaitForScanner_Txt, WaitForScanner_Key]
    for thisComponent in WaitforScannerComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1

    # -------Run Routine "WaitforScanner"-------
    while continueRoutine:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *WaitForScanner_Txt* updates
        if WaitForScanner_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            WaitForScanner_Txt.frameNStart = frameN  # exact frame index
            WaitForScanner_Txt.tStart = t  # local t and not account for scr refresh
            WaitForScanner_Txt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(WaitForScanner_Txt, 'tStartRefresh')  # time at next scr refresh
            WaitForScanner_Txt.setAutoDraw(True)
        
        # *WaitForScanner_Key* updates
        waitOnFlip = False
        if WaitForScanner_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            WaitForScanner_Key.frameNStart = frameN  # exact frame index
            WaitForScanner_Key.tStart = t  # local t and not account for scr refresh
            WaitForScanner_Key.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(WaitForScanner_Key, 'tStartRefresh')  # time at next scr refresh
            WaitForScanner_Key.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(WaitForScanner_Key.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(WaitForScanner_Key.clearEvents, eventType='keyboard')  # clear events on next screen flip
        if WaitForScanner_Key.status == STARTED and not waitOnFlip:
            theseKeys = WaitForScanner_Key.getKeys(keyList=['5'], waitRelease=False)
            _WaitForScanner_Key_allKeys.extend(theseKeys)
            if len(_WaitForScanner_Key_allKeys):
                WaitForScanner_Key.keys = _WaitForScanner_Key_allKeys[-1].name  # just the last key pressed
                WaitForScanner_Key.rt = _WaitForScanner_Key_allKeys[-1].rt
                # a response ends the routine
                continueRoutine = False
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in WaitforScannerComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()

    # -------Ending Routine "WaitforScanner"-------
    for thisComponent in WaitforScannerComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # save page onset
    thisExp.addData('WaitForScanner.started', WaitForScanner_Txt.tStartRefresh)
    # check responses
    if WaitForScanner_Key.keys in ['', [], None]:  # No response was made
        WaitForScanner_Key.keys = None
    if WaitForScanner_Key.keys != None:  # we had a response
        try:
            # save key press rt
            thisExp.addData('WaitForScanner_Key.rt', WaitForScanner_Key.rt)
        except:
            thisExp.addData('WaitForScanner_Key.rt', None)
    # save page offset
    if WaitForScanner_Key.keys != None:
        thisExp.addData('WaitForScanner.stopped', float(WaitForScanner_Txt.tStartRefresh)+float(WaitForScanner_Key.rt))
    # move to next line
    thisExp.nextEntry()
    # the Routine "WaitforScanner" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()

    #####################################################
    ############### PRETRIAL FIXATION
    #####################################################

    # ------Prepare to start Routine "PretrialFixation"-------
    continueRoutine = True
    routineForceEnded = False
    PreFix_duration = 20.000

    # update component parameters for each repeat
    PreFix = jitter

    # keep track of which components have finished
    PretrialFixationComponents = [PreFix]
    for thisComponent in PretrialFixationComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        thisComponent.frameNStart = None
        thisComponent.frameNStop = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1

    # -------Run Routine "PretrialFixation"-------
    while continueRoutine and routineTimer.getTime() < PreFix_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *PreFix* updates
        if PreFix.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            PreFix.frameNStart = frameN  # exact frame index
            PreFix.tStart = t  # local t and not account for scr refresh
            PreFix.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(PreFix, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'PreFix.started')
            PreFix.setAutoDraw(True)
            if EEGflag == 1:
                port.write(bytes([255]))
        if PreFix.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > PreFix.tStartRefresh + (PreFix_duration-frameTolerance):
                if EEGflag == 1:
                    port.write(bytes([255]))
                # keep track of stop time/frame for later
                PreFix.tStop = t  # not accounting for scr refresh
                PreFix.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'PreFix.stopped')
                PreFix.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in PretrialFixationComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()

    # -------Ending Routine "PretrialFixation"-------
    for thisComponent in PretrialFixationComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # save page onset
    thisExp.addData('PreFix.started', PreFix.tStartRefresh)
    # save page offset
    try:
        thisExp.addData('PreFix.stopped', float(PreFix.tStartRefresh) + PreFix_duration)
    except:
        thisExp.addData('PreFix.stopped', None)
    # move to next line
    thisExp.nextEntry()
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-PreFix_duration)
 
#####################################
############### RUN 1 ###############
#####################################

# set up handler to look after randomisation of conditions etc
RUN1 = data.TrialHandler(nReps=1.0, method='sequential', 
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions(df_run1),
    seed=randint(1000), name='RUN1')
thisExp.addLoop(RUN1)  # add the loop to the experiment
thisRUN1 = RUN1.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb = thisRUN1.rgb)
if thisRUN1 != None:
    for paramName in thisRUN1:
        exec('{} = thisRUN1[paramName]'.format(paramName))

for thisRUN1 in RUN1:
    currentLoop = RUN1
    # abbreviate parameter names if possible (e.g. rgb = thisRUN1.rgb)
    if thisRUN1 != None:
        for paramName in thisRUN1:
            exec('{} = thisRUN1[paramName]'.format(paramName))
    
    ######################################
    ############### CHOICE ###############
    ######################################

    # ------Prepare to start Routine "Choice"-------
    continueRoutine = True
    routineForceEnded = False
    
    Choice_duration = 5.050
    
    # update component parameters for each repeat
    you = you_dict[Endowment]
    partner = partner_dict[Stimuli]
    pie = pie_dict[f"{Endowment}_{Ambiguity}"]
    if Side == "Left":
        keep.setPos([0.30, 0.45])
        you_Txt.setPos([0.30, 0.10])
        you.setPos([0.30, -0.15])
    
        invest.setPos([-0.30, 0.45])
        partner.setPos([-0.30, 0.20])
        pie.setPos([-0.30, -0.15])
    else:
        keep.setPos([-0.30, 0.45])
        you_Txt.setPos([-0.30, 0.10])
        you.setPos([-0.30, -0.15])
    
        invest.setPos([0.30, 0.45])
        partner.setPos([0.30, 0.20])
        pie.setPos([0.30, -0.15])

    Choice_Key.keys = []
    Choice_Key.rt = []
    _Choice_Key_allKeys = []

    # keep track of which components have finished
    ChoiceComponents = [keep, invest, you_Txt, partner, you, pie, make_a_decision, or_Txt, Choice_Key]
    for thisComponent in ChoiceComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # -------Run Routine "Choice"-------
    while continueRoutine and routineTimer.getTime() < Choice_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *keep* updates
        if keep.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            keep.tStart = t  # local t and not account for scr refresh
            keep.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(keep, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'keep.started')
            keep.setAutoDraw(True)
        if keep.status == STARTED:
            if tThisFlipGlobal > keep.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                keep.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'keep.stopped')
                keep.setAutoDraw(False)
        
        # *invest* updates
        if invest.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            invest.tStart = t  # local t and not account for scr refresh
            invest.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(invest, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'invest.started')
            invest.setAutoDraw(True)
        if invest.status == STARTED:
            if tThisFlipGlobal > invest.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                invest.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'invest.stopped')
                invest.setAutoDraw(False)
        
        # *you_Txt* updates
        if you_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            you_Txt.tStart = t  # local t and not account for scr refresh
            you_Txt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(you_Txt, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'you_Txt.started')
            you_Txt.setAutoDraw(True)
        if you_Txt.status == STARTED:
            if tThisFlipGlobal > you_Txt.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                you_Txt.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'you_Txt.stopped')
                you_Txt.setAutoDraw(False)

        # *partner* updates
        if partner.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            if EEGflag == 1:
                port.write(bytes([Trigger]))
            # keep track of start time/frame for later
            partner.tStart = t  # local t and not account for scr refresh
            partner.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(partner, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'partner.started')
            partner.setAutoDraw(True)
        if partner.status == STARTED:
            if tThisFlipGlobal > partner.tStartRefresh + (Choice_duration-frameTolerance):
                if EEGflag == 1:
                    port.write(bytes([Trigger]))
                # keep track of stop time/frame for later
                partner.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'partner.stopped')
                partner.setAutoDraw(False)
        
        # *you* updates
        if you.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            you.tStart = t  # local t and not account for scr refresh
            you.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(you, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'you.started')
            you.setAutoDraw(True)
        if you.status == STARTED:
            if tThisFlipGlobal > you.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                you.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'you.stopped')
                you.setAutoDraw(False)
        
        # *pie* updates
        if pie.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            pie.tStart = t  # local t and not account for scr refresh
            pie.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(pie, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'pie.started')
            pie.setAutoDraw(True)
        if pie.status == STARTED:
            if tThisFlipGlobal > pie.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                pie.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'pie.stopped')
                pie.setAutoDraw(False)

        # *or_Txt* updates
        if or_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            or_Txt.tStart = t  # local t and not account for scr refresh
            or_Txt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(or_Txt, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'or_Txt.started')
            or_Txt.setAutoDraw(True)
        if or_Txt.status == STARTED:
            if tThisFlipGlobal > or_Txt.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                or_Txt.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'or_Txt.stopped')
                or_Txt.setAutoDraw(False)
        
        # *make_a_decision* updates
        if make_a_decision.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            make_a_decision.tStart = t  # local t and not account for scr refresh
            make_a_decision.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(make_a_decision, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'make_a_decision.started')
            make_a_decision.setAutoDraw(True)
        if make_a_decision.status == STARTED:
            if tThisFlipGlobal > make_a_decision.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                make_a_decision.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'make_a_decision.stopped')
                make_a_decision.setAutoDraw(False)
        
        # *Choice_Key* updates
        waitOnFlip = False
        if Choice_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Choice_Key.tStart = t  # local t and not account for scr refresh
            Choice_Key.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Choice_Key, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'Choice_Key.started')
            Choice_Key.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(Choice_Key.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(Choice_Key.clearEvents, eventType='keyboard')  # clear events on next screen flip
        if Choice_Key.status == STARTED:
            if tThisFlipGlobal > Choice_Key.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                Choice_Key.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Choice_Key.stopped')
                Choice_Key.status = FINISHED
        if Choice_Key.status == STARTED and not waitOnFlip:
            theseKeys = Choice_Key.getKeys(keyList=['1', '6'], waitRelease=False)
            _Choice_Key_allKeys.extend(theseKeys)
            if len(_Choice_Key_allKeys):
                Choice_Key.keys = _Choice_Key_allKeys[-1].name  # just the last key pressed
                Choice_Key.rt = _Choice_Key_allKeys[-1].rt  # rt for just the last key pressed
                # a response ends the routine
                continueRoutine = False
                ### append result to results
                if Side == "Left": #partner on the left, keep on the right
                    if Choice_Key.keys == '6': #6 button is on the right and corresponds to keep
                        result = Endowment
                    elif Choice_Key.keys == '1': #1 button is on the left and corresponds to invest
                        result = Results
                elif Side == "Right": #partner on the right, keep on the left
                    if Choice_Key.keys == '1': #1 button is on the left and corresponds to keep
                        result = Endowment
                    elif Choice_Key.keys == '6': #1 button is on the right and corresponds to invest
                        result = Results
                results.append(result)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in ChoiceComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # -------Ending Routine "Choice"-------
    for thisComponent in ChoiceComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    
    # save page onset
    RUN1.addData('Choice.started', you_Txt.tStartRefresh)
    # check responses
    if Choice_Key.keys in ['', [], None]:  # No response was made
        Choice_Key.keys = None
    # save key pressed
    RUN1.addData('Choice_Key.keys',Choice_Key.keys)
    if Choice_Key.keys != None:  # we had a response
        # save key press rt
        RUN1.addData('Choice_Key.rt', Choice_Key.rt)
    # save page offset
    if Choice_Key.keys != None:
        try:
            RUN1.addData('Choice.stopped', float(you_Txt.tStartRefresh) + float(Choice_Key.rt))
        except:
            RUN1.addData('Choice.stopped', None)
    else:
        try:
            RUN1.addData('Choice.stopped', float(you_Txt.tStartRefresh) + Choice_duration)
        except:
            RUN1.addData('Choice.stopped', None)
    # save result
    RUN1.addData('result', result)
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-Choice_duration)
    
    #######################################
    ############### OUTCOME ###############
    #######################################
        
    # ------Prepare to start Routine "Outcome"-------
    continueRoutine = True
    routineForceEnded = False
    
    Outcome_duration = 3.500

    # update component parameters for each repeat
    if Choice_Key.keys != None:
        if Side == "Left": #partner on the left, keep on the right
            if Choice_Key.keys == '6': #6 button is on the right and corresponds to keep
                outcome = outcome_keep_dict[Endowment]
                txt = 'You chose not to invest'
                
            elif Choice_Key.keys == '1': #1 button is on the left and corresponds to invest
                outcome = outcome_invest_dict[str(round(float(Results), 1))]
                txt = "Your return amount is %.1f points" %float(Results)

        if Side == "Right": #partner on the right, keep on the left
            if Choice_Key.keys == '1': #1 button is on the left and corresponds to keep
                outcome = outcome_keep_dict[Endowment]
                txt = 'You chose not to invest'

            elif Choice_Key.keys == '6': #6 button is on the right and corresponds to invest
                outcome = outcome_invest_dict[str(round(float(Results), 1))]
                txt = "Your return amount is %.1f points" %float(Results)

    else:
        outcome = skipped
        txt = ''
    outcome_Txt.setText(txt)

    # keep track of which components have finished
    OutcomeComponents = [outcome, outcome_Txt]
    for thisComponent in OutcomeComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # -------Run Routine "Outcome"-------
    while continueRoutine and routineTimer.getTime() < Outcome_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *outcome* updates
        if outcome.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            if EEGflag == 1:
                port.write(bytes([132]))
            # keep track of start time/frame for later
            outcome.tStart = t  # local t and not account for scr refresh
            outcome.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(outcome, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'outcome.started')
            outcome.setAutoDraw(True)
        if outcome.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > outcome.tStartRefresh + (Outcome_duration-frameTolerance):
                if EEGflag == 1:
                    port.write(bytes([132]))
                # keep track of stop time/frame for later
                outcome.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'outcome.stopped')
                outcome.setAutoDraw(False)
        
        # *outcome_Txt* updates
        if outcome_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            outcome_Txt.tStart = t  # local t and not account for scr refresh
            outcome_Txt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(outcome_Txt, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'outcome_Txt.started')
            outcome_Txt.setAutoDraw(True)
        if outcome_Txt.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > outcome_Txt.tStartRefresh + (Outcome_duration-frameTolerance):
                # keep track of stop time/frame for later
                outcome_Txt.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'outcome_Txt.stopped')
                outcome_Txt.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in OutcomeComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # -------Ending Routine "Outcome"-------
    for thisComponent in OutcomeComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # save page onset
    RUN1.addData('Outcome.started', outcome.tStartRefresh)
    # save page offset
    try:
        RUN1.addData('Outcome.stopped', float(outcome.tStartRefresh) + Outcome_duration)
    except:
        RUN1.addData('Outcome.stopped', None)
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-Outcome_duration)
    
    ###################################
    ############### ITI ###############
    ###################################

    # ------Prepare to start Routine "iti"-------
    continueRoutine = True
    routineForceEnded = False

    # update component parameters for each repeat
    iti_duration = np.random.normal(1.25, 0.25)

    # keep track of which components have finished
    itiComponents = [jitter]
    for thisComponent in itiComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
        
    # -------Run Routine "iti"-------
    while continueRoutine and routineTimer.getTime() < iti_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
            
        # *jitter* updates
        if jitter.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            if EEGflag == 1:
                port.write(bytes([155]))
            # keep track of start time/frame for later
            jitter.tStart = t  # local t and not account for scr refresh
            jitter.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(jitter, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'jitter.started')
            jitter.setAutoDraw(True)
        if jitter.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > jitter.tStartRefresh + (iti_duration-frameTolerance):
                if EEGflag == 1:
                    port.write(bytes([155]))
                # keep track of stop time/frame for later
                jitter.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'jitter.stopped')
                jitter.setAutoDraw(False)
            
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in itiComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
            
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
        
    # -------Ending Routine "iti"-------
    for thisComponent in itiComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # save page onset
    RUN1.addData('iti.started', jitter.tStartRefresh)
    # save page offset
    try:
        RUN1.addData('iti.stopped', float(jitter.tStartRefresh) + iti_duration)
    except:
        RUN1.addData('iti.stopped', None)
    # move to next line
    thisExp.nextEntry()
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-iti_duration)
    
# completed 1.0 repeats of 'RUN1'

if fMRIflag == 1:
    ##################################################
    ############### POSTTRIAL FIXATION ###############
    ##################################################

    # ------Prepare to start Routine "PosttrialFixation"-------
    continueRoutine = True
    routineForceEnded = False

    # update component parameters for each repeat
    PostFix = jitter
    run_total_duration = (float(jitter.tStartRefresh) + iti_duration) - PreFix.tStartRefresh
    if round(run_total_duration % tr, 2) == 0:
        PostFix_duration = float(tr * 10)
    else:
        PostFix_duration = float((tr * 10) + (tr - round(run_total_duration % tr, 2)))

    # keep track of which components have finished
    PosttrialFixationComponents = [PostFix]
    for thisComponent in PosttrialFixationComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED

    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1

    # -------Run Routine "PosttrialFixation"-------
    while continueRoutine and routineTimer.getTime() < PostFix_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *PostFix* updates
        if PostFix.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            if EEGflag == 1:
                port.write(bytes([100]))
            # keep track of start time/frame for later
            PostFix.tStart = t  # local t and not account for scr refresh
            PostFix.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(PostFix, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'PostFix.started')
            PostFix.setAutoDraw(True)
        if PostFix.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > PostFix.tStartRefresh + (run_total_duration-frameTolerance):
                if EEGflag == 1:
                    port.write(bytes([100]))
                # keep track of stop time/frame for later
                PostFix.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'PostFix.stopped')
                PostFix.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in PosttrialFixationComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()

    # -------Ending Routine "PosttrialFixation"-------
    for thisComponent in PosttrialFixationComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # save page onset
    thisExp.addData('PostFix.started', PostFix.tStartRefresh)
    # save page offset
    try:
        thisExp.addData('PostFix.stopped', float(PostFix.tStartRefresh) + PostFix_duration)
    except:
        thisExp.addData('PostFix.stopped', float(PostFix.tStartRefresh) + PostFix_duration)
    # move to next line
    thisExp.nextEntry()
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-PostFix_duration)

#########################################
############### RUN 1 OVER ###############
#########################################

# ------Prepare to start Routine "Run1Over"-------
continueRoutine = True
routineForceEnded = False

# update component parameters for each repeat
Run1Over_Key.keys = []
Run1Over_Key.rt = []
_Run1Over_Key_allKeys = []

# keep track of which components have finished
Run1OverComponents = [Run1Over_Txt, Run1Over_Key]
for thisComponent in Run1OverComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# -------Run Routine "Run1Over"-------
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *Run1Over_Txt* updates
    if Run1Over_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        Run1Over_Txt.tStart = t  # local t and not account for scr refresh
        Run1Over_Txt.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(Run1Over_Txt, 'tStartRefresh')  # time at next scr refresh
        Run1Over_Txt.setAutoDraw(True)
    
    # *Run1Over_Key* updates
    waitOnFlip = False
    if Run1Over_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        Run1Over_Key.tStart = t  # local t and not account for scr refresh
        Run1Over_Key.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(Run1Over_Key, 'tStartRefresh')  # time at next scr refresh
        Run1Over_Key.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(Run1Over_Key.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(Run1Over_Key.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if Run1Over_Key.status == STARTED and not waitOnFlip:
        theseKeys = Run1Over_Key.getKeys(keyList=None, waitRelease=False)
        _Run1Over_Key_allKeys.extend(theseKeys)
        if len(_Run1Over_Key_allKeys):
            Run1Over_Key.keys = _Run1Over_Key_allKeys[-1].name  # just the last key pressed
            Run1Over_Key.rt = _Run1Over_Key_allKeys[-1].rt
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in Run1OverComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# -------Ending Routine "Run1Over"-------
for thisComponent in Run1OverComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# save page onset
thisExp.addData('TaskOver.started', Run1Over_Txt.tStartRefresh)
# check responses
if Run1Over_Key.keys in ['', [], None]:  # No response was made
    Run1Over_Key.keys = None
# save key pressed
thisExp.addData('Run1Over_Key.keys',Run1Over_Key.keys)
if Run1Over_Key.keys != None:  # we had a response
    # save key press rt
    thisExp.addData('Run1Over_Key.rt', Run1Over_Key.rt)
# save page offset
if Run1Over_Key.keys != None:
    try:
        thisExp.addData('TaskOver.stopped', float(Run1Over_Txt.tStartRefresh) + float(Run1Over_Key.rt))
    except:
        thisExp.addData('TaskOver.stopped', None)
# move to next line
thisExp.nextEntry()
# the Routine "Run1Over" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

#####################################
############### RUN 2 ###############
#####################################

# set up handler to look after randomisation of conditions etc
RUN2 = data.TrialHandler(nReps=1.0, method='sequential', 
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions(df_run2),
    seed=randint(1000), name='RUN2')
thisExp.addLoop(RUN2)  # add the loop to the experiment
thisRUN2 = RUN2.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb = thisRUN2.rgb)
if thisRUN2 != None:
    for paramName in thisRUN2:
        exec('{} = thisRUN2[paramName]'.format(paramName))

for thisRUN2 in RUN2:
    currentLoop = RUN2
    # abbreviate parameter names if possible (e.g. rgb = thisRUN2.rgb)
    if thisRUN2 != None:
        for paramName in thisRUN2:
            exec('{} = thisRUN2[paramName]'.format(paramName))
    
    ######################################
    ############### CHOICE ###############
    ######################################

    # ------Prepare to start Routine "Choice"-------
    continueRoutine = True
    routineForceEnded = False
    Choice_duration = 5.050
    
    # update component parameters for each repeat
    you = you_dict[Endowment]
    partner = partner_dict[Stimuli]
    pie = pie_dict[f"{Endowment}_{Ambiguity}"]
    if Side == "Left":
        keep.setPos([0.30, 0.45])
        you_Txt.setPos([0.30, 0.10])
        you.setPos([0.30, -0.15])
    
        invest.setPos([-0.30, 0.45])
        partner.setPos([-0.30, 0.20])
        pie.setPos([-0.30, -0.15])
    else:
        keep.setPos([-0.30, 0.45])
        you_Txt.setPos([-0.30, 0.10])
        you.setPos([-0.30, -0.15])
    
        invest.setPos([0.30, 0.45])
        partner.setPos([0.30, 0.20])
        pie.setPos([0.30, -0.15])

    Choice_Key.keys = []
    Choice_Key.rt = []
    _Choice_Key_allKeys = []

    # keep track of which components have finished
    ChoiceComponents = [keep, invest, you_Txt, partner, you, pie, make_a_decision, or_Txt, Choice_Key]
    for thisComponent in ChoiceComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # -------Run Routine "Choice"-------
    while continueRoutine and routineTimer.getTime() < Choice_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *keep* updates
        if keep.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            keep.tStart = t  # local t and not account for scr refresh
            keep.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(keep, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'keep.started')
            keep.setAutoDraw(True)
        if keep.status == STARTED:
            if tThisFlipGlobal > keep.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                keep.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'keep.stopped')
                keep.setAutoDraw(False)
        
        # *invest* updates
        if invest.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            invest.tStart = t  # local t and not account for scr refresh
            invest.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(invest, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'invest.started')
            invest.setAutoDraw(True)
        if invest.status == STARTED:
            if tThisFlipGlobal > invest.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                invest.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'invest.stopped')
                invest.setAutoDraw(False)
        
        # *you_Txt* updates
        if you_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            you_Txt.tStart = t  # local t and not account for scr refresh
            you_Txt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(you_Txt, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'you_Txt.started')
            you_Txt.setAutoDraw(True)
        if you_Txt.status == STARTED:
            if tThisFlipGlobal > you_Txt.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                you_Txt.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'you_Txt.stopped')
                you_Txt.setAutoDraw(False)

        # *partner* updates
        if partner.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            if EEGflag == 1:
                port.write(bytes([Trigger]))
            # keep track of start time/frame for later
            partner.tStart = t  # local t and not account for scr refresh
            partner.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(partner, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'partner.started')
            partner.setAutoDraw(True)
        if partner.status == STARTED:
            if tThisFlipGlobal > partner.tStartRefresh + (Choice_duration-frameTolerance):
                if EEGflag == 1:
                    port.write(bytes([Trigger]))
                # keep track of stop time/frame for later
                partner.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'partner.stopped')
                partner.setAutoDraw(False)
        
        # *you* updates
        if you.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            you.tStart = t  # local t and not account for scr refresh
            you.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(you, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'you.started')
            you.setAutoDraw(True)
        if you.status == STARTED:
            if tThisFlipGlobal > you.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                you.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'you.stopped')
                you.setAutoDraw(False)
        
        # *pie* updates
        if pie.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            pie.tStart = t  # local t and not account for scr refresh
            pie.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(pie, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'pie.started')
            pie.setAutoDraw(True)
        if pie.status == STARTED:
            if tThisFlipGlobal > pie.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                pie.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'pie.stopped')
                pie.setAutoDraw(False)

        # *or_Txt* updates
        if or_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            or_Txt.tStart = t  # local t and not account for scr refresh
            or_Txt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(or_Txt, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'or_Txt.started')
            or_Txt.setAutoDraw(True)
        if or_Txt.status == STARTED:
            if tThisFlipGlobal > or_Txt.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                or_Txt.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'or_Txt.stopped')
                or_Txt.setAutoDraw(False)
        
        # *make_a_decision* updates
        if make_a_decision.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            make_a_decision.tStart = t  # local t and not account for scr refresh
            make_a_decision.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(make_a_decision, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'make_a_decision.started')
            make_a_decision.setAutoDraw(True)
        if make_a_decision.status == STARTED:
            if tThisFlipGlobal > make_a_decision.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                make_a_decision.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'make_a_decision.stopped')
                make_a_decision.setAutoDraw(False)
        
        # *Choice_Key* updates
        waitOnFlip = False
        if Choice_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Choice_Key.tStart = t  # local t and not account for scr refresh
            Choice_Key.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Choice_Key, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'Choice_Key.started')
            Choice_Key.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(Choice_Key.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(Choice_Key.clearEvents, eventType='keyboard')  # clear events on next screen flip
        if Choice_Key.status == STARTED:
            if tThisFlipGlobal > Choice_Key.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                Choice_Key.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Choice_Key.stopped')
                Choice_Key.status = FINISHED
        if Choice_Key.status == STARTED and not waitOnFlip:
            theseKeys = Choice_Key.getKeys(keyList=['1', '6'], waitRelease=False)
            _Choice_Key_allKeys.extend(theseKeys)
            if len(_Choice_Key_allKeys):
                Choice_Key.keys = _Choice_Key_allKeys[-1].name  # just the last key pressed
                Choice_Key.rt = _Choice_Key_allKeys[-1].rt  # rt for just the last key pressed
                # a response ends the routine
                continueRoutine = False
                ### append result to results
                if Side == "Left": #partner on the left, keep on the right
                    if Choice_Key.keys == '6': #6 button on the right, corresponds to keep
                        result = Endowment
                    elif Choice_Key.keys == '1': #1 button on the left, corresponds to invest
                        result = Results
                elif Side == "Right": #partner on the right, keep on the left
                    if Choice_Key.keys == '1': #1 button on the left, corresponds to keep
                        result = Endowment
                    elif Choice_Key.keys == '6': #6 button on the right, corresponds to invest
                        result = Results
                results.append(result)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in ChoiceComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # -------Ending Routine "Choice"-------
    for thisComponent in ChoiceComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    
    # save page onset
    RUN2.addData('Choice.started', you_Txt.tStartRefresh)
    # check responses
    if Choice_Key.keys in ['', [], None]:  # No response was made
        Choice_Key.keys = None
    # save key pressed
    RUN2.addData('Choice_Key.keys',Choice_Key.keys)
    if Choice_Key.keys != None:  # we had a response
        # save key press rt
        RUN2.addData('Choice_Key.rt', Choice_Key.rt)
    # save page offset
    if Choice_Key.keys != None:
        try:
            RUN2.addData('Choice.stopped', float(you_Txt.tStartRefresh) + float(Choice_Key.rt))
        except:
            RUN2.addData('Choice.stopped', None)
    else:
        try:
            RUN2.addData('Choice.stopped', float(you_Txt.tStartRefresh) + Choice_duration)
        except:
            RUN2.addData('Choice.stopped', None)
    # save result
    RUN2.addData('result', result)
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-Choice_duration)
    
    #######################################
    ############### OUTCOME ###############
    #######################################
        
    # ------Prepare to start Routine "Outcome"-------
    continueRoutine = True
    routineForceEnded = False
    Outcome_duration = 3.500

    # update component parameters for each repeat
    if Choice_Key.keys != None:
        if Side == "Left": #partner on the left, keep on the right
            if Choice_Key.keys == '6': #6 button on the right, corresponds to keep
                outcome = outcome_keep_dict[Endowment]
                txt = 'You chose not to invest'
                
            elif Choice_Key.keys == '1': #1 button on the left, corresponds to invest
                outcome = outcome_invest_dict[str(round(float(Results), 1))]
                txt = "Your return amount is %.1f points" %float(result)

        if Side == "Right": #partner on the right, keep on the left
            if Choice_Key.keys == '1': #1 button on the left, corresponds to keep
                outcome = outcome_keep_dict[Endowment]
                txt = 'You chose not to invest'

            elif Choice_Key.keys == '6': #6 button on the right, corresponds to invest
                outcome = outcome_invest_dict[str(round(float(Results), 1))]
                txt = "Your return amount is %.1f points" %float(result)

    else:
        outcome = skipped
        txt = ''
    outcome_Txt.setText(txt)

    # keep track of which components have finished
    OutcomeComponents = [outcome, outcome_Txt]
    for thisComponent in OutcomeComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # -------Run Routine "Outcome"-------
    while continueRoutine and routineTimer.getTime() < Outcome_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *outcome* updates
        if outcome.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            if EEGflag == 1:
                port.write(bytes([132]))
            # keep track of start time/frame for later
            outcome.tStart = t  # local t and not account for scr refresh
            outcome.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(outcome, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'outcome.started')
            outcome.setAutoDraw(True)
        if outcome.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > outcome.tStartRefresh + (Outcome_duration-frameTolerance):
                if EEGflag == 1:
                    port.write(bytes([132]))
                # keep track of stop time/frame for later
                outcome.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'outcome.stopped')
                outcome.setAutoDraw(False)
        
        # *outcome_Txt* updates
        if outcome_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            outcome_Txt.tStart = t  # local t and not account for scr refresh
            outcome_Txt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(outcome_Txt, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'outcome_Txt.started')
            outcome_Txt.setAutoDraw(True)
        if outcome_Txt.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > outcome_Txt.tStartRefresh + (Outcome_duration-frameTolerance):
                # keep track of stop time/frame for later
                outcome_Txt.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'outcome_Txt.stopped')
                outcome_Txt.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in OutcomeComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # -------Ending Routine "Outcome"-------
    for thisComponent in OutcomeComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # save page onset
    RUN2.addData('Outcome.started', outcome.tStartRefresh)
    # save page offset
    try:
        RUN2.addData('Outcome.stopped', float(outcome.tStartRefresh) + Outcome_duration)
    except:
        RUN2.addData('Outcome.stopped', None)
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-Outcome_duration)
    
    ###################################
    ############### ITI ###############
    ###################################

    # ------Prepare to start Routine "iti"-------
    continueRoutine = True
    routineForceEnded = False

    # update component parameters for each repeat
    iti_duration = np.random.normal(1.25, 0.25)

    # keep track of which components have finished
    itiComponents = [jitter]
    for thisComponent in itiComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
        
    # -------Run Routine "iti"-------
    while continueRoutine and routineTimer.getTime() < iti_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
            
        # *jitter* updates
        if jitter.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            if EEGflag == 1:
                port.write(bytes([155]))
            # keep track of start time/frame for later
            jitter.tStart = t  # local t and not account for scr refresh
            jitter.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(jitter, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'jitter.started')
            jitter.setAutoDraw(True)
        if jitter.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > jitter.tStartRefresh + (iti_duration-frameTolerance):
                if EEGflag == 1:
                    port.write(bytes([155]))
                # keep track of stop time/frame for later
                jitter.tStop = t  # not accounting for scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'jitter.stopped')
                jitter.setAutoDraw(False)
            
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in itiComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
            
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
        
    # -------Ending Routine "iti"-------
    for thisComponent in itiComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # save page onset
    RUN2.addData('iti.started', jitter.tStartRefresh)
    # save page offset
    try:
        RUN2.addData('iti.stopped', float(jitter.tStartRefresh) + iti_duration)
    except:
        RUN2.addData('iti.stopped', None)
    # move to next line
    thisExp.nextEntry()
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-iti_duration)
    
# completed 1.0 repeats of 'RUN2'

#########################################
############### TASK OVER ###############
#########################################

# ------Prepare to start Routine "TaskOver"-------
continueRoutine = True
routineForceEnded = False

# update component parameters for each repeat
#randomly select one result from results
bonus = randchoice(results)
bonus_msg = f"You have finished both runs.\n\nYour bonus for this game is {bonus}.\n\nPlease wait for the RA to end session."
youBonus.setText(bonus_msg)

TaskOver_Key.keys = []
TaskOver_Key.rt = []
_TaskOver_Key_allKeys = []

# keep track of which components have finished
TaskOverComponents = [youBonus, TaskOver_Key]
for thisComponent in TaskOverComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# -------Run Routine "TaskOver"-------
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *youBonus* updates
    if youBonus.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        youBonus.tStart = t  # local t and not account for scr refresh
        youBonus.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(youBonus, 'tStartRefresh')  # time at next scr refresh
        youBonus.setAutoDraw(True)
    
    # *TaskOver_Key* updates
    waitOnFlip = False
    if TaskOver_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        TaskOver_Key.tStart = t  # local t and not account for scr refresh
        TaskOver_Key.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(TaskOver_Key, 'tStartRefresh')  # time at next scr refresh
        TaskOver_Key.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(TaskOver_Key.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(TaskOver_Key.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if TaskOver_Key.status == STARTED and not waitOnFlip:
        theseKeys = TaskOver_Key.getKeys(keyList=None, waitRelease=False)
        _TaskOver_Key_allKeys.extend(theseKeys)
        if len(_TaskOver_Key_allKeys):
            TaskOver_Key.keys = _TaskOver_Key_allKeys[-1].name  # just the last key pressed
            TaskOver_Key.rt = _TaskOver_Key_allKeys[-1].rt
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in TaskOverComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# -------Ending Routine "TaskOver"-------
for thisComponent in TaskOverComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# save page onset
thisExp.addData('TaskOver.started', youBonus.tStartRefresh)
# check responses
if TaskOver_Key.keys in ['', [], None]:  # No response was made
    TaskOver_Key.keys = None
# save key pressed
thisExp.addData('TaskOver_Key.keys',TaskOver_Key.keys)
if TaskOver_Key.keys != None:  # we had a response
    # save key press rt
    thisExp.addData('TaskOver_Key.rt', TaskOver_Key.rt)
# save page offset
if TaskOver_Key.keys != None:
    try:
        thisExp.addData('TaskOver.stopped', float(youBonus.tStartRefresh) + float(TaskOver_Key.rt))
    except:
        thisExp.addData('TaskOver.stopped', None)
# move to next line
thisExp.nextEntry()
# the Routine "TaskOver" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

###################################
############### END ###############
###################################

# --- End experiment ---
# Flip one final time so any remaining win.callOnFlip() 
# and win.timeOnFlip() tasks get executed before quitting
win.flip()

# these shouldn't be strictly necessary (should auto-save)
thisExp.saveAsWideText(filename+'.csv', delim='auto')
thisExp.saveAsPickle(filename)
logging.flush()
# make sure everything is closed down
if eyetracker:
    eyetracker.setConnectionState(False)
thisExp.abort()  # or data files will save again on exit
win.close()
core.quit()