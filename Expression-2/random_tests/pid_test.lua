@name PID Test
@inputs Prop:entity
@outputs Thruster:vector PitchUp PitchDown YawLeft YawRight RollLeft RollRight
@persist [VTarget VPGain VIGain VDGain VEPrior VIPrior]:vector
@persist [ATarget APGain AIGain ADGain AEPrior AIPrior]:angle

runOnTick(1)

if(first()){
    VTarget = vec(0, 0, 200)
    VPGain = vec(0.5)
    VIGain = vec(0)
    VDGain = vec(0.5)
    
    ATarget = ang(0, 0, 0)
    APGain = ang(0.1)
    AIGain = ang(0.001)
    ADGain = ang(0.01)
}

VError = VTarget - Prop:pos()
VI = VIPrior + VError * tickInterval()
VD = (VError - VEPrior) / tickInterval()
VOutput = VError * VPGain + VI * VIGain + VD * VDGain
VEPrior = VError
VIPrior = VI

Thruster = -VOutput

AError = ATarget - Prop:angles()
AI = AIPrior + AError * tickInterval()
AD = (AError - AEPrior) / tickInterval()
AOutput = AError * APGain + AI * AIGain + AD * ADGain
AEPrior = AError
AIPrior = AI

PitchUp = AOutput:pitch()
PitchDown = -AOutput:pitch()
YawLeft = AOutput:yaw()
YawRight = -AOutput:yaw()
RollLeft = AOutput:roll()
RollRight = -AOutput:roll()
#print(AError)
