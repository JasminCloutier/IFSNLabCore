#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy3 Experiment Builder (v2022.2.4),
    on Sat Jan 21 17:04:41 2023
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

# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)

# Store info about the experiment session
psychopyVersion = '2022.2.4'
expName = 'TG'  # from the Builder filename that created this script
participants_list = list(np.arange(1,129))
participants_list.append('test_purple')
participants_list.append('test_orange')
expInfo = {
    'Participant': participants_list,
    'Simultaneous/MRI/EGG/Behavioral?': ["Simultaneous", "fMRI only", "EEG only", "Behavioral only"]
}

# --- Show Participant info dialog --
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
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

endExpNow = False  # flag for 'escape' or other condition => quit the exp
frameTolerance = 0.001  # how close to onset before 'same' frame

# Start Code - component code to be run after the window creation

# --- Setup the Window ---
win = visual.Window(
    size=(1920, 1080), fullscr=True, screen=0, 
    winType='pyglet', allowGUI = False, allowStencil=False,
    monitor='testMonitor', color='#D7D7D7', colorSpace='rgb',
    blendMode='avg', useFBO=True, units='height')
win.mouseVisible = False

# store frame rate of monitor if we can measure it
expInfo['frameRate'] = win.getActualFrameRate()
if expInfo['frameRate'] != None:
    frameDur = 1.0 / round(expInfo['frameRate'])
else:
    frameDur = 1.0 / 60.0  # could not measure, so guess

# --- Setup input devices ---
ioConfig = {}

# Setup iohub keyboard
ioConfig['Keyboard'] = dict(use_keymap='psychopy')
ioSession = '1'
if 'session' in expInfo:
    ioSession = str(expInfo['session'])
ioServer = io.launchHubServer(window=win, **ioConfig)
eyetracker = None

# create a default keyboard (e.g. to check for escape)
defaultKeyboard = keyboard.Keyboard(backend='iohub')

# create file names for the different run files
df_run1 = f"df/df_{expInfo['Participant']}_1.csv"
df_run2 = f"df/df_{expInfo['Participant']}_2.csv"
df_run3 = f"df/df_{expInfo['Participant']}_3.csv"

# save TR as object to calculate post-run padding
tr = 2.45

# create MRI and EEG flags
if expInfo['Simultaneous/MRI/EGG/Behavioral?'] == "Simultaneous":
    fMRI_flag = 1
    EEG_flag = 1
elif expInfo['Simultaneous/MRI/EGG/Behavioral?'] == "fMRI only":
    fMRI_flag = 1
    EEG_flag = 0
elif expInfo['Simultaneous/MRI/EGG/Behavioral?'] == "EEG only":
    fMRI_flag = 0
    EEG_flag = 1
elif expInfo['Simultaneous/MRI/EGG/Behavioral?'] == "Behavioral only":
    fMRI_flag = 0
    EEG_flag = 0

if EEG_flag == 1:
    import serial
    import time
    port = serial.Serial("COM5")

####################################################################################################
############################################ INITIALIZE ############################################
####################################################################################################

##################################
########## INSTRUCTIONS ##########
##################################

# --- Initialize components for Routine "Instructions" ---
Instr_Txt = visual.TextStim(
    win=win, name='Instr_Txt',
    text='You will now play 3 runs of trust games with other players.\n\nIn each run, you will play 56 trust games with 56 unique players. A researcher will check-in with you between runs to make sure you are comfortable.\n\nPress any button to start the first run.',
    font='Open Sans', pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
    color='black', colorSpace='rgb', opacity=None, 
    languageStyle='LTR', depth=0.0);
Instr_Key = keyboard.Keyboard()

##############################
########## POST-RUN ##########
##############################

# --- Initialize components for Routine "Postrun" ---
Postrun_Txt = visual.TextStim(
    win=win, name='Postrun_Txt',
    text='Great job! A researcher will check-in with you shortly.',
    font='Open Sans', pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
    color='black', colorSpace='rgb', opacity=None, 
    languageStyle='LTR', depth=0.0);
Postrun_Key = keyboard.Keyboard()

######################################
########## WAIT FOR SCANNER ##########
######################################

# --- Initialize components for Routine "WaitForScanner" ---
WaitForScanner_Key = keyboard.Keyboard()
WaitForScanner_Txt = visual.TextStim(
    win=win, name='WaitForScanner_Txt',
    text='Waiting for scanner...', font='Open Sans',
    pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
    color='black', colorSpace='rgb', opacity=None, 
    languageStyle='LTR', depth=0.0);

############################
########## JITTER ##########
############################

# --- Initialize components for Routine "PretrialFixation" ---
jitter = visual.TextStim(
    win=win, name='jitter',
    text='+', font='Open Sans',
    pos=(0, 0), height=0.3, wrapWidth=None, ori=0.0, 
    color='black', colorSpace='rgb', opacity=None, 
    languageStyle='LTR', depth=0.0);

########################################
########## PARTNER INTRO TEXT ##########
########################################

partnerintro_Txt = visual.TextStim(
    win=win, name='partnerintro_Txt',
    text='This is your partner',
    font='Open Sans',
    pos=(0, 0.40), height=0.07, wrapWidth=None, ori=0.0, 
    color='black', colorSpace='rgb', opacity=None, 
    languageStyle='LTR', depth=0.0);

#################################
########## PARTICIPANT ##########
#################################

you = visual.TextStim(
    win=win, name = "YOU", 
    text='YOU', font='Open Sans',
    pos=[-0.30, 0.30], height=0.05, ori=0.0, 
    color='black', colorSpace='rgb', languageStyle='LTR',
    opacity=1, depth=0.0, wrapWidth=None)

#############################
########## PARTNER ##########
#############################
partner_dict = {}
df = pd.read_csv(df_run1)
partner_list = df.Stimuli.tolist()
for image in partner_list:
    if image not in partner_dict.keys():
        partner_dict[image] = visual.ImageStim(
            win=win, name=image, 
            image=image, mask=None, anchor='center',
            ori=0.0, pos=(0, 0), size=(0.5, 0.5),
            color=[1,1,1], colorSpace='rgb', opacity=None,
            flipHoriz=False, flipVert=False,
            texRes=128.0, interpolate=True, depth=0.0)

##########################
########## KEEP ##########
##########################

keep = visual.TextStim(
    win=win, name='keep',
    text='Keep', font='Open Sans',
    pos=[-0.3,-0.2], height=0.05, ori=0.0, 
    color='black', colorSpace='rgb', languageStyle='LTR',
    opacity=1, depth=0.0, wrapWidth=None);

############################
########## INVEST ##########
############################

invest = visual.TextStim(
    win=win, name='invest',
    text='Invest', font='Open Sans',
    pos=[0.3,-0.2], height=0.05, ori=0.0, 
    color='black', colorSpace='rgb', languageStyle='LTR', 
    opacity=None, depth=0.0, wrapWidth=None);

###################################
########## INVEST SLIDER ##########
###################################

invest_slider = visual.Slider(
    win=win, name='invest_slider', style='radio', styleTweaks=(), 
    startValue=0, labels=(0, 2, 4, 6, 8, 10), ticks=(0, 2, 4, 6, 8, 10), 
    size=(0.5, 0.03), pos=(0, 0), units=None, flip=False, ori=0, depth=0.0, granularity=0.0, opacity=None,
    labelColor='black', markerColor='darkgrey', lineColor='darkgrey', colorSpace='rgb',
    font='Open Sans', labelHeight=0.03, readOnly=False)

# key-to-slider dictionary
key2slider_invest = {'1':0, '2':2, '3':4, '6':6, '7':8, '8':10}

Choice_Key = keyboard.Keyboard()

feedback_run1 = []
feedback_run2 = []
feedback_run3 = []

#############################
########## OUTCOME ##########
#############################

youAmt = visual.TextStim(
    win=win, name='youAmt',
    text='', font='Open Sans',
    pos=[0,0], height=0.07, wrapWidth=None, ori=0.0, 
    color='black', colorSpace='rgb', opacity=None, 
    languageStyle='LTR', depth=0.0);

outcomes = []

###########################
########## BONUS ##########
###########################

youBonus = visual.TextStim(
    win=win, name='youBonus',
    text='', font='Open Sans',
    pos=[0,0], height=0.07, wrapWidth=None, ori=0.0, 
    color='black', colorSpace='rgb', opacity=None, 
    languageStyle='LTR', depth=0.0);

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.Clock()  # to track time remaining of each (possibly non-slip) routine 

# Create run counters
run1_total_duration = 0
run2_total_duration = 0
run3_total_duration = 0

####################################################################################################
############################################ EXPERIMENT ############################################
####################################################################################################

##################################
########## INSTRUCTIONS ##########
##################################

# --- Prepare to start Routine "Instructions" ---
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

# --- Run Routine "Instructions" ---
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
        Instr_Txt.frameNStart = frameN  # exact frame index
        Instr_Txt.tStart = t  # local t and not account for scr refresh
        Instr_Txt.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(Instr_Txt, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'Instr_Txt.started')
        Instr_Txt.setAutoDraw(True)
    
    # *Instr_Key* updates
    waitOnFlip = False
    if Instr_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        Instr_Key.frameNStart = frameN  # exact frame index
        Instr_Key.tStart = t  # local t and not account for scr refresh
        Instr_Key.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(Instr_Key, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'Instr_Key.started')
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

# --- Ending Routine "Instructions" ---
for thisComponent in InstructionsComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)

# save page onset
thisExp.addData('Instr_Txt.started', Instr_Txt.tStartRefresh)
# save page offset
try:
    thisExp.addData('Instr_Txt.stopped', float(Instr_Txt.tStartRefresh) + float(Instr_Key.rt))
except:
    thisExp.addData('Instr_Txt.stopped', None)
# save response time
if Instr_Key.keys != None:  # we had a response
    thisExp.addData('Instr_Key.rt', Instr_Key.rt)
# move to next line
thisExp.nextEntry()
# the Routine "Instructions" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

