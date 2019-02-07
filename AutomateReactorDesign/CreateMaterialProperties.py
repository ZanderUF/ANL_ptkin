# Create material properties for MSR design

#!/usr/bin/python
import os,sys,random,subprocess,fileinput

# External python file containing set atom densities
# and Isotope base names
from MaterialNames import *

# Evaluate the fuel density based on the temperature
# Using 1975 Russian correlation for 33% UCl3.
# Has a range of [892 - 1142] K
# Returns density in units of [g/cc]
def GetFuelDensity(Temperature):
    a = 3.8604
    b = 0.8321	
    density =  a - (b*Temperature)*0.001
    return density

# Avagadros number
AvagadroNum = 6.02214E-1 # because DIF3D assumes you are giving atom density in Atoms/CC*1E-24

# Tunable values - enrichments
EnrichmentCl37 = 0.99
EnrichmentU235 = 0.16

# NaCl atomic masses
# Order of array - Na23 Cl35 Cl37
NaCl_MolarMass  = [22.9894924, 34.9689000,36.9659000]
NaCl_PercentComp = [1.00]

# Update enrichment percent comp array
NaCl_PercentComp.append(1.0 - EnrichmentCl37)
NaCl_PercentComp.append(EnrichmentCl37)

# Calculate mixture components NaCl-UCl3
Fraction_NaCl = 0.64
Fraction_UCl3 = 1.0 - Fraction_NaCl

# Number of fuel regions
NumFuelRegions = 1

# Reflector Below core
NumReflectorRegionsBelow = 3 
NumReflectorRegionsCore  = 1 
NumReflectorRegionsAbove = 3

#Number of shielding regions
NumShieldRegionsAbove = 3
NumShieldRegionsCore  = 1
NumShieldRegionsBelow = 3

#Number of vessel regions
NumVesselRegionsAbove = 3  
NumVesselRegionsCore  = 1
NumVesselRegionsBelow = 3 

#----------------------------------------------------------------------
#Calculate fuel fraction for reflector below and above the core
FractionSteel_ReflectorBelow = 0.9
FractionFuel_ReflectorBelow  = 1.0 - FractionSteel_ReflectorBelow   

# Calculate fuel fraction for reflector adjacent to core 
FractionSteel_ReflectorCore   = 0.8  
FractionFuel_ReflectorCore    = 1.0 - FractionSteel_ReflectorCore

#Calculate fuel fraction for reflector below and above the core
FractionSteel_ReflectorAbove = 0.9
FractionFuel_ReflectorAbove  = 1.0 - FractionSteel_ReflectorAbove   

#----------------------------------------------------------------------
# Shield composition fractions below core
FractionSteel_ShieldBelow = 0.8 
FractionFuel_ShieldBelow  = 0.1
FractionBoron_ShieldBelow = 1.0 - FractionSteel_ShieldBelow - FractionFuel_ShieldBelow

# Shield composition fractions adjacent to core
FractionSteel_ShieldCore = 0.8 
FractionFuel_ShieldCore  = 0.1
FractionBoron_ShieldCore = 1.0 - FractionSteel_ShieldCore - FractionFuel_ShieldCore

# Shield composition fractions above 
FractionSteel_ShieldAbove = 0.8 
FractionFuel_ShieldAbove  = 0.1
FractionBoron_ShieldAbove = 1.0 - FractionSteel_ShieldAbove - FractionFuel_ShieldAbove


TotalNaCl_MolarMass = 0.0
# Calculate total molar mass for the compound based on percent comps
for i in range(len(NaCl_PercentComp)):
    TotalNaCl_MolarMass = TotalNaCl_MolarMass + NaCl_MolarMass[i]*NaCl_PercentComp[i]
    i = i + 1

print 'NaCl starting percent composition..',NaCl_PercentComp
print 'Molar mass Na23, Cl35, Cl37........',NaCl_MolarMass
print 'NaCl total molar mass .............',TotalNaCl_MolarMass

