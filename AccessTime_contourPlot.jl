using Revise
# using Cspice
# using Ctk, CSpice, CtkAPI
using JSON, Dates, CSV, JLD, DelimitedFiles,LinearAlgebra

dir     = homedir()

#Example file
fjson = "/home/parallels/RevSpace/InputFiles/Imaging_1sc_ContourDataScript.json"

#Ctk Simulation Name
sim_id = "Imaging_1sc_ContourDataScript"

#Initialize results file
# sim_idtxt = sim_id*".txt"
resultfile_times = joinpath(@__DIR__,sim_id*".txt")
head_times = reshape(["LAT","LON","Duration" ,"Revisit"], (1,4))
res_times = open(resultfile_times,"w")
writedlm(res_times,head_times)

# Call Ctk
Ctk.run(fjson,sim_id,force_simid=true)
@load joinpath(dir,"sims",sim_id,"outputs","display.jld") access
accesstimes = JSON.parse(access)
# # access = zeros(length(times))
for at in accesstimes
    duration = at["duration"]
    start_time = at["start_t"]
    end_time = at["end_t"]
    sat = at["sat"]
    lon = at["lon"] 
    lat = at["lat"] 
    revisit = at["revisit"]
    result_times = reshape([lat,lon,duration,revisit], (1,4))
    writedlm(res_times,result_times)
end
close(res_times)


# "orbit": {
# 				"centralBody": "Earth",
# 				"constellationType": "single_orbit",
# 				"initialConditions":[
# 					{
# 						"epoch": "01 Jan 2024 00:00:00.000",
# 						"isSunSynchronous": "false",
# 						"orbitType": "custom",
# 						"state": {
# 							"keplerian": {
# 								"semimajorAxisAltitude": 500,
# 								"eccentricity": 0,
# 								"inclination": 0,
# 								"rightAscension": 0,
# 								"argumentOfPeriapsis": 0,
# 								"meanAnomaly": 0
# 							}
# 						},
# 						"sunSyncInputs": {
# 							"LTAN": "00:00:00",
# 							"timeType": "mean"
# 						}
# 					}
# 				]
# 			},