if fMRI_flag == 1:
    ######################################
    ########## WAIT FOR SCANNER ##########
    ######################################

    # --- Prepare to start Routine "WaitForScanner" ---
    continueRoutine = True
    routineForceEnded = False
    # update component parameters for each repeat
    WaitForScanner_Key.keys = []
    WaitForScanner_Key.rt = []
    WaitForScanner_Key_allKeys = []
    # keep track of which components have finished
    WaitForScannerComponents = [WaitForScanner_Key, WaitForScanner_Txt]
    for thisComponent in WaitForScannerComponents:
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

    # --- Run Routine "WaitForScanner" ---
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
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'WaitForScanner_Txt.started')
            WaitForScanner_Txt.setAutoDraw(True)

        # *WaitForScanner_Key* updates
        waitOnFlip = False
        if WaitForScanner_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            WaitForScanner_Key.frameNStart = frameN  # exact frame index
            WaitForScanner_Key.tStart = t  # local t and not account for scr refresh
            WaitForScanner_Key.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(WaitForScanner_Key, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'WaitForScanner_Key.started')
            WaitForScanner_Key.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(WaitForScanner_Key.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(WaitForScanner_Key.clearEvents, eventType='keyboard')  # clear events on next screen flip
        if WaitForScanner_Key.status == STARTED and not waitOnFlip:
            theseKeys = WaitForScanner_Key.getKeys(keyList=['5'], waitRelease=False)
            WaitForScanner_Key_allKeys.extend(theseKeys)
            if len(WaitForScanner_Key_allKeys):
                WaitForScanner_Key.keys = WaitForScanner_Key_allKeys[-1].name  # just the last key pressed
                WaitForScanner_Key.rt = WaitForScanner_Key_allKeys[-1].rt
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
        for thisComponent in WaitForScannerComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()

    # --- Ending Routine "WaitForScanner" ---
    for thisComponent in WaitForScannerComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)

    # save page onset
    thisExp.addData('WaitForScanner_Txt.started', WaitForScanner_Txt.tStartRefresh)
    # save page offset
    try:
        thisExp.addData('WaitForScanner_Txt.started', float(WaitForScanner_Txt.tStartRefresh) + float(WaitForScanner_Key.rt))
    except:
        thisExp.addData('WaitForScanner_Txt.started', None)
    # save scanner response time
    if WaitForScanner_Key.keys != None:  # we had a response
        thisExp.addData('WaitForScanner_Key.rt', WaitForScanner_Key.rt)
    # move to next line
    thisExp.nextEntry()
    # the Routine "WaitForScanner" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
else:
    pass

#######################################
########## PRETRIAL FIXATION ##########
#######################################

# --- Prepare to start Routine "PretrialFixation" ---
continueRoutine = True
routineForceEnded = False

# update component parameters for each repeat
PreFix = jitter
PreFix_duration = 10.000

# add to the run duration counter
run1_total_duration += PreFix_duration

# keep track of which components have finished
PretrialFixationComponents = [PreFix]
for thisComponent in PretrialFixationComponents:
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

# --- Run Routine "PretrialFixation" ---
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
        if EEG_flag == 1:
            port.write(bytes([255]))
    if PreFix.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > PreFix.tStartRefresh + (PreFix_duration-frameTolerance):
            if EEG_flag == 1:
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

# --- Ending Routine "PretrialFixation" ---
for thisComponent in PretrialFixationComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)

# save page onset
thisExp.addData('PreFix.started', PreFix.tStartRefresh)
# save page offset
try:
    thisExp.addData('PreFix.stopped', float(PreFix.tStartRefresh) + float(PreFix_duration))
except:
    thisExp.addData('PreFix.stopped', None)
# move to next line
thisExp.nextEntry()

# using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
if routineForceEnded:
    routineTimer.reset()
else:
    routineTimer.addTime(-PreFix_duration)

###########################
########## RUN 1 ##########
###########################

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
    
    ##################################
    ########## INTRODUCTION ##########
    ##################################

    # --- Prepare to start Routine "Introduction" ---
    continueRoutine = True
    routineForceEnded = False
    
    # update component parameters for each repeat
    partner = partner_dict[Stimuli]
    partner.setSize([0.5, 0.5])
    partner.setPos([0, 0])
    Partner_duration = 2.000
    
    # add to the run duration counter
    run1_total_duration += Partner_duration
    
    # keep track of which components have finished
    IntroductionComponents = [partner, partnerintro_Txt]
    for thisComponent in IntroductionComponents:
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

    # --- Run Routine "Introduction" ---
    while continueRoutine and routineTimer.getTime() < Partner_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *partner* updates
        if partner.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            partner.frameNStart = frameN  # exact frame index
            partner.tStart = t  # local t and not account for scr refresh
            partner.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(partner, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'partner.started')
            partner.setAutoDraw(True)
            if EEG_flag == 1:
                port.write(bytes([Trigger]))
        if partner.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > partner.tStartRefresh + (Partner_duration-frameTolerance):
                if EEG_flag == 1:
                    port.write(bytes([Trigger]))
                # keep track of stop time/frame for later
                partner.tStop = t  # not accounting for scr refresh
                partner.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'partner.stopped')
                partner.setAutoDraw(False)
        
        # *partnerintro_Txt* updates
        if partnerintro_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            partnerintro_Txt.frameNStart = frameN  # exact frame index
            partnerintro_Txt.tStart = t  # local t and not account for scr refresh
            partnerintro_Txt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(partnerintro_Txt, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'partnerintro_Txt.started')
            partnerintro_Txt.setAutoDraw(True)
        if partnerintro_Txt.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > partnerintro_Txt.tStartRefresh + (Partner_duration-frameTolerance):
                # keep track of stop time/frame for later
                partnerintro_Txt.tStop = t  # not accounting for scr refresh
                partnerintro_Txt.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'partnerintro_Txt.stopped')
                partnerintro_Txt.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in IntroductionComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "Introduction" ---
    for thisComponent in IntroductionComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    
    # save page onset
    RUN1.addData('partner.started', partner.tStartRefresh)
    # save page offset
    try:
        RUN1.addData('partner.stopped', float(partner.tStartRefresh) + float(Partner_duration))
    except:
        RUN1.addData('partner.stopped', None)
    
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-Partner_duration)
    
    #########################
    ########## ISI ##########
    #########################

    # --- Prepare to start Routine "ISI" ---
    continueRoutine = True
    routineForceEnded = False
    
    # update component parameters for each repeat
    isi = jitter
    isi_duration = float(ISI_revised)
    
    # add to the run duration counter
    run1_total_duration += isi_duration
    
    # keep track of which components have finished
    ISIComponents = [isi]
    for thisComponent in ISIComponents:
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
    
    # --- Run Routine "ISI" ---
    while continueRoutine and routineTimer.getTime() < isi_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *isi* updates
        if isi.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            isi.frameNStart = frameN  # exact frame index
            isi.tStart = t  # local t and not account for scr refresh
            isi.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(isi, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'isi.started')
            isi.setAutoDraw(True)
            if EEG_flag == 1:
                port.write(bytes([255]))
        if isi.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > isi.tStartRefresh + (isi_duration-frameTolerance):
                if EEG_flag == 1:
                    port.write(bytes([255]))
                # keep track of stop time/frame for later
                isi.tStop = t  # not accounting for scr refresh
                isi.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'isi.stopped')
                isi.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in ISIComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "ISI" ---
    for thisComponent in ISIComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    
    # save page onset
    RUN1.addData('isi.started', isi.tStartRefresh)
    # save page offset
    try:
        RUN1.addData('isi.stopped', float(isi.tStartRefresh) + float(isi_duration))
    except:
        RUN1.addData('isi.stopped', None)

    
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-isi_duration)
    
    ############################
    ########## CHOICE ##########
    ############################

    # --- Prepare to start Routine "Choice" ---
    continueRoutine = True
    routineForceEnded = False
    win.mouseVisible = False
    
    # update component parameters for each repeat
    Choice_duration = 4.050
    partner.setSize([0.20, 0.20])
    partner.setPos([0.30, 0.30])
    you.setPos([-0.30, 0.30])
    invest_slider.reset()
    invest_slider.marker.opacity = 0.0
    invest_slider.marker.color = 'darkgrey'

    # add to the run duration counter
    run1_total_duration += Choice_duration

    # initialize key lists
    Choice_Key.keys = []
    Choice_Key.rt = []
    _Choice_Key_allKeys = []

    # keep track of which components have finished
    ChoiceComponents = [partner, you, keep, invest, invest_slider, Choice_Key]
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
    
    # --- Run Routine "Choice" ---
    while continueRoutine and routineTimer.getTime() < Choice_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *partner* updates
        if partner.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            partner.frameNStart = frameN  # exact frame index
            partner.tStart = t  # local t and not account for scr refresh
            partner.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(partner, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'partner.started')
            partner.setAutoDraw(True)
            if EEG_flag == 1:
                port.write(bytes([Trigger]))
        if partner.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > partner.tStartRefresh + (Choice_duration-frameTolerance):
                if EEG_flag == 1:
                    port.write(bytes([Trigger]))
                # keep track of stop time/frame for later
                partner.tStop = t  # not accounting for scr refresh
                partner.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'partner.stopped')
                partner.setAutoDraw(False)
        
        # *you* updates
        if you.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            you.frameNStart = frameN  # exact frame index
            you.tStart = t  # local t and not account for scr refresh
            you.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(you, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'you.started')
            you.setAutoDraw(True)
        if you.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > you.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                you.tStop = t  # not accounting for scr refresh
                you.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'you.stopped')
                you.setAutoDraw(False)
        
        # *keep* updates
        if keep.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            keep.frameNStart = frameN  # exact frame index
            keep.tStart = t  # local t and not account for scr refresh
            keep.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(keep, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'keep.started')
            keep.setAutoDraw(True)
        if keep.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > keep.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                keep.tStop = t  # not accounting for scr refresh
                keep.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'keep.stopped')
                keep.setAutoDraw(False)
        
        # *invest* updates
        if invest.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            invest.frameNStart = frameN  # exact frame index
            invest.tStart = t  # local t and not account for scr refresh
            invest.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(invest, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'invest.started')
            invest.setAutoDraw(True)
        if invest.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > invest.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                invest.tStop = t  # not accounting for scr refresh
                invest.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'invest.stopped')
                invest.setAutoDraw(False)
        
        # *invest_slider* updates
        if invest_slider.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            invest_slider.frameNStart = frameN  # exact frame index
            invest_slider.tStart = t  # local t and not account for scr refresh
            invest_slider.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(invest_slider, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'invest_slider.started')
            invest_slider.setAutoDraw(True)
            invest_slider.setMarkerPos = None
        if invest_slider.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > invest_slider.tStartRefresh + Choice_duration-frameTolerance:
                # keep track of stop time/frame for later
                invest_slider.tStop = t  # not accounting for scr refresh
                invest_slider.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'invest_slider.stopped')
                invest_slider.setAutoDraw(False)

        # *Choice_Key* updates
        waitOnFlip = False
        if Choice_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Choice_Key.frameNStart = frameN  # exact frame index
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
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > Choice_Key.tStartRefresh + (Choice_duration-frameTolerance):
                # keep track of stop time/frame for later
                Choice_Key.tStop = t  # not accounting for scr refresh
                Choice_Key.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Choice_Key.stopped')
                Choice_Key.status = FINISHED
        if Choice_Key.status == STARTED and not waitOnFlip:
            theseKeys = Choice_Key.getKeys(keyList=['1','2','3','6','7','8'], waitRelease=False)
            if theseKeys:
                _Choice_Key_allKeys.extend(theseKeys)
                # move invest_slider marker
                if str(int(theseKeys[-1].name)) in key2slider_invest.keys():
                    invest_slider.marker.opacity = 1.0
                    invest_slider.marker.color = 'black'
                    invest_slider.markerPos = key2slider_invest[str(int(theseKeys[-1].name))]
                    invest_slider.rating = key2slider_invest[str(int(theseKeys[-1].name))]
            if len(_Choice_Key_allKeys):
                Choice_Key.keys = _Choice_Key_allKeys[-1].name  # just the last key pressed
                Choice_Key.rt = _Choice_Key_allKeys[-1].rt
                invest_slider.rating = key2slider_invest[str(int(_Choice_Key_allKeys[-1].name))] # money trusted
        
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
    
    # --- Ending Routine "Choice" ---
    for thisComponent in ChoiceComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # check responses
    if Choice_Key.keys in ['', [], None]:  # No response was made
        Choice_Key.keys = None
    # save key response
    RUN1.addData('Choice_Key.keys',Choice_Key.keys)
    if Choice_Key.keys != None:  # we had a response
        # save key rt
        RUN1.addData('Choice_Key.rt', Choice_Key.rt)
    # save investment based on key response
    if Choice_Key.keys == '1':
        investment = 0
        kept = 10
    elif Choice_Key.keys == '2':
        investment = 2
        kept = 8
    elif Choice_Key.keys == '3':
        investment = 4
        kept = 6
    elif Choice_Key.keys == '6':
        investment = 6
        kept = 4
    elif Choice_Key.keys == '7':
        investment = 8
        kept = 2
    elif Choice_Key.keys == '8':
        investment = 10
        kept = 0
    else:
        investment = None
        kept = 0
    RUN1.addData('investment',investment)
    RUN1.addData('kept',kept)
    # save feedback based on investment
    if investment is not None:
        if Feedback == "POSFB":
            feedback = (investment*3)/2
            total = kept + feedback
        elif Feedback == "NEGFB":
            feedback = 0
            total = kept
    else:
        feedback = None
        total = 0
    RUN1.addData('feedback',feedback)
    RUN1.addData('total',total)
    # also save feedback in list for later
    feedback_run1.append(total)
    # save page onset
    RUN1.addData('Choice.started', you.tStartRefresh)
    # save page offset
    try:
        RUN1.addData('Choice.stopped', float(you.tStartRefresh) + float(Choice_duration))
    except:
        RUN1.addData('Choice.stopped', None)
    
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-Choice_duration)
    
    #########################
    ########## ITI ##########
    #########################

    # --- Prepare to start Routine "ITI" ---
    continueRoutine = True
    routineForceEnded = False
    
    # update component parameters for each repeat
    iti = jitter
    iti_duration = float(ITI_revised)

    # add to the run duration counter
    run1_total_duration += iti_duration
    
    # keep track of which components have finished
    ITIComponents = [iti]
    for thisComponent in ITIComponents:
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
    
    # --- Run Routine "ITI" ---
    while continueRoutine and routineTimer.getTime() < iti_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *iti* updates
        if iti.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            iti.frameNStart = frameN  # exact frame index
            iti.tStart = t  # local t and not account for scr refresh
            iti.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(iti, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'iti.started')
            iti.setAutoDraw(True)
            if EEG_flag == 1:
                port.write(bytes([255]))
        if iti.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > iti.tStartRefresh + iti_duration-frameTolerance:
                if EEG_flag == 1:
                    port.write(bytes([255]))
                # keep track of stop time/frame for later
                iti.tStop = t  # not accounting for scr refresh
                iti.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'iti.stopped')
                iti.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in ITIComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "ITI" ---
    for thisComponent in ITIComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # save page onset
    RUN1.addData('iti.started', iti.tStartRefresh)
    # save page offset
    try:
        RUN1.addData('iti.stopped', float(iti.tStartRefresh) + float(iti_duration))
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

