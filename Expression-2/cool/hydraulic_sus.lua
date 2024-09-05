@name Hydraulic Sus
@inputs R1 R2 R3 R4 Car:entity
@outputs L1 L2 L3 L4 Constant Damping
@persist Flip

interval(100)

C1 = 50
C2 = 100

L1 = clamp(C1 - (R1 - C2), 50, 200)
L2 = clamp(C1 - (R2 - C2), 50, 200)
L3 = clamp(C1 - (R3 - C2), 50, 100)
L4 = clamp(C1 - (R4 - C2), 50, 100)

Constant = Car:mass() * 50
Damping = 5000
