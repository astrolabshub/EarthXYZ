using Revise
# using Cspice
# using Ctk, CSpice, CtkAPI
using JSON, Dates, CSV, JLD, DelimitedFiles,LinearAlgebra
using Metaheuristics

dir     = homedir()

#Initialize results file
# sim_idtxt = sim_id*".txt"
# resultfile_times = joinpath(@__DIR__,sim_id*".txt")
# head_times = reshape(["LAT","LON","Duration" ,"Revisit"], (1,4))
# res_times = open(resultfile_times,"w")
# writedlm(res_times,head_times)

#Example file
fjson = "/home/parallels/RevSpace/InputFiles/Imaging_Constel_OptimScript.json"

#Ctk Simulation Name
sim_id = "Imaging_Constel_OptimScript"

# fjson = "Imaging_1sc_1target.json" # CTK file name
# file = joinpath(dir,fjson)

function MUSE_COVERAGE(x)
    inputs = JSON.parse(read(fjson,String))

    constellation = inputs[3]["value"]
    constellation["orbit"]["constellationProperties"]["planeAmount"] = x[1]
    constellation["orbit"]["constellationProperties"]["spacecraftPerPlane"] = x[2]
    # constellation["orbit"]["constellationProperties"]["nSat"] = 4
    groundobject = inputs[4]["value"]
    groundobject["groundobject"]["dlat"] = 5
    groundobject["groundobject"]["dlat"] = 5

    open(fjson,"w") do f
        write(f,JSON.json(inputs))
    end
    sim_id = "RevSpace"*"$(now(Dates.UTC))"
    # Call Ctk
    # @info "--------Running analysis with  sats in $nPlane planes -------"
    Ctk.run(fjson,sim_id,force_simid=true)
    @load joinpath(homedir(),"sims","$sim_id","outputs","display.jld") fom_data
    fomRes = JSON.parse(fom_data)[1]
    revisitTime = round(parse(Float64,fomRes["meancovgap"]) / 3600, digits=3)
    # percCov = fomRes["percentcovered"]
    # cumPercCov = fomRes["cumpercentcovered"]

    return -1*revisitTime 
end

algorithm = GA(
    N = 2,
    options = Options(iterations = 2, f_calls_limit = 100, f_tol = 1e-5, seed=1)
    )

# res = bboptimize(MUSE_COVERAGE; SearchRange = [(1,2), (1,2)])
bounds = [1 2; 2 2]
result = optimize(MUSE_COVERAGE, bounds, algorithm )

fx = minimum(result)
@info fx

x = minimizer(result)
@info x

# Call Ctk
# Ctk.run(fjson,sim_id,force_simid=true)
# Load & Parse Results
# @load joinpath(dir,"sims",sim_id,"outputs","display.jld") access fom_data
# accesstimes = JSON.parse(access)
# for at in accesstimes
#     cur_revisit = at["revisit"]
#     if cur_revisit != 0: np.append(revisit_array,at["revisit"])        
#     mean_revisit = np.mean(revisit_array)
# return mean_revisit

# class MUSE_COVERAGE:
#     def fitness(self, x):
#         # Update JSON fields with Design Variables 
#         # altitude
#         # inclination
#         constellation["orbit"]["constellationProperties"]["planeAmount"] = nPlane
#         constellation["orbit"]["constellationProperties"]["spacecraftPerPlane"] = nScPerPlane

#         # Call Ctk
#         Ctk.run(fjson,sim_id,force_simid=true)
#         # Load & Parse Results
#         @load joinpath(dir,"sims",sim_id,"outputs","display.jld") access
#         accesstimes = JSON.parse(access)
#         for at in accesstimes
#             cur_revisit = at["revisit"]
#             if cur_revisit != 0: np.append(revisit_array,at["revisit"])        
#             mean_revisit = np.mean(revisit_array)

#         return mean_revisit

#     def get_bounds(self):
#         # DV1 = Number of Planes
#         # DV2 = Number of Spacecraft per Plane
#         return ([1,6],[1,4])

# # The problem
# prob = pg.problem(MUSE_COVERAGE())
# # The initial population
# pop = pg.population(prob, size = 2)
# # The algorithm (a self-adaptive form of Differential Evolution (sade - jDE variant)
# algo = pg.algorithm(pg.pso(gen = 2))
# # The actual optimization process
# pop = algo.evolve(pop)
# # Getting the best individual in the population
# best_fitness = pop.get_f()[pop.best_idx()]
# print(best_fitness) 


# // "orbit":{
#     //   "centralBody": "MyEarth",
#     //   "constellationType": "Walker Delta",
#     //   "dr": 50,
#     //   "initialConditions": [ // Mission Initial Conditions
#     //     {
#     //         "epoch": "01 Jan 2023 12:00:00.000",
#     //         "isSunSynchronous": false,
#     //         "state": {
#     //             "keplerian": {
#     //                 "argumentOfPeriapsis": 0, //deg
#     //                 "eccentricity": 0,
#     //                 "inclination": 90, //deg
#     //                 "meanAnomaly": 0, //deg
#     //                 "rightAscension": 0, //deg
#     //                 "semimajorAxisAltitude": 500, //km
#     //                 "trueAnomaly": 0 //deg
#     //             },
#     //             "referenceFrame": "EarthMJ2000Eq"
#     //         }
#     //     }
#     //   ],
#     //   "constellationProperties": { // Properties of the constellation
#     //     "groundTrackPeriod": 1,
#     //     "phaseAmount": 0,
#     //     "planeAmount": 3,
#     //     "spacecraftPerPlane": 4
#     //   }
#     // },

# Post Process aceess time contour plots
# # # access = zeros(length(times))
# for at in accesstimes
#     duration = at["duration"]
#     start_time = at["start_t"]
#     end_time = at["end_t"]
#     sat = at["sat"]
#     lon = at["lon"] 
#     lat = at["lat"] 
#     revisit = at["revisit"]
#     result_times = reshape([lat,lon,duration,revisit], (1,4))
#     writedlm(res_times,result_times)
# end
# close(res_times)