#############################
########## OUTCOME ##########
#############################

# --- Prepare to start Routine "Outcome" ---
continueRoutine = True
routineForceEnded = False

# update component parameters for each repeat
outcome_run1 = randchoice(feedback_run1)
outcomes.append(outcome_run1)
outcome_text = f"You won ${outcome_run1} in run 1!"
youAmt.setText(outcome_text)
youAmt.setPos([0, 0.15])
Outcome_duration = 3.500

# add to the run duration counter
run1_total_duration += Outcome_duration

# keep track of which components have finished
OutcomeComponents = [youAmt]
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

# --- Run Routine "Outcome" ---
while continueRoutine and routineTimer.getTime() < Outcome_duration:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *youAmt* updates
    if youAmt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        youAmt.frameNStart = frameN  # exact frame index
        youAmt.tStart = t  # local t and not account for scr refresh
        youAmt.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(youAmt, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'youAmt.started')
        youAmt.setAutoDraw(True)
        if EEG_flag == 1:
            port.write(bytes([FeedbackTrigger]))
    if youAmt.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > youAmt.tStartRefresh + (Outcome_duration-frameTolerance):
            if EEG_flag == 1:
                port.write(bytes([FeedbackTrigger]))
            # keep track of stop time/frame for later
            youAmt.tStop = t  # not accounting for scr refresh
            youAmt.frameNStop = frameN  # exact frame index
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'youAmt.stopped')
            youAmt.setAutoDraw(False)
    
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

# --- Ending Routine "Outcome" ---
for thisComponent in OutcomeComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)

# save page onset
thisExp.addData('Outcome.started', youAmt.tStartRefresh)
# save page offset
try:
    thisExp.addData('Outcome.stopped', float(youAmt.tStartRefresh) + float(Outcome_duration))
except:
    thisExp.addData('Outcome.stopped', None)
# move to next line
thisExp.nextEntry()

# using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
if routineForceEnded:
    routineTimer.reset()
else:
    routineTimer.addTime(-Outcome_duration)

########################################
########## POSTTRIAL FIXATION ##########
########################################

# --- Prepare to start Routine "PosttrialFixation" ---
continueRoutine = True
routineForceEnded = False

# update component parameters for each repeat
PostFix = jitter
PostFix_duration = 597.80 - run1_total_duration
# if round(run1_total_duration % tr, 2) == 0:
#     PostFix_duration = float(tr * 8)
# else:
#     PostFix_duration = float((tr * 8) + (tr - round(run1_total_duration % tr, 2)))

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

# --- Run Routine "PosttrialFixation" ---
while continueRoutine and routineTimer.getTime() < PostFix_duration:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *PostFix* updates
    if PostFix.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        PostFix.frameNStart = frameN  # exact frame index
        PostFix.tStart = t  # local t and not account for scr refresh
        PostFix.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(PostFix, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'PostFix.started')
        PostFix.setAutoDraw(True)
        if EEG_flag == 1:
            port.write(bytes([255]))
    if PostFix.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > PostFix.tStartRefresh + (PostFix_duration-frameTolerance):
            if EEG_flag == 1:
                port.write(bytes([255]))
            # keep track of stop time/frame for later
            PostFix.tStop = t  # not accounting for scr refresh
            PostFix.frameNStop = frameN  # exact frame index
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

# --- Ending Routine "PosttrialFixation" ---
for thisComponent in PosttrialFixationComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)

# save page onset
thisExp.addData('PostFix.started', PostFix.tStartRefresh)
# save page offset
try:
    thisExp.addData('PostFix.stopped', float(PostFix.tStartRefresh) + float(PostFix_duration))
except:
    thisExp.addData('PostFix.stopped', None)
# move to next line
thisExp.nextEntry()

# using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
if routineForceEnded:
    routineTimer.reset()
else:
    routineTimer.addTime(-PostFix_duration)

########################################
########## POST-RUN1 CHECK-IN ##########
########################################

# ------Prepare to start Routine "Postrun1"-------
continueRoutine = True

# update component parameters for each repeat
Postrun_Key.keys = []
Postrun_Key.rt = []
_Postrun_Key_allKeys = []

# keep track of which components have finished
PostrunComponents = [Postrun_Txt, Postrun_Key]
for thisComponent in PostrunComponents:
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

