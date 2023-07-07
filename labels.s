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
ControllerInputs			= $10

ApplePos					= $11 ; 2 bytes
SnakeHeadPos				= $13 ; 2 bytes
SnakeTailPos				= $15 ; 2 bytes

IncrementTailLength			= $17
EnableMovement				= $18
SnakeDirection				= $19

FrameCounter				= $1a

LastSnakeHeadPos			= $1b ; 2 bytes
LastSnakeTailPos			= $1d ; 2 bytes

BlacklistedInputs			= $1f

GamePaused					= $20

Temp_SnakeTailDirection		= $21

ScreenData					= $400 ; 1024 bytes