# Order of array U235 U238 Cl35 Cl37
UCl3_MolarMass  = [235.043945, 238.050781, 34.9689000, 36.9659000]
UCl3_PercentComp = []
UCl3_PercentComp.append(EnrichmentU235)             # U235
UCl3_PercentComp.append(1.0 - EnrichmentU235)       # U238
UCl3_PercentComp.append(3.0*(1.0-EnrichmentCl37))   # Cl35
UCl3_PercentComp.append(3.0*EnrichmentCl37)         # Cl37

TotalUCl3_MolarMass = 0.0
# Calculate total molar mass for the compound based on percent comps
for i in range(len(UCl3_PercentComp)):
    TotalUCl3_MolarMass = TotalUCl3_MolarMass + UCl3_MolarMass[i]*UCl3_PercentComp[i]

print 'UCl3 starting percent composition..', UCl3_PercentComp 
print 'Molar mass U235 U238 Cl35 Cl37.....', UCl3_MolarMass
print 'UCl3 total molar mass .............', TotalUCl3_MolarMass

Total_NaCl_UCl3_MolarMass = TotalNaCl_MolarMass*Fraction_NaCl + TotalUCl3_MolarMass*Fraction_UCl3

print 'Total NaCl-UCl3 molar mass .........',Total_NaCl_UCl3_MolarMass

NominalTemperature = 900 # [Kelvin]
NominalFuelDensity = GetFuelDensity(NominalTemperature) # g/cc
print 'Nominal fuel density is ', NominalFuelDensity, ' at a temperature of ', NominalTemperature

# Get component densities
ComponentDensity_NaCl = (NominalFuelDensity/Total_NaCl_UCl3_MolarMass) * Fraction_NaCl*AvagadroNum
ComponentDensity_UCl3 = (NominalFuelDensity/Total_NaCl_UCl3_MolarMass) * Fraction_UCl3*AvagadroNum
# Get atom density for the mixture NaCl-UCl3
AtomDensity_NaCl_UCl3 = []
# Na23 Cl35 Cl37 U235 U238
AtomDensity_NaCl_UCl3.append(ComponentDensity_NaCl*NaCl_PercentComp[0])
AtomDensity_NaCl_UCl3.append(ComponentDensity_NaCl*NaCl_PercentComp[1]+ComponentDensity_UCl3*UCl3_PercentComp[2])
AtomDensity_NaCl_UCl3.append(ComponentDensity_NaCl*NaCl_PercentComp[2]+ComponentDensity_UCl3*UCl3_PercentComp[3])
AtomDensity_NaCl_UCl3.append(ComponentDensity_UCl3*UCl3_PercentComp[0])
AtomDensity_NaCl_UCl3.append(ComponentDensity_UCl3*UCl3_PercentComp[1])

print 'Atom density for NaCl-UCl3 is.......', AtomDensity_NaCl_UCl3

# Calculate reflector atom densities

# Calculate atom densities based on fractions of each composition and write out to file for MCC^2-3

FuelSaltAtomDen  = []
ReflectorAtomDen = []
ShieldAtomDen    = []
VesselAtomDen    = []

IDs_Core         = []
IDs_Reflector    = []
IDs_Shield       = []
IDs_Vessel       = []

NumFuelRegions = 1
# FUEL
#------------------------------------------------------------------------
for n in range(NumFuelRegions):
    TempID = []
    TempFuelAtomDen = []
    for i in range(len(CoreIsotopeNames)):
        # Add the first of fuel salt calculated 
        if i < len(AtomDensity_NaCl_UCl3):
            TempFuelAtomDen.append(AtomDensity_NaCl_UCl3[i]) 
        # Otherwise 'dummy' isotopes 
        else:
            TempFuelAtomDen.append(1.0E-16)
        TempID.append(CoreID[i] + 'M' + str(n+1))
        i = i+1 
    FuelSaltAtomDen.append(TempFuelAtomDen)
    IDs_Core.append(TempID)
    n = n+1 


SteelLength = len(SteelAtomDensity)
BoronLength = len(BoronAtomDensity)
FuelLength  = len(AtomDensity_NaCl_UCl3)

for n in range(NumReflectorRegionsBelow):
    TempReflectorAtomDen = []
    TempID = []
    for i in range(len(ReflectorIsotopeNames)):
        # First do steel using fraction
        if i < SteelLength:
            TempReflectorAtomDen.append(SteelAtomDensity[i]*FractionSteel_ReflectorBelow)
        # Add fuel fraction
        elif i < SteelLength + FuelLength:  
            TempReflectorAtomDen.append(AtomDensity_NaCl_UCl3[i-SteelLength]*FractionFuel_ReflectorBelow)
        # Extra isotopes
        else:
            TempReflectorAtomDen.append(1E-16)
        TempID.append(ReflectorID[i] + 'R' + str(n+1))
        i = i+1
    # Append to large array containing all info for a set of regions
    IDs_Reflector.append(TempID)
    ReflectorAtomDen.append(TempReflectorAtomDen) 
    n = n+1

# Reflector Next to Core 
for n in range(NumReflectorRegionsCore):
    TempReflectorAtomDen = []
    TempID = []
    for i in range(len(ReflectorIsotopeNames)):
        # First do steel using fraction
        if i < SteelLength:
            TempReflectorAtomDen.append(SteelAtomDensity[i]*FractionSteel_ReflectorCore)
        elif i < SteelLength + FuelLength:  
            TempReflectorAtomDen.append(AtomDensity_NaCl_UCl3[i-SteelLength]*FractionFuel_ReflectorCore)
        else:
            TempReflectorAtomDen.append(1E-16)
        TempID.append(ReflectorID[i] + 'R' + str(n+1+NumReflectorRegionsBelow))
        i = i+1
    IDs_Reflector.append(TempID)
    ReflectorAtomDen.append(TempReflectorAtomDen) 
    n = n+1

# Reflector Above core
for n in range(NumReflectorRegionsAbove):
    TempReflectorAtomDen = []
    TempID = []
    for i in range(len(ReflectorIsotopeNames)):
        # First do steel using fraction
        if i < SteelLength:
            TempReflectorAtomDen.append(SteelAtomDensity[i]*FractionSteel_ReflectorAbove)
        # Fuel
        elif i < SteelLength + FuelLength:
            TempReflectorAtomDen.append(AtomDensity_NaCl_UCl3[i-SteelLength]*FractionFuel_ReflectorAbove) 
        # Extra isotopes
        else:
            TempReflectorAtomDen.append(1E-16)
        TempID.append(ReflectorID[i] + 'R' + str(n+1+NumReflectorRegionsBelow+NumReflectorRegionsCore))
        i = i+1
    IDs_Reflector.append(TempID)
    ReflectorAtomDen.append(TempReflectorAtomDen) 
    n = n+1

#------------------------------------------------------------------------
# SHIELD

# Below
for n in range(NumShieldRegionsBelow):
    TempShieldAtomDen = []
    TempID = []
    for i in range(len(ShieldIsotopeNames)):
        # Fraction of steel
        if i < SteelLength:
            TempShieldAtomDen.append(SteelAtomDensity[i]*FractionSteel_ShieldBelow)
        elif i < SteelLength + BoronLength:
            TempShieldAtomDen.append(BoronAtomDensity[i-SteelLength]*FractionBoron_ShieldBelow)
        # Fraction of boron carbide
        elif i < SteelLength + BoronLength + FuelLength:
            TempShieldAtomDen.append(AtomDensity_NaCl_UCl3[i-SteelLength - BoronLength]*FractionFuel_ShieldBelow)
        # Fraction of Fuel
        else:
            TempShieldAtomDen.append(1E-16)
        TempID.append(ShieldID[i] + 'S' + str(n+1))     
        i = i+1
    IDs_Shield.append(TempID)
    ShieldAtomDen.append(TempShieldAtomDen)
    n = n+1

