@name DotProductSingle
@inputs Target:entity
@persist 

interval(100)

ToPlayerDelta = owner():pos() - Target:pos()
Delta = entity():pos() - Target:pos()
print(Delta:dot(ToPlayerDelta))
