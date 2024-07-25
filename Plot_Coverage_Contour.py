import numpy as np
from numpy import loadtxt
import matplotlib.pyplot as plt
from irfpy.moon import moon_map

data = loadtxt("/Users/emily/Documents/ContourCoverage/LRO_results_revisit.txt", skiprows=1)

# Load in data and define grid spacing for post processing
lats = np.unique([data[:,0]])
lons = np.unique([data[:,1]])
lasz=np.size(lats) 
losz=np.size(lons) 
lainds=np.linspace(0,lasz-1,lasz,dtype=int) # [ 0, ... , 10 ]
loinds=np.linspace(0,losz-1,losz,dtype=int) # [ 0, ... , 24 ]
Npairs = lasz*losz 

# Preallocate result matrix
res = np.zeros((lasz,losz),dtype=int)
mins = np.zeros((lasz,losz),dtype=int)
maxs = np.zeros((lasz,losz),dtype=int)
counts = np.zeros((lasz,losz),dtype=int)

for row in data:
    cla = row[0] # current latitude value
    clo = row[1] # current longitude value

    Icla = np.where(lats == cla)[0] 
    Iclo = np.where(lons == clo)[0]
    icla = Icla[0] # find index of lat value in results matrix
    iclo = Iclo[0] # find index of lng value in results matrix

    # Plot Access Times 
    if (res[icla,iclo]) == 0: # current lat,lon result value = 0 aka first measurment
        res[icla,iclo] = row[2]
        mins[icla,iclo] = row[2]
        maxs[icla,iclo] = row[2]
    else: # lat,lon pair already as measurments 
        cur_vals = [row[2],res[icla,iclo]] 
        res[icla,iclo] = np.mean(cur_vals) # find mean 
        if mins[icla,iclo] > row[2]:
            mins[icla,iclo] = row[2]
        if maxs[icla,iclo] < row[2]:
            maxs[icla,iclo] = row[2]
    # Plot Revisit
    # if (row[3] != 0): # ignore first measurment that has 0 revisit becuase no revisit until second measurment
    #     if (res[icla,iclo]) == 0: # if current result value = 0 
    #         res[icla,iclo] = row[3]
    #         mins[icla,iclo] = row[3]
    #         maxs[icla,iclo] = row[3]
    #     else: 
    #         cur_vals = [row[3],res[icla,iclo]]
    #         res[icla,iclo] = np.mean(cur_vals)
    #         if mins[icla,iclo] > row[3]:
    #             mins[icla,iclo] = row[3]
    #         if maxs[icla,iclo] < row[3]:
    #             maxs[icla,iclo] = row[3]

    counts[icla,iclo] += 1

# Sort results for plotting format
plotresults = np.zeros((Npairs,5))
count = 0 
for LA in lainds:
    for LO in loinds:
        plotresults[count,:] = [lats[LA],lons[LO],res[LA,LO],mins[LA,LO],maxs[LA,LO]]
        count += 1

X= plotresults[:,0]
Y = plotresults[:,1]
Z= plotresults[:,2]
x,y = np.meshgrid(X,Y)

fig1, ax1 = plt.subplots()
CS = plt.contourf(lons,lats,res,levels=np.linspace(0, 250, 20),cmap='Spectral')
ax1.legend()
plt.scatter(y,x,3,c="k")
fig1.colorbar(CS)
fig1.show()
plt.xlabel('Longitude (degrees)')
plt.ylabel('Latitude (degrees)')
plt.title('Average Access Duration in Seconds')

fig2, ax2 = plt.subplots()
CS = plt.contourf(lons,lats,mins,levels=np.linspace(0, 250, 20),cmap='Spectral')
ax2.legend()
plt.scatter(y,x,3,c="k")
fig2.colorbar(CS)
fig2.show()
plt.xlabel('Longitude (degrees)')
plt.ylabel('Latitude (degrees)')
plt.title('Minimum Access Duration in Seconds')


fig3, ax3 = plt.subplots()
CS = plt.contourf(lons,lats,maxs,levels=np.linspace(0, 250, 20),cmap='Spectral')
ax3.legend()
plt.scatter(y,x,3,c="k")
fig3.colorbar(CS)
fig3.show()
plt.xlabel('Longitude (degrees)')
plt.ylabel('Latitude (degrees)')
plt.title('Maximum Access Duration in Seconds')


# map = moon_map.MoonMapSmall()
# map_on_sphere = map.gridsphere()
# blon, blat = map_on_sphere.get_bgrid(delta=0.01)    # Grid specifying the longitude and latitude.
# level = map_on_sphere.get_average()
# # newLon = np.zeros((513,1024 ))
# halfLon2 = blon[:,512:1025]-360
# halfLon1 = blon[:,0:512]
# newLon = np.concatenate([halfLon2,halfLon1],axis=-1)
# ax.pcolor(newLon, blat, level, cmap='gray')
# ax.legend()
# map = moon_map.MoonMapSmall()
# # fig = px.imshow(map.image)
# pixel_data = map.image
# print(pixel_data.shape)