# Core 
for n in range(NumShieldRegionsCore):
    TempShieldAtomDen = []
    TempID = []
    for i in range(len(ShieldIsotopeNames)):
        # Fraction of steel
        if i < SteelLength:
            TempShieldAtomDen.append(SteelAtomDensity[i]*FractionSteel_ShieldCore)
        elif i < SteelLength + BoronLength:
            TempShieldAtomDen.append(BoronAtomDensity[i-SteelLength]*FractionBoron_ShieldCore)
        # Fraction of boron carbide
        elif i < SteelLength + BoronLength + FuelLength:
            TempShieldAtomDen.append(AtomDensity_NaCl_UCl3[i-SteelLength - BoronLength]*FractionFuel_ShieldCore)
        # Fraction of Fuel
        else:
            TempShieldAtomDen.append(1E-16)
        TempID.append(ShieldID[i] + 'S' + str(n+1+NumShieldRegionsBelow))     
        i = i+1
    IDs_Shield.append(TempID)
    ShieldAtomDen.append(TempShieldAtomDen)
    n = n+1

# Above 
for n in range(NumShieldRegionsAbove):
    TempShieldAtomDen = []
    TempID = []
    for i in range(len(ShieldIsotopeNames)):
        # Fraction of steel
        if i < SteelLength:
            TempShieldAtomDen.append(SteelAtomDensity[i]*FractionSteel_ShieldAbove)
        elif i < SteelLength + BoronLength:
            TempShieldAtomDen.append(BoronAtomDensity[i-SteelLength]*FractionBoron_ShieldAbove)
        # Fraction of boron carbide
        elif i < SteelLength + BoronLength + FuelLength:
            TempShieldAtomDen.append(AtomDensity_NaCl_UCl3[i-SteelLength - BoronLength]*FractionFuel_ShieldAbove)
        # Fraction of Fuel
        else:
            TempShieldAtomDen.append(1E-16)
        TempID.append(ShieldID[i] + 'S' + str(n+1+NumShieldRegionsBelow+NumShieldRegionsCore))     
        i = i+1
    IDs_Shield.append(TempID)
    ShieldAtomDen.append(TempShieldAtomDen)
    n = n+1

# VESSEL
# Below 
for n in range(NumVesselRegionsBelow):
    TempVesselAtomDen = []
    TempID = []
    for i in range(len(VesselIsotopeNames)):
        # Fraction of steel
        if i < SteelLength:
            TempID.append(VesselID[i] + 'V' + str(n+1+NumVesselRegionsBelow+NumVesselRegionsCore))     
            TempVesselAtomDen.append(SteelAtomDensity[i])
        i = i+1
    IDs_Vessel.append(TempID)
    VesselAtomDen.append(TempVesselAtomDen)
    n = n+1

# Core 
for n in range(NumVesselRegionsCore):
    TempVesselAtomDen = []
    TempID = []
    for i in range(len(VesselIsotopeNames)):
        # Fraction of steel
        if i < SteelLength:
            TempID.append(VesselID[i] + 'V' + str(n+1+NumVesselRegionsBelow))     
            TempVesselAtomDen.append(SteelAtomDensity[i])
        i = i+1
    IDs_Vessel.append(TempID)
    VesselAtomDen.append(TempVesselAtomDen)
    n = n+1

# Above 
for n in range(NumVesselRegionsAbove):
    TempVesselAtomDen = []
    TempID = []
    for i in range(len(VesselIsotopeNames)):
        # Fraction of steel
        if i < SteelLength:
            TempID.append(VesselID[i] + 'V' + str(n+1+NumVesselRegionsBelow+NumVesselRegionsCore))     
            TempVesselAtomDen.append(SteelAtomDensity[i])
        i = i+1
    IDs_Vessel.append(TempID)
    VesselAtomDen.append(TempVesselAtomDen)
    n = n+1

TotalNumRegions = 12
MaterialFileName = 'material_section_mcc.txt'
os.system('rm ' + MaterialFileName) 