# -------Run Routine "Postrun1"-------
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *Postrun_Txt* updates
    if Postrun_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        Postrun_Txt.frameNStart = frameN  # exact frame index
        Postrun_Txt.tStart = t  # local t and not account for scr refresh
        Postrun_Txt.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(Postrun_Txt, 'tStartRefresh')  # time at next scr refresh
        Postrun_Txt.setAutoDraw(True)
    
    # *Postrun_Key* updates
    waitOnFlip = False
    if Postrun_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        Postrun_Key.frameNStart = frameN  # exact frame index
        Postrun_Key.tStart = t  # local t and not account for scr refresh
        Postrun_Key.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(Postrun_Key, 'tStartRefresh')  # time at next scr refresh
        Postrun_Key.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(Postrun_Key.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(Postrun_Key.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if Postrun_Key.status == STARTED and not waitOnFlip:
        theseKeys = Postrun_Key.getKeys(keyList=['z','m'], waitRelease=False)
        _Postrun_Key_allKeys.extend(theseKeys)
        if len(_Postrun_Key_allKeys):
            Postrun_Key.keys = _Postrun_Key_allKeys[-1].name  # just the last key pressed
            Postrun_Key.rt = _Postrun_Key_allKeys[-1].rt
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in PostrunComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# -------Ending Routine "Postrun1"-------
for thisComponent in PostrunComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)

# save page onset
thisExp.addData('Postrun_Txt.started', Postrun_Txt.tStartRefresh)
# save page offset
try:
    thisExp.addData('Postrun_Txt.started', float(Postrun_Txt.tStartRefresh) + float(Postrun_Key.rt))
except:
    thisExp.addData('Postrun_Txt.started', None)
# save scanner response time
if Postrun_Key.keys != None:  # we had a response
    thisExp.addData('Postrun_Key.rt', Postrun_Key.rt)
# move to next line
thisExp.nextEntry()
# the Routine "Postrun1" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

if Postrun_Key.keys == 'z':
    if fMRI_flag == 1:
        ######################################
        ########## WAIT FOR SCANNER ##########
        ######################################

        # --- Prepare to start Routine "WaitForScanner" ---
        continueRoutine = True
        routineForceEnded = False

        # update component parameters for each repeat
        WaitForScanner_Key.keys = []
        WaitForScanner_Key.rt = []
        WaitForScanner_Key_allKeys = []

        # keep track of which components have finished
        WaitForScannerComponents = [WaitForScanner_Key, WaitForScanner_Txt]
        for thisComponent in WaitForScannerComponents:
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

        # --- Run Routine "WaitForScanner" ---
        while continueRoutine:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *WaitForScanner_Key* updates
            waitOnFlip = False
            if WaitForScanner_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                WaitForScanner_Key.frameNStart = frameN  # exact frame index
                WaitForScanner_Key.tStart = t  # local t and not account for scr refresh
                WaitForScanner_Key.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(WaitForScanner_Key, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'WaitForScanner_Key.started')
                WaitForScanner_Key.status = STARTED
                # keyboard checking is just starting
                waitOnFlip = True
                win.callOnFlip(WaitForScanner_Key.clock.reset)  # t=0 on next screen flip
                win.callOnFlip(WaitForScanner_Key.clearEvents, eventType='keyboard')  # clear events on next screen flip
            if WaitForScanner_Key.status == STARTED and not waitOnFlip:
                theseKeys = WaitForScanner_Key.getKeys(keyList=['5'], waitRelease=False)
                WaitForScanner_Key_allKeys.extend(theseKeys)
                if len(WaitForScanner_Key_allKeys):
                    WaitForScanner_Key.keys = WaitForScanner_Key_allKeys[-1].name  # just the last key pressed
                    WaitForScanner_Key.rt = WaitForScanner_Key_allKeys[-1].rt
                    # a response ends the routine
                    continueRoutine = False
            
            # *WaitForScanner_Txt* updates
            if WaitForScanner_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                WaitForScanner_Txt.frameNStart = frameN  # exact frame index
                WaitForScanner_Txt.tStart = t  # local t and not account for scr refresh
                WaitForScanner_Txt.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(WaitForScanner_Txt, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'WaitForScanner_Txt.started')
                WaitForScanner_Txt.setAutoDraw(True)
            
            # check for quit (typically the Esc key)
            if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
                core.quit()
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineForceEnded = True
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in WaitForScannerComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()

        # --- Ending Routine "WaitForScanner" ---
        for thisComponent in WaitForScannerComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        # save page onset
        thisExp.addData('WaitForScanner_Txt.started', WaitForScanner_Txt.tStartRefresh)
        # save page offset
        try:
            thisExp.addData('WaitForScanner_Txt.started', float(WaitForScanner_Txt.tStartRefresh) + float(WaitForScanner_Key.rt))
        except:
            thisExp.addData('WaitForScanner_Txt.started', None)
        # save scanner response time
        if WaitForScanner_Key.keys != None:  # we had a response
            thisExp.addData('WaitForScanner_Key.rt', WaitForScanner_Key.rt)
        # move to next line
        thisExp.nextEntry()
        # the Routine "WaitForScanner" was not non-slip safe, so reset the non-slip timer
        routineTimer.reset()
    else:
        pass

    ######################################
    ########## PRETRIALFIXATION ##########
    ######################################

    # --- Prepare to start Routine "PretrialFixation" ---
    continueRoutine = True
    routineForceEnded = False

    # update component parameters for each repeat
    PreFix = jitter
    PreFix_duration = 10.000

    # add to the run duration counter
    run2_total_duration += PreFix_duration

    # keep track of which components have finished
    PretrialFixationComponents = [PreFix]
    for thisComponent in PretrialFixationComponents:
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

    # --- Run Routine "PretrialFixation" ---
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
            if EEG_flag == 1:
                port.write(bytes([255]))
        if PreFix.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > PreFix.tStartRefresh + PreFix_duration-frameTolerance:
                if EEG_flag == 1:
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

    # --- Ending Routine "PretrialFixation" ---
    for thisComponent in PretrialFixationComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)

    # save page onset
    thisExp.addData('PreFix.started', PreFix.tStartRefresh)
    # save page offset
    try:
        thisExp.addData('PreFix.stopped', float(PreFix.tStartRefresh) + float(PreFix_duration))
    except:
        thisExp.addData('PreFix.stopped', None)
    # move to next line
    thisExp.nextEntry()

    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-PreFix_duration)

    ###########################
    ########## RUN 2 ##########
    ###########################

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
        
        ##################################
        ########## INTRODUCTION ##########
        ##################################

        # --- Prepare to start Routine "Introduction" ---
        continueRoutine = True
        routineForceEnded = False
        
        # update component parameters for each repeat
        partner = partner_dict[Stimuli]
        partner.setSize([0.50, 0.50])
        partner.setPos([0, 0])
        Partner_duration = 2.000

        # add to the run duration counter
        run2_total_duration += Partner_duration
        
        # keep track of which components have finished
        IntroductionComponents = [partner, partnerintro_Txt]
        for thisComponent in IntroductionComponents:
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
        
        # --- Run Routine "Introduction" ---
        while continueRoutine and routineTimer.getTime() < Partner_duration:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *partner* updates
            if partner.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                partner.frameNStart = frameN  # exact frame index
                partner.tStart = t  # local t and not account for scr refresh
                partner.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(partner, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'partner.started')
                partner.setAutoDraw(True)
                if EEG_flag == 1:
                    port.write(bytes([Trigger]))
            if partner.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > partner.tStartRefresh + (Partner_duration-frameTolerance):
                    if EEG_flag == 1:
                        port.write(bytes([Trigger]))
                    # keep track of stop time/frame for later
                    partner.tStop = t  # not accounting for scr refresh
                    partner.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'partner.stopped')
                    partner.setAutoDraw(False)
            
            # *partnerintro_Txt* updates
            if partnerintro_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                partnerintro_Txt.frameNStart = frameN  # exact frame index
                partnerintro_Txt.tStart = t  # local t and not account for scr refresh
                partnerintro_Txt.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(partnerintro_Txt, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'partnerintro_Txt.started')
                partnerintro_Txt.setAutoDraw(True)
            if partnerintro_Txt.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > partnerintro_Txt.tStartRefresh + (Partner_duration-frameTolerance):
                    # keep track of stop time/frame for later
                    partnerintro_Txt.tStop = t  # not accounting for scr refresh
                    partnerintro_Txt.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'partnerintro_Txt.stopped')
                    partnerintro_Txt.setAutoDraw(False)
            
            # check for quit (typically the Esc key)
            if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
                core.quit()
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineForceEnded = True
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in IntroductionComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        # --- Ending Routine "Introduction" ---
        for thisComponent in IntroductionComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        
        # save page onset
        RUN2.addData('partner.started', partner.tStartRefresh)
        # save page offset
        try:
            RUN2.addData('partner.stopped', float(partner.tStartRefresh) + float(Partner_duration))
        except:
            RUN2.addData('partner.stopped', None)
        
        # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
        if routineForceEnded:
            routineTimer.reset()
        else:
            routineTimer.addTime(-Partner_duration)
        
        #########################
        ########## ISI ##########
        #########################

        # --- Prepare to start Routine "ISI" ---
        continueRoutine = True
        routineForceEnded = False
        
        # update component parameters for each repeat
        isi = jitter
        isi_duration = float(ISI_revised)

        # add to the run duration counter
        run2_total_duration += isi_duration
        
        # keep track of which components have finished
        ISIComponents = [isi]
        for thisComponent in ISIComponents:
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
        
        # --- Run Routine "ISI" ---
        while continueRoutine and routineTimer.getTime() < isi_duration:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *isi* updates
            if isi.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                isi.frameNStart = frameN  # exact frame index
                isi.tStart = t  # local t and not account for scr refresh
                isi.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(isi, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'isi.started')
                isi.setAutoDraw(True)
                if EEG_flag == 1:
                    port.write(bytes([255]))
            if isi.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > isi.tStartRefresh + isi_duration-frameTolerance:
                    if EEG_flag == 1:
                        port.write(bytes([255]))
                    # keep track of stop time/frame for later
                    isi.tStop = t  # not accounting for scr refresh
                    isi.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'isi.stopped')
                    isi.setAutoDraw(False)
            
            # check for quit (typically the Esc key)
            if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
                core.quit()
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineForceEnded = True
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in ISIComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        # --- Ending Routine "ISI" ---
        for thisComponent in ISIComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        
        # save page onset
        RUN2.addData('isi.started', isi.tStartRefresh)
        # save page offset
        try:
            RUN2.addData('isi.stopped', float(isi.tStartRefresh) + float(isi_duration))
        except:
            RUN2.addData('isi.stopped', None)
        
        # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
        if routineForceEnded:
            routineTimer.reset()
        else:
            routineTimer.addTime(-isi_duration)
        
        ############################
        ########## CHOICE ##########
        ############################

        # --- Prepare to start Routine "Choice" ---
        continueRoutine = True
        routineForceEnded = False
        win.mouseVisible = False

        # update component parameters for each repeat
        Choice_duration = 4.050
        partner.setSize([0.20, 0.20])
        partner.setPos([0.30, 0.30])
        you.setPos([-0.30, 0.30])
        invest_slider.reset()
        invest_slider.marker.opacity = 0.0
        invest_slider.marker.color = 'darkgrey'

        # add to the run duration counter
        run2_total_duration += Choice_duration

        # initialize key lists
        Choice_Key.keys = []
        Choice_Key.rt = []
        _Choice_Key_allKeys = []

        # keep track of which components have finished
        ChoiceComponents = [partner, you, keep, invest, invest_slider, Choice_Key]
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
        
        # --- Run Routine "Choice" ---
        while continueRoutine and routineTimer.getTime() < Choice_duration:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *partner* updates
            if partner.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                partner.frameNStart = frameN  # exact frame index
                partner.tStart = t  # local t and not account for scr refresh
                partner.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(partner, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'partner.started')
                partner.setAutoDraw(True)
                if EEG_flag == 1:
                    port.write(bytes([Trigger]))
            if partner.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > partner.tStartRefresh + (Choice_duration-frameTolerance):
                    if EEG_flag == 1:
                        port.write(bytes([Trigger]))
                    # keep track of stop time/frame for later
                    partner.tStop = t  # not accounting for scr refresh
                    partner.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'partner.stopped')
                    partner.setAutoDraw(False)
            
            # *you* updates
            if you.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                you.frameNStart = frameN  # exact frame index
                you.tStart = t  # local t and not account for scr refresh
                you.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(you, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'you.started')
                you.setAutoDraw(True)
            if you.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > you.tStartRefresh + (Choice_duration-frameTolerance):
                    # keep track of stop time/frame for later
                    you.tStop = t  # not accounting for scr refresh
                    you.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'you.stopped')
                    you.setAutoDraw(False)
            
            # *keep* updates
            if keep.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                keep.frameNStart = frameN  # exact frame index
                keep.tStart = t  # local t and not account for scr refresh
                keep.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(keep, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'keep.started')
                keep.setAutoDraw(True)
            if keep.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > keep.tStartRefresh + (Choice_duration-frameTolerance):
                    # keep track of stop time/frame for later
                    keep.tStop = t  # not accounting for scr refresh
                    keep.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'keep.stopped')
                    keep.setAutoDraw(False)
            
            # *invest* updates
            if invest.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                invest.frameNStart = frameN  # exact frame index
                invest.tStart = t  # local t and not account for scr refresh
                invest.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(invest, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'invest.started')
                invest.setAutoDraw(True)
            if invest.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > invest.tStartRefresh + (Choice_duration-frameTolerance):
                    # keep track of stop time/frame for later
                    invest.tStop = t  # not accounting for scr refresh
                    invest.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'invest.stopped')
                    invest.setAutoDraw(False)
            
            # *invest_slider* updates
            if invest_slider.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                invest_slider.frameNStart = frameN  # exact frame index
                invest_slider.tStart = t  # local t and not account for scr refresh
                invest_slider.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(invest_slider, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'invest_slider.started')
                invest_slider.setAutoDraw(True)
                invest_slider.setMarkerPos = None
            if invest_slider.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > invest_slider.tStartRefresh + Choice_duration-frameTolerance:
                    # keep track of stop time/frame for later
                    invest_slider.tStop = t  # not accounting for scr refresh
                    invest_slider.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'invest_slider.stopped')
                    invest_slider.setAutoDraw(False)
            
            # *Choice_Key* updates
            waitOnFlip = False
            if Choice_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                Choice_Key.frameNStart = frameN  # exact frame index
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
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > Choice_Key.tStartRefresh + (Choice_duration-frameTolerance):
                    # keep track of stop time/frame for later
                    Choice_Key.tStop = t  # not accounting for scr refresh
                    Choice_Key.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'Choice_Key.stopped')
                    Choice_Key.status = FINISHED
            if Choice_Key.status == STARTED and not waitOnFlip:
                theseKeys = Choice_Key.getKeys(keyList=['1','2','3','6','7','8'], waitRelease=False)
                if theseKeys:
                    _Choice_Key_allKeys.extend(theseKeys)
                    # move invest_slider marker
                    if str(int(theseKeys[-1].name)) in key2slider_invest.keys():
                        invest_slider.marker.opacity = 1.0
                        invest_slider.marker.color = 'black'
                        invest_slider.markerPos = key2slider_invest[str(int(theseKeys[-1].name))]
                        invest_slider.rating = key2slider_invest[str(int(theseKeys[-1].name))]
                if len(_Choice_Key_allKeys):
                    Choice_Key.keys = _Choice_Key_allKeys[-1].name  # just the last key pressed
                    Choice_Key.rt = _Choice_Key_allKeys[-1].rt
                    invest_slider.rating = key2slider_invest[str(int(_Choice_Key_allKeys[-1].name))] # money trusted
            
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
        
        # --- Ending Routine "Choice" ---
        for thisComponent in ChoiceComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        # check responses
        if Choice_Key.keys in ['', [], None]:  # No response was made
            Choice_Key.keys = None
        # save key response
        RUN2.addData('Choice_Key.keys',Choice_Key.keys)
        if Choice_Key.keys != None:  # we had a response
            # save key rt
            RUN2.addData('Choice_Key.rt', Choice_Key.rt)
        # save investment based on key response
        if Choice_Key.keys == '1':
            investment = 0
            kept = 10
        elif Choice_Key.keys == '2':
            investment = 2
            kept = 8
        elif Choice_Key.keys == '3':
            investment = 4
            kept = 6
        elif Choice_Key.keys == '6':
            investment = 6
            kept = 4
        elif Choice_Key.keys == '7':
            investment = 8
            kept = 2
        elif Choice_Key.keys == '8':
            investment = 10
            kept = 0
        else:
            investment = None
            kept = 0
        RUN2.addData('investment',investment)
        RUN2.addData('kept',kept)
        # save feedback based on investment
        if investment is not None:
            if Feedback == "POSFB":
                feedback = (investment*3)/2
                total = kept + feedback
            elif Feedback == "NEGFB":
                feedback = 0
                total = kept
        else:
            feedback = None
            total = 0
        RUN2.addData('feedback',feedback)
        RUN2.addData('total',total)
        # also save feedback in list for later
        feedback_run2.append(total)
        # save page onset
        RUN2.addData('Choice.started', you.tStartRefresh)
        # save page offset
        try:
            RUN2.addData('Choice.stopped', float(you.tStartRefresh) + float(Choice_duration))
        except:
            RUN2.addData('Choice.stopped', None)
        
        # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
        if routineForceEnded:
            routineTimer.reset()
        else:
            routineTimer.addTime(-Choice_duration)
        
        #########################
        ########## ITI ##########
        #########################

        # --- Prepare to start Routine "ITI" ---
        continueRoutine = True
        routineForceEnded = False
        
        # update component parameters for each repeat
        iti = jitter
        iti_duration = float(ITI_revised)

        # add to the run duration counter
        run2_total_duration += iti_duration

        # keep track of which components have finished
        ITIComponents = [iti]
        for thisComponent in ITIComponents:
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
        
        # --- Run Routine "ITI" ---
        while continueRoutine and routineTimer.getTime() < iti_duration:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *iti* updates
            if iti.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                iti.frameNStart = frameN  # exact frame index
                iti.tStart = t  # local t and not account for scr refresh
                iti.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(iti, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'iti.started')
                iti.setAutoDraw(True)
                if EEG_flag == 1:
                    port.write(bytes([255]))
            if iti.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > iti.tStartRefresh + iti_duration-frameTolerance:
                    if EEG_flag == 1:
                        port.write(bytes([255]))
                    # keep track of stop time/frame for later
                    iti.tStop = t  # not accounting for scr refresh
                    iti.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'iti.stopped')
                    iti.setAutoDraw(False)
            
            # check for quit (typically the Esc key)
            if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
                core.quit()
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineForceEnded = True
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in ITIComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        # --- Ending Routine "ITI" ---
        for thisComponent in ITIComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        
        # save page onset
        RUN2.addData('iti.started', iti.tStartRefresh)
        # save page offset
        try:
            RUN2.addData('iti.stopped', float(iti.tStartRefresh) + float(iti_duration))
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

    #############################
    ########## OUTCOME ##########
    #############################

    # --- Prepare to start Routine "Outcome" ---
    continueRoutine = True
    routineForceEnded = False

    # update component parameters for each repeat
    outcome_run2 = randchoice(feedback_run2)
    outcomes.append(outcome_run2)
    outcome_text = f"You won ${outcome_run2} in run 2!"
    youAmt.setText(outcome_text)
    youAmt.setPos([0, 0.15])
    Outcome_duration = 3.500

    # add to the run duration counter
    run2_total_duration += Outcome_duration

    # keep track of which components have finished
    OutcomeComponents = [youAmt]
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

    # --- Run Routine "Outcome" ---
    while continueRoutine and routineTimer.getTime() < Outcome_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *youAmt* updates
        if youAmt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            youAmt.frameNStart = frameN  # exact frame index
            youAmt.tStart = t  # local t and not account for scr refresh
            youAmt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(youAmt, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'youAmt.started')
            youAmt.setAutoDraw(True)
            if EEG_flag == 1:
                port.write(bytes([FeedbackTrigger]))
        if youAmt.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > youAmt.tStartRefresh + (Outcome_duration-frameTolerance):
                if EEG_flag == 1:
                    port.write(bytes([FeedbackTrigger]))
                # keep track of stop time/frame for later
                youAmt.tStop = t  # not accounting for scr refresh
                youAmt.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'youAmt.stopped')
                youAmt.setAutoDraw(False)
        
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

    # --- Ending Routine "Outcome" ---
    for thisComponent in OutcomeComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)

    # save page onset
    thisExp.addData('Outcome.started', youAmt.tStartRefresh)
    # save page offset
    try:
        thisExp.addData('Outcome.stopped', float(youAmt.tStartRefresh) + float(Outcome_duration))
    except:
        thisExp.addData('Outcome.stopped', None)
    # move to next line
    thisExp.nextEntry()
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-Outcome_duration)

    ########################################
    ########## POSTTRIAL FIXATION ##########
    ########################################

    # --- Prepare to start Routine "PosttrialFixation" ---
    continueRoutine = True
    routineForceEnded = False
    # update component parameters for each repeat
    PostFix = jitter
    PostFix_duration = 597.80 - run2_total_duration
    # if round(run2_total_duration % tr, 2) == 0:
    #     PostFix_duration = float(tr * 8)
    # else:
    #     PostFix_duration = float((tr * 8) + (tr - round(run2_total_duration % tr, 2)))
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

    # --- Run Routine "PosttrialFixation" ---
    while continueRoutine and routineTimer.getTime() < PostFix_duration:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *PostFix* updates
        if PostFix.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            PostFix.frameNStart = frameN  # exact frame index
            PostFix.tStart = t  # local t and not account for scr refresh
            PostFix.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(PostFix, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'PostFix.started')
            PostFix.setAutoDraw(True)
            if EEG_flag == 1:
                port.write(bytes([255]))
        if PostFix.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > PostFix.tStartRefresh + PostFix_duration-frameTolerance:
                if EEG_flag == 1:
                    port.write(bytes([255]))
                # keep track of stop time/frame for later
                PostFix.tStop = t  # not accounting for scr refresh
                PostFix.frameNStop = frameN  # exact frame index
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

    # --- Ending Routine "PosttrialFixation" ---
    for thisComponent in PosttrialFixationComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)

    # save page onset
    thisExp.addData('PostFix.started', PostFix.tStartRefresh)
    # save page offset
    try:
        thisExp.addData('PostFix.stopped', float(PostFix.tStartRefresh) + float(PostFix_duration))
    except:
        thisExp.addData('PostFix.stopped', None)
    # move to next line
    thisExp.nextEntry()
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-PostFix_duration)

    ########################################
    ########## POST-RUN CHECK-IN ##########
    ########################################

    # ------Prepare to start Routine "Postrun2"-------
    continueRoutine = True

    # update component parameters for each repeat
    Postrun_Key.keys = []
    Postrun_Key.rt = []
    _Postrun_Key_allKeys = []

    # keep track of which components have finished
    PostrunComponents = [Postrun_Txt, Postrun_Key]
    for thisComponent in PostrunComponents:
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

    # -------Run Routine "Postrun2"-------
    while continueRoutine:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *Postrun_Txt* updates
        if Postrun_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Postrun_Txt.frameNStart = frameN  # exact frame index
            Postrun_Txt.tStart = t  # local t and not account for scr refresh
            Postrun_Txt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Postrun_Txt, 'tStartRefresh')  # time at next scr refresh
            Postrun_Txt.setAutoDraw(True)
        
        # *Postrun_Key* updates
        waitOnFlip = False
        if Postrun_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Postrun_Key.frameNStart = frameN  # exact frame index
            Postrun_Key.tStart = t  # local t and not account for scr refresh
            Postrun_Key.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Postrun_Key, 'tStartRefresh')  # time at next scr refresh
            Postrun_Key.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(Postrun_Key.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(Postrun_Key.clearEvents, eventType='keyboard')  # clear events on next screen flip
        if Postrun_Key.status == STARTED and not waitOnFlip:
            theseKeys = Postrun_Key.getKeys(keyList=['z','m'], waitRelease=False)
            _Postrun_Key_allKeys.extend(theseKeys)
            if len(_Postrun_Key_allKeys):
                Postrun_Key.keys = _Postrun_Key_allKeys[-1].name  # just the last key pressed
                Postrun_Key.rt = _Postrun_Key_allKeys[-1].rt
                # a response ends the routine
                continueRoutine = False
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in PostrunComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()

    # -------Ending Routine "Postrun2"-------
    for thisComponent in PostrunComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)

    # save page onset
    thisExp.addData('Postrun_Txt.started', Postrun_Txt.tStartRefresh)
    # save page offset
    try:
        thisExp.addData('Postrun_Txt.started', float(Postrun_Txt.tStartRefresh) + float(Postrun_Key.rt))
    except:
        thisExp.addData('Postrun_Txt.started', None)
    # save scanner response time
    if Postrun_Key.keys != None:  # we had a response
        thisExp.addData('Postrun_Key.rt', Postrun_Key.rt)
    # move to next line
    thisExp.nextEntry()
    # the Routine "Postrun2" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()

    if Postrun_Key.keys == 'z':
        if fMRI_flag == 1:
            ######################################
            ########## WAIT FOR SCANNER ##########
            ######################################

            # --- Prepare to start Routine "WaitForScanner" ---
            continueRoutine = True
            routineForceEnded = False
            # update component parameters for each repeat
            WaitForScanner_Key.keys = []
            WaitForScanner_Key.rt = []
            WaitForScanner_Key_allKeys = []
            # keep track of which components have finished
            WaitForScannerComponents = [WaitForScanner_Key, WaitForScanner_Txt]
            for thisComponent in WaitForScannerComponents:
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

            # --- Run Routine "WaitForScanner" ---
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
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'WaitForScanner_Txt.started')
                    WaitForScanner_Txt.setAutoDraw(True)
                
                # *WaitForScanner_Key* updates
                waitOnFlip = False
                if WaitForScanner_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    WaitForScanner_Key.frameNStart = frameN  # exact frame index
                    WaitForScanner_Key.tStart = t  # local t and not account for scr refresh
                    WaitForScanner_Key.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(WaitForScanner_Key, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'WaitForScanner_Key.started')
                    WaitForScanner_Key.status = STARTED
                    # keyboard checking is just starting
                    waitOnFlip = True
                    win.callOnFlip(WaitForScanner_Key.clock.reset)  # t=0 on next screen flip
                    win.callOnFlip(WaitForScanner_Key.clearEvents, eventType='keyboard')  # clear events on next screen flip
                if WaitForScanner_Key.status == STARTED and not waitOnFlip:
                    theseKeys = WaitForScanner_Key.getKeys(keyList=['5'], waitRelease=False)
                    WaitForScanner_Key_allKeys.extend(theseKeys)
                    if len(WaitForScanner_Key_allKeys):
                        WaitForScanner_Key.keys = WaitForScanner_Key_allKeys[-1].name  # just the last key pressed
                        WaitForScanner_Key.rt = WaitForScanner_Key_allKeys[-1].rt
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
                for thisComponent in WaitForScannerComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()

            # --- Ending Routine "WaitForScanner" ---
            for thisComponent in WaitForScannerComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)

            # save page onset
            thisExp.addData('WaitForScanner_Txt.started', WaitForScanner_Txt.tStartRefresh)
            # save page offset
            try:
                thisExp.addData('WaitForScanner_Txt.started', float(WaitForScanner_Txt.tStartRefresh) + float(WaitForScanner_Key.rt))
            except:
                thisExp.addData('WaitForScanner_Txt.started', None)
            # save scanner response time
            if WaitForScanner_Key.keys != None:  # we had a response
                thisExp.addData('WaitForScanner_Key.rt', WaitForScanner_Key.rt)
            # move to next line
            thisExp.nextEntry()

            # the Routine "WaitForScanner" was not non-slip safe, so reset the non-slip timer
            routineTimer.reset()
        else:
            pass

        #######################################
        ########## PRETRIAL FIXATION ##########
        #######################################

        # --- Prepare to start Routine "PretrialFixation" ---
        continueRoutine = True
        routineForceEnded = False

        # update component parameters for each repeat
        PreFix = jitter
        PreFix_duration = 10.000

        # add to the run duration counter
        run3_total_duration += PreFix_duration

        # keep track of which components have finished
        PretrialFixationComponents = [PreFix]
        for thisComponent in PretrialFixationComponents:
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

        # --- Run Routine "PretrialFixation" ---
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
                if EEG_flag == 1:
                    port.write(bytes([255]))
            if PreFix.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > PreFix.tStartRefresh + PreFix_duration-frameTolerance:
                    if EEG_flag == 1:
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

        # --- Ending Routine "PretrialFixation" ---
        for thisComponent in PretrialFixationComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)

        # save page onset
        thisExp.addData('PreFix.started', PreFix.tStartRefresh)
        # save page offset
        try:
            thisExp.addData('PreFix.stopped', float(PreFix.tStartRefresh) + float(PreFix_duration))
        except:
            thisExp.addData('PreFix.stopped', None)
        # move to next line
        thisExp.nextEntry()

        # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
        if routineForceEnded:
            routineTimer.reset()
        else:
            routineTimer.addTime(-PreFix_duration)

        ####################
        ########## RUN 3
        ####################

        # set up handler to look after randomisation of conditions etc
        RUN3 = data.TrialHandler(nReps=1.0, method='sequential', 
            extraInfo=expInfo, originPath=-1,
            trialList=data.importConditions(df_run3),
            seed=randint(1000), name='RUN3')
        thisExp.addLoop(RUN3)  # add the loop to the experiment
        thisRUN3 = RUN3.trialList[0]  # so we can initialise stimuli with some values
        # abbreviate parameter names if possible (e.g. rgb = thisRUN3.rgb)
        if thisRUN3 != None:
            for paramName in thisRUN3:
                exec('{} = thisRUN3[paramName]'.format(paramName))

        for thisRUN3 in RUN3:
            currentLoop = RUN3
            # abbreviate parameter names if possible (e.g. rgb = thisRUN3.rgb)
            if thisRUN3 != None:
                for paramName in thisRUN3:
                    exec('{} = thisRUN3[paramName]'.format(paramName))
            
            ##################################
            ########## INTRODUCTION ##########
            ##################################

            # --- Prepare to start Routine "Introduction" ---
            continueRoutine = True
            routineForceEnded = False
            
            # update component parameters for each repeat
            partner = partner_dict[Stimuli]
            partner.setSize([0.50, 0.50])
            partner.setPos([0, 0])
            Partner_duration = 2.000
            
            # add to the run duration counter
            run3_total_duration += Partner_duration
            
            # keep track of which components have finished
            IntroductionComponents = [partner, partnerintro_Txt]
            for thisComponent in IntroductionComponents:
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
            
            # --- Run Routine "Introduction" ---
            while continueRoutine and routineTimer.getTime() < Partner_duration:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                
                # *partner* updates
                if partner.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    partner.frameNStart = frameN  # exact frame index
                    partner.tStart = t  # local t and not account for scr refresh
                    partner.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(partner, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'partner.started')
                    partner.setAutoDraw(True)
                    if EEG_flag == 1:
                        port.write(bytes([Trigger]))
                if partner.status == STARTED:
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > partner.tStartRefresh + (Partner_duration-frameTolerance):
                        if EEG_flag == 1:
                            port.write(bytes([Trigger]))
                        # keep track of stop time/frame for later
                        partner.tStop = t  # not accounting for scr refresh
                        partner.frameNStop = frameN  # exact frame index
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'partner.stopped')
                        partner.setAutoDraw(False)
                
                # *partnerintro_Txt* updates
                if partnerintro_Txt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    partnerintro_Txt.frameNStart = frameN  # exact frame index
                    partnerintro_Txt.tStart = t  # local t and not account for scr refresh
                    partnerintro_Txt.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(partnerintro_Txt, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'partnerintro_Txt.started')
                    partnerintro_Txt.setAutoDraw(True)
                if partnerintro_Txt.status == STARTED:
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > partnerintro_Txt.tStartRefresh + (Partner_duration-frameTolerance):
                        # keep track of stop time/frame for later
                        partnerintro_Txt.tStop = t  # not accounting for scr refresh
                        partnerintro_Txt.frameNStop = frameN  # exact frame index
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'partnerintro_Txt.stopped')
                        partnerintro_Txt.setAutoDraw(False)
                
                # check for quit (typically the Esc key)
                if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
                    core.quit()
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in IntroductionComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "Introduction" ---
            for thisComponent in IntroductionComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            
            # save page onset
            RUN3.addData('partner.started', partner.tStartRefresh)
            # save page offset
            try:
                RUN3.addData('partner.stopped', float(partner.tStartRefresh) + float(Partner_duration))
            except:
                RUN3.addData('partner.stopped', None)
            
            # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
            if routineForceEnded:
                routineTimer.reset()
            else:
                routineTimer.addTime(-Partner_duration)
            
            #########################
            ########## ISI ##########
            #########################

            # --- Prepare to start Routine "ISI" ---
            continueRoutine = True
            routineForceEnded = False
            
            # update component parameters for each repeat
            isi = jitter
            isi_duration = float(ISI_revised)
            
            # add to the run duration counter
            run3_total_duration += isi_duration
            
            # keep track of which components have finished
            ISIComponents = [isi]
            for thisComponent in ISIComponents:
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
            
            # --- Run Routine "ISI" ---
            while continueRoutine and routineTimer.getTime() < isi_duration:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                
                # *isi* updates
                if isi.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    isi.frameNStart = frameN  # exact frame index
                    isi.tStart = t  # local t and not account for scr refresh
                    isi.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(isi, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'isi.started')
                    isi.setAutoDraw(True)
                    if EEG_flag == 1:
                        port.write(bytes([255]))
                if isi.status == STARTED:
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > isi.tStartRefresh + isi_duration-frameTolerance:
                        if EEG_flag == 1:
                            port.write(bytes([255]))
                        # keep track of stop time/frame for later
                        isi.tStop = t  # not accounting for scr refresh
                        isi.frameNStop = frameN  # exact frame index
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'isi.stopped')
                        isi.setAutoDraw(False)
                
                # check for quit (typically the Esc key)
                if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
                    core.quit()
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in ISIComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "ISI" ---
            for thisComponent in ISIComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            
            # save page onset
            RUN3.addData('isi.started', isi.tStartRefresh)
            # save page offset
            try:
                RUN3.addData('isi.stopped', float(isi.tStartRefresh) + float(isi_duration))
            except:
                RUN3.addData('isi.stopped', None)
            
            # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
            if routineForceEnded:
                routineTimer.reset()
            else:
                routineTimer.addTime(-isi_duration)
            
            ############################
            ########## CHOICE ##########
            ############################

            # --- Prepare to start Routine "Choice" ---
            continueRoutine = True
            routineForceEnded = False
            win.mouseVisible = False
            
            # update component parameters for each repeat
            Choice_duration = 4.050
            partner.setSize([0.20, 0.20])
            partner.setPos([0.30, 0.30])
            you.setPos([-0.30, 0.30])
            invest_slider.reset()
            invest_slider.marker.opacity = 0.0
            invest_slider.marker.color = 'darkgrey'

            # add to the run duration counter
            run3_total_duration += Choice_duration

            # initialize key lists
            Choice_Key.keys = []
            Choice_Key.rt = []
            _Choice_Key_allKeys = []
            
            # keep track of which components have finished
            ChoiceComponents = [partner, you, keep, invest, invest_slider, Choice_Key]
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
            
            # --- Run Routine "Choice" ---
            while continueRoutine and routineTimer.getTime() < Choice_duration:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                
                # *partner* updates
                if partner.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    partner.frameNStart = frameN  # exact frame index
                    partner.tStart = t  # local t and not account for scr refresh
                    partner.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(partner, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'partner.started')
                    partner.setAutoDraw(True)
                    if EEG_flag == 1:
                        port.write(bytes([Trigger]))
                if partner.status == STARTED:
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > partner.tStartRefresh + (Choice_duration-frameTolerance):
                        if EEG_flag == 1:
                            port.write(bytes([Trigger]))
                        # keep track of stop time/frame for later
                        partner.tStop = t  # not accounting for scr refresh
                        partner.frameNStop = frameN  # exact frame index
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'partner.stopped')
                        partner.setAutoDraw(False)
                
                # *you* updates
                if you.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    you.frameNStart = frameN  # exact frame index
                    you.tStart = t  # local t and not account for scr refresh
                    you.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(you, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'you.started')
                    you.setAutoDraw(True)
                if you.status == STARTED:
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > you.tStartRefresh + (Choice_duration-frameTolerance):
                        # keep track of stop time/frame for later
                        you.tStop = t  # not accounting for scr refresh
                        you.frameNStop = frameN  # exact frame index
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'you.stopped')
                        you.setAutoDraw(False)
                
                # *keep* updates
                if keep.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    keep.frameNStart = frameN  # exact frame index
                    keep.tStart = t  # local t and not account for scr refresh
                    keep.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(keep, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'keep.started')
                    keep.setAutoDraw(True)
                if keep.status == STARTED:
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > keep.tStartRefresh + (Choice_duration-frameTolerance):
                        # keep track of stop time/frame for later
                        keep.tStop = t  # not accounting for scr refresh
                        keep.frameNStop = frameN  # exact frame index
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'keep.stopped')
                        keep.setAutoDraw(False)
                
                # *invest* updates
                if invest.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    invest.frameNStart = frameN  # exact frame index
                    invest.tStart = t  # local t and not account for scr refresh
                    invest.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(invest, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'invest.started')
                    invest.setAutoDraw(True)
                if invest.status == STARTED:
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > invest.tStartRefresh + (Choice_duration-frameTolerance):
                        # keep track of stop time/frame for later
                        invest.tStop = t  # not accounting for scr refresh
                        invest.frameNStop = frameN  # exact frame index
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'invest.stopped')
                        invest.setAutoDraw(False)
                
                # *invest_slider* updates
                if invest_slider.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    invest_slider.frameNStart = frameN  # exact frame index
                    invest_slider.tStart = t  # local t and not account for scr refresh
                    invest_slider.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(invest_slider, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'invest_slider.started')
                    invest_slider.setAutoDraw(True)
                    invest_slider.setMarkerPos = None
                if invest_slider.status == STARTED:
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > invest_slider.tStartRefresh + Choice_duration-frameTolerance:
                        # keep track of stop time/frame for later
                        invest_slider.tStop = t  # not accounting for scr refresh
                        invest_slider.frameNStop = frameN  # exact frame index
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'invest_slider.stopped')
                        invest_slider.setAutoDraw(False)
                
                # *Choice_Key* updates
                waitOnFlip = False
                if Choice_Key.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    Choice_Key.frameNStart = frameN  # exact frame index
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
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > Choice_Key.tStartRefresh + (Choice_duration-frameTolerance):
                        # keep track of stop time/frame for later
                        Choice_Key.tStop = t  # not accounting for scr refresh
                        Choice_Key.frameNStop = frameN  # exact frame index
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'Choice_Key.stopped')
                        Choice_Key.status = FINISHED
                if Choice_Key.status == STARTED and not waitOnFlip:
                    theseKeys = Choice_Key.getKeys(keyList=['1','2','3','6','7','8'], waitRelease=False)
                    if theseKeys:
                        _Choice_Key_allKeys.extend(theseKeys)
                        # move invest_slider marker
                        if str(int(theseKeys[-1].name)) in key2slider_invest.keys():
                            invest_slider.marker.opacity = 1.0
                            invest_slider.marker.color = 'black'
                            invest_slider.markerPos = key2slider_invest[str(int(theseKeys[-1].name))]
                            invest_slider.rating = key2slider_invest[str(int(theseKeys[-1].name))]
                    if len(_Choice_Key_allKeys):
                        Choice_Key.keys = _Choice_Key_allKeys[-1].name  # just the last key pressed
                        Choice_Key.rt = _Choice_Key_allKeys[-1].rt
                        invest_slider.rating = key2slider_invest[str(int(_Choice_Key_allKeys[-1].name))] # money trusted
                
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
            
            # --- Ending Routine "Choice" ---
            for thisComponent in ChoiceComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            # check responses
            if Choice_Key.keys in ['', [], None]:  # No response was made
                Choice_Key.keys = None
            # save key response
            RUN3.addData('Choice_Key.keys',Choice_Key.keys)
            if Choice_Key.keys != None:  # we had a response
                # save key rt
                RUN3.addData('Choice_Key.rt', Choice_Key.rt)
            # save investment based on key response
            if Choice_Key.keys == '1':
                investment = 0
                kept = 10
            elif Choice_Key.keys == '2':
                investment = 2
                kept = 8
            elif Choice_Key.keys == '3':
                investment = 4
                kept = 6
            elif Choice_Key.keys == '6':
                investment = 6
                kept = 4
            elif Choice_Key.keys == '7':
                investment = 8
                kept = 2
            elif Choice_Key.keys == '8':
                investment = 10
                kept = 0
            else:
                investment = None
                kept = 0
            RUN3.addData('investment',investment)
            RUN3.addData('kept',kept)
            # save feedback based on investment
            if investment is not None:
                if Feedback == "POSFB":
                    feedback = (investment*3)/2
                    total = kept + feedback
                elif Feedback == "NEGFB":
                    feedback = 0
                    total = kept
            else:
                feedback = None
                total = 0
            RUN3.addData('feedback',feedback)
            RUN3.addData('total',total)
            # also save feedback in list for later
            feedback_run3.append(total)
            # save page onset
            RUN3.addData('Choice.started', you.tStartRefresh)
            # save page offset
            try:
                RUN3.addData('Choice.stopped', float(you.tStartRefresh) + float(Choice_duration))
            except:
                RUN3.addData('Choice.stopped', None)
            
            # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
            if routineForceEnded:
                routineTimer.reset()
            else:
                routineTimer.addTime(-Choice_duration)
            
            #########################
            ########## ITI ##########
            #########################

            # --- Prepare to start Routine "ITI" ---
            continueRoutine = True
            routineForceEnded = False
            
            # update component parameters for each repeat
            iti = jitter
            iti_duration = float(ITI_revised)

            # add to the run duration counter
            run3_total_duration += iti_duration
            
            # keep track of which components have finished
            ITIComponents = [iti]
            for thisComponent in ITIComponents:
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
            
            # --- Run Routine "ITI" ---
            while continueRoutine and routineTimer.getTime() < iti_duration:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                
                # *iti* updates
                if iti.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    iti.frameNStart = frameN  # exact frame index
                    iti.tStart = t  # local t and not account for scr refresh
                    iti.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(iti, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'iti.started')
                    iti.setAutoDraw(True)
                    if EEG_flag == 1:
                        port.write(bytes([255]))
                if iti.status == STARTED:
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > iti.tStartRefresh + iti_duration-frameTolerance:
                        if EEG_flag == 1:
                            port.write(bytes([255]))
                        # keep track of stop time/frame for later
                        iti.tStop = t  # not accounting for scr refresh
                        iti.frameNStop = frameN  # exact frame index
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'iti.stopped')
                        iti.setAutoDraw(False)
                
                # check for quit (typically the Esc key)
                if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
                    core.quit()
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in ITIComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "ITI" ---
            for thisComponent in ITIComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            
            # save page onset
            RUN3.addData('iti.started', iti.tStartRefresh)
            # save page offset
            try:
                RUN3.addData('iti.stopped', float(iti.tStartRefresh) + float(iti_duration))
            except:
                RUN3.addData('iti.stopped', None)
            # move to next line
            thisExp.nextEntry()
            # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
            if routineForceEnded:
                routineTimer.reset()
            else:
                routineTimer.addTime(-iti_duration)
            
        # completed 1.0 repeats of 'RUN3'

        ####################
        ########## OUTCOME
        ####################

        # --- Prepare to start Routine "Outcome" ---
        continueRoutine = True
        routineForceEnded = False

        # update component parameters for each repeat
        outcome_run3 = randchoice(feedback_run3)
        outcomes.append(outcome_run3)
        outcome_text = f"You won ${outcome_run3} in run 3!"
        youAmt.setText(outcome_text)
        youAmt.setPos([0, 0.15])
        Outcome_duration = 3.500

        # add to the run duration counter
        run3_total_duration += Outcome_duration

        # keep track of which components have finished
        OutcomeComponents = [youAmt]
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

        # --- Run Routine "Outcome" ---
        while continueRoutine and routineTimer.getTime() < Outcome_duration:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *youAmt* updates
            if youAmt.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                youAmt.frameNStart = frameN  # exact frame index
                youAmt.tStart = t  # local t and not account for scr refresh
                youAmt.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(youAmt, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'youAmt.started')
                youAmt.setAutoDraw(True)
                if EEG_flag == 1:
                    port.write(bytes([FeedbackTrigger]))
            if youAmt.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > youAmt.tStartRefresh + (Outcome_duration-frameTolerance):
                    if EEG_flag == 1:
                        port.write(bytes([FeedbackTrigger]))
                    # keep track of stop time/frame for later
                    youAmt.tStop = t  # not accounting for scr refresh
                    youAmt.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'youAmt.stopped')
                    youAmt.setAutoDraw(False)
            
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

        # --- Ending Routine "Outcome" ---
        for thisComponent in OutcomeComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
                
        # save page onset
        thisExp.addData('Outcome.started', youAmt.tStartRefresh)
        # save page offset
        try:
            thisExp.addData('Outcome.stopped', float(youAmt.tStartRefresh) + float(Outcome_duration))
        except:
            thisExp.addData('Outcome.stopped', None)
        # move to next line
        thisExp.nextEntry()
        # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
        if routineForceEnded:
            routineTimer.reset()
        else:
            routineTimer.addTime(-Outcome_duration)

        ####################
        ########## BONUS
        ####################

        # --- Prepare to start Routine "Bonus" ---
        continueRoutine = True
        routineForceEnded = False

        # update component parameters for each repeat
        bonus_amount = randchoice(outcomes)
        youBonus.setPos([0, 0.15])
        bonus_text = f"Your bonus is {bonus_amount}!"
        youBonus.setText(bonus_text)
        if bonus_amount > 10:
            BonusTrigger = 133
        else:
            BonusTrigger = 131
        Bonus_duration = 3.500

        # add to the run duration counter
        run3_total_duration += Bonus_duration

        # keep track of which components have finished
        BonusComponents = [youBonus]
        for thisComponent in BonusComponents:
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

        # --- Run Routine "Bonus" ---
        while continueRoutine and routineTimer.getTime() < Bonus_duration:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *youBonus* updates
            if youBonus.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                youBonus.frameNStart = frameN  # exact frame index
                youBonus.tStart = t  # local t and not account for scr refresh
                youBonus.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(youBonus, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'youBonus.started')
                youBonus.setAutoDraw(True)
                if EEG_flag == 1:
                    port.write(bytes([BonusTrigger]))
            if youBonus.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > youBonus.tStartRefresh + (Bonus_duration-frameTolerance):
                    if EEG_flag == 1:
                        port.write(bytes([BonusTrigger]))
                    # keep track of stop time/frame for later
                    youBonus.tStop = t  # not accounting for scr refresh
                    youBonus.frameNStop = frameN  # exact frame index
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'youBonus.stopped')
                    youBonus.setAutoDraw(False)
            
            # check for quit (typically the Esc key)
            if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
                core.quit()
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineForceEnded = True
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in BonusComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()

        # --- Ending Routine "Bonus" ---
        for thisComponent in BonusComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)

        # save page onset
        thisExp.addData('Bonus.started', youBonus.tStartRefresh)
        # save page offset
        try:
            thisExp.addData('Bonus.stopped', float(youBonus.tStartRefresh) + float(Bonus_duration))
        except:
            thisExp.addData('Bonus.stopped', None)
        # save bonus
        thisExp.addData('bonus', bonus_amount)
        # move to next line
        thisExp.nextEntry()
        # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
        if routineForceEnded:
            routineTimer.reset()
        else:
            routineTimer.addTime(-Bonus_duration)

        ########################################
        ########## POSTTRIAL FIXATION ##########
        ########################################

        # --- Prepare to start Routine "PosttrialFixation" ---
        continueRoutine = True
        routineForceEnded = False
        # update component parameters for each repeat
        PostFix = jitter
        PostFix_duration = 597.80 - run3_total_duration
        # if round(run3_total_duration % tr, 2) == 0:
        #     PostFix_duration = float(tr * 8)
        # else:
        #     PostFix_duration = float((tr * 8) + (tr - round(run3_total_duration % tr, 2)))
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

        # --- Run Routine "PosttrialFixation" ---
        while continueRoutine and routineTimer.getTime() < PostFix_duration:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *PostFix* updates
            if PostFix.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                PostFix.frameNStart = frameN  # exact frame index
                PostFix.tStart = t  # local t and not account for scr refresh
                PostFix.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(PostFix, 'tStartRefresh')  # time at next scr refresh
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'PostFix.started')
                PostFix.setAutoDraw(True)
                if EEG_flag == 1:
                    port.write(bytes([255]))
            if PostFix.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > PostFix.tStartRefresh + PostFix_duration-frameTolerance:
                    if EEG_flag == 1:
                        port.write(bytes([255]))
                    # keep track of stop time/frame for later
                    PostFix.tStop = t  # not accounting for scr refresh
                    PostFix.frameNStop = frameN  # exact frame index
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

        # --- Ending Routine "PosttrialFixation" ---
        for thisComponent in PosttrialFixationComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)

        # save page onset
        thisExp.addData('PostFix.started', PostFix.tStartRefresh)
        # save page offset
        try:
            thisExp.addData('PostFix.stopped', float(PostFix.tStartRefresh) + float(PostFix_duration))
        except:
            thisExp.addData('PostFix.stopped', None)
        # move to next line
        thisExp.nextEntry()
        # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
        if routineForceEnded:
            routineTimer.reset()
        else:
            routineTimer.addTime(-PostFix_duration)
    else:
        pass
else:
    pass
#########################
########## END ##########
#########################

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
