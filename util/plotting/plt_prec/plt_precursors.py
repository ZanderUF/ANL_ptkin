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

i=0
color = ['.', ':', '--', '.',':','--']
#color=['.',',','o','v','^','<','>','1','2','3','4','8','s','p','P','*','h','H','+','x','X','D','d','|','_']
#set number of precursor groups
num_precursor_groups = 1 
print file_names

while i < len(file_names):
    data1 = np.loadtxt(current_dir + "/" + file_names[i] , skiprows=2)
    g=0
    while g < num_precursor_groups:
        x_coord = data1[:,0]
        prec_conc = data1[:,g+3]
        max_length = len(x_coord)
        element_length = x_coord[2] - x_coord[0]
        starting = x_coord[0]
        ending =   x_coord[max_length-1]
        elem_interval = 10
        
        norm_space = np.linspace(-1,1,elem_interval)
        x_interval = (ending*elem_interval)/element_length
        # Break the x coordinate into smaller intervals
        x_space = np.linspace(starting,ending,x_interval)
        
        # evaluate using quadratic interpolation functions
        nodes_per_elem = 3
        num_elem = max_length/nodes_per_elem
        value = 0
        
        # array to hold quadratically interpolated solution
        soln = []
        # evaluate solution between nodal points
        for q in range(0, num_elem):
            ii = (q)*nodes_per_elem 
            for k in range(0,len(norm_space)):
                x = norm_space[k]
                linear_comb = 0
                for j in range(0,nodes_per_elem):
                    value = shape_fcn(value,x,j)
                    linear_comb = linear_comb + value*prec_conc[j + ii]
                soln.append(linear_comb)  
        
        plt.plot(x_space,soln,color[g], label='File'+ str(i)) #+ str(file_names[i]) )
        plt.ylabel('Precursor Concentration',size=14)
        plt.xlabel('Distance [cm]',size=14)
        plt.xlim(0,550)  
        
        
        g=g+1
    
    i=i+1

text_ht=0.9
plt.axvline(x=50)
plt.text(60,text_ht*max(prec_conc),'Inlet' )
plt.axvline(x=100)
plt.text(250,text_ht*max(prec_conc),'Main Core' )
plt.axvline(x=450)
plt.text(450,text_ht*max(prec_conc),'Outlet' )
plt.axvline(x=510)

## Name of saved image
name = 'precursor_concentration'

##------Configure the legend --- ##
plt.legend( loc='upper center', bbox_to_anchor=(0.5, -0.15),  shadow=True,prop={'size':14},numpoints=1)
#plt.legend( loc='upper right', shadow=True,prop={'size':14},numpoints=1)


if re.search(r'\bpng\b',arglist[1:]):
	f.savefig("./" + name + ".png",bbox_inches = "tight")

if re.search(r'\bpdf\b',arglist[1:]):
        f.savefig("./" + name + ".pdf", bbox_inches = "tight")

if re.search(r'\bs\b',arglist[1:]):
	plt.show()
