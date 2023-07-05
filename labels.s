.define Button_A #$80
.define Button_B #$40
.define Button_Select #$20
.define Button_Start #$10
.define DPad_Up #$8
.define DPad_Down #$4
.define DPad_Left #$2
.define DPad_Right #$1

PpuControl_2000				= $2000
PpuMask_2001				= $2001
PpuStatus_2002				= $2002
OamAddr_2003				= $2003
OamData_2004				= $2004
PpuScroll_2005				= $2005
PpuAddr_2006				= $2006
PpuData_2007				= $2007
SpriteDma_4014				= $4014

Sq0Duty_4000				= $4000
Sq0Sweep_4001				= $4001
Sq0Timer_4002				= $4002
Sq0Length_4003				= $4003

Sq1Duty_4004				= $4004
Sq1Sweep_4005				= $4005
Sq1Timer_4006				= $4006
Sq1Length_4007				= $4007

TrgLinear_4008				= $4008
TrgTimer_400A				= $400a
TrgLength_400B				= $400b

NoiseVolume_400C			= $400c
NoisePeriod_400E			= $400e
NoiseLength_400F			= $400f

DmcFreq_4010				= $4010
DmcCounter_4011 			= $4011
DmcAddress_4012				= $4012
DmcLength_4013				= $4013

ApuStatus_4015				= $4015

Ctrl1_4016					= $4016
Ctrl2_FrameCtr_4017			= $4017


; NES RAM

RNGData						= $00 ; 2 bytes
ControllerInputs			= $02

ApplePos					= $03 ; 2 bytes
SnakeHeadPos				= $05 ; 2 bytes
SnakeTailPos				= $07 ; 2 bytes

IncrementTailLength			= $09
EnableMovement				= $0a
SnakeDirection				= $0b

FrameCounter				= $0c

LastSnakeHeadPos			= $0d ; 2 bytes
LastSnakeTailPos			= $0f ; 2 bytes

BlacklistedInputs			= $11

GamePaused					= $12

Temp_SnakeTailDirection		= $ff

ScreenData					= $400 ; 1024 bytes