# Write material section of MC^2-3 file
#-----------------------------------------------------
# Write out fuel compositions 
TotalFuelRegions = NumFuelRegions 
for i in range(TotalFuelRegions):
    
    output = open(MaterialFileName,"a")
    # for a given material
    
    output.write('! Fuel  Material ' + str(i+1)+ '\n') 
    CompositionIdentifier = 't_composition(:, '+ str(i+1) + ') ='
    output.write(CompositionIdentifier)
    FinalLine = [] 
    for j in range(len(CoreIsotopeNames)): 
        if j < len(AtomDensity_NaCl_UCl3):
            FinalLine.append(CoreIsotopeNames[j] + ' ' + IDs_Core[i][j] + ' ' + str('{:.5e}'.format(FuelSaltAtomDen[i][j])) + '  900.00')
    
    output.write("\n".join(FinalLine))
    
    output.write("\n")
    output.write("\n")
    output.close()
    i = i+1

# Reflector compositions

TotalReflectorRegions = NumReflectorRegionsBelow + NumReflectorRegionsCore + NumReflectorRegionsAbove 
for i in range(TotalReflectorRegions):
    
    output = open(MaterialFileName,"a")
    # for a given material
    output.write('! Reflector Material ' + str(i+1)+ '\n') 
    CompositionIdentifier = 't_composition(:, '+ str(i+1+TotalFuelRegions) + ') ='
    output.write(CompositionIdentifier)

    FinalLine = [] 
    for j in range(len(ReflectorIsotopeNames)): 
        FinalLine.append(ReflectorIsotopeNames[j] + ' ' + IDs_Reflector[i][j] + ' ' + str('{:.5e}'.format(ReflectorAtomDen[i][j])) + '  900.00')
    
    output.write("\n".join(FinalLine))
    
    output.write("\n")
    output.write("\n")
    output.close()
    i = i+1

# Shielding
TotalShieldRegions = NumShieldRegionsBelow+NumShieldRegionsCore+NumShieldRegionsAbove

for i in range(TotalShieldRegions):
    output = open(MaterialFileName,"a")
   
    output.write('! Shield Material ' + str(i+1) + '\n')
    # for a given material
    CompositionIdentifier = 't_composition(:, '+ str(i+1+TotalReflectorRegions+TotalFuelRegions) + ') ='
    output.write(CompositionIdentifier)

    FinalLine = [] 
    for j in range(len(ShieldIsotopeNames)): 
        FinalLine.append(ShieldIsotopeNames[j] + ' ' + IDs_Shield[i][j] + ' ' + str('{:.5e}'.format(ShieldAtomDen[i][j])) + '  900.00')
    
    output.write("\n".join(FinalLine))
    
    output.write("\n")
    output.write("\n")
    output.close()
    
    i = i+1

# Vessel 
TotalVesselRegions = NumVesselRegionsBelow + NumVesselRegionsCore + NumVesselRegionsAbove
print VesselAtomDen

print ' len v ', len(VesselAtomDen[0])
print ' sdfa ' ,len(VesselIsotopeNames)
print 'le id  ',len(IDs_Vessel[0])

for i in range(TotalVesselRegions):
    output = open(MaterialFileName,"a")
   
    output.write('! Vessel Material ' + str(i+1))
    # for a given material
    CompositionIdentifier = 't_composition(:, '+ str(i+1+TotalReflectorRegions+TotalFuelRegions+TotalShieldRegions) + ') ='
    output.write(CompositionIdentifier)

    FinalLine = [] 
    for j in range(len(VesselIsotopeNames)): 
        FinalLine.append(VesselIsotopeNames[j] + ' ' + IDs_Vessel[i][j] + ' ' + str('{:.5e}'.format(VesselAtomDen[i][j])) + '  900.00')
    
    output.write("\n".join(FinalLine))
    
    output.write("\n")
    output.write("\n")
    output.close()
    
    i = i+1

