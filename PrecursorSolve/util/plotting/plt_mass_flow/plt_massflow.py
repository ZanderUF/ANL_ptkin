## Generic Plotting Outline for rhovsenergy.out data
##
## Author:  Zander Mausolff
## Usage:  python plt_cmdline-args.py
## Usage help: python plt_cmdline-args.py help
import os
import numpy as np
import matplotlib.pyplot as plt
import sys
import re

##-------Change font to 'Palatino' throughout the plot---##
##-------This will match latex documents exactly---------##
from matplotlib import rcParams

current_dir = os.getcwd()
##-------Check if user wants help w/cmd line options
arglist = str(sys.argv)

f=plt.figure()

##------Shape functions------##
def shape_fcn(fcn,x,i):
    if (i == 0) :
        fcn = -0.5*x*(1.0 - x) 
    if (i == 1) :
        fcn = (1 + x)*(1 - x)
    if (i == 2) :
        fcn = 0.5*x*(1 + x)
    return fcn 

data_file_names="data_file_names.txt"
file_names = [line.rstrip('\n') for line in open(data_file_names)]
tick_marks = ['--',':','-','.']

i=0
color = ['.', 'o', '*', '^']
#color=['.',',','o','v','^','<','>','1','2','3','4','8','s','p','P','*','h','H','+','x','X','D','d','|','_']
#set number of precursor groups
num_precursor_groups =1 

while i < len(file_names):
    data1 = np.loadtxt(current_dir + "/" + file_names[i] , skiprows=1)
    
    time = data1[:,0]
    mass_flow = data1[:,7] 
    
    plt.plot(time,mass_flow,tick_marks[i] )
    plt.ylabel('Mass Flow [g/s]',size=14)
    plt.xlabel('Time [s]',size=14)
        
    i=i+1

## Name of saved image
name = 'mass_flow'

##------Configure the legend --- ##
plt.legend( loc='upper center', bbox_to_anchor=(0.5, -0.15),  shadow=True,prop={'size':14},numpoints=1)

if re.search(r'\bpng\b',arglist[1:]):
	f.savefig("./" + name + ".png", bbox_inches = "tight")

if re.search(r'\bpdf\b',arglist[1:]):
        f.savefig("./" + name + ".pdf", bbox_inches = "tight")

if re.search(r'\bs\b',arglist[1:]):
	plt.show()
