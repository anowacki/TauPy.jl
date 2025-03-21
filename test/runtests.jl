using TauPy
using Test

# Time tolerance / s
time_atol = 0.01
# Slowness tolerance / s/°
slow_atol = 0.001
# Angle tolerance / °
angle_atol = 0.01

@testset "Phase" begin
    @testset "Time" begin
        let p = travel_time(300, 60, "PcS", model="prem")
            @test p isa Vector{<:Phase}
            @test length(p) == 1
            @test p[1].model == "prem"
            @test p[1].name == "PcS"
            @test p[1].delta ≈ 60.0
            @test p[1].depth ≈ 300.0
            @test p[1].time ≈ 860.2281352411015 atol=time_atol
            @test p[1].dtdd ≈ 4.425149199692147 atol=slow_atol
            @test p[1].inc ≈ 7.316383583264879 atol=angle_atol
            @test p[1].takeoff ≈ 21.338284647101577 atol=angle_atol
            @test p[1].pierce ≈ Float64[]
            @test p[1].distance ≈ Float64[]
            @test p[1].radius ≈ Float64[]
        end

        # Triplications around 20° should many arrivals
        let p = travel_time(0, 20, "P", model="iasp91")
            @test length(p) == 5
            @test all([pp.name for pp in p] .== "P")
            @test all([pp.model for pp in p] .== "iasp91")
            @test p[end].delta ≈ 20.0
            @test p[end].depth ≈ 0.0
            @test p[end].time ≈ 279.8555618981382 atol=time_atol
            @test p[end].dtdd ≈ 9.484314474162678 atol=slow_atol
            @test p[end].inc ≈ 29.65049984974929 atol=angle_atol
            @test p[end].takeoff ≈ 29.65049984974929 atol=angle_atol
            @test p[end].pierce ≈ Float64[]
            @test p[end].distance ≈ Float64[]
            @test p[end].radius ≈ Float64[]
        end

        let h = 0, Δ = 60
            pp = travel_time(h, Δ, "P")
            ps = travel_time(h, Δ, "S")
            p = travel_time(h, Δ, ["P", "S"])
            @test length(p) == 2
            @test p[1].name == "P"
            @test p[2].name == "S"
            for f in fieldnames(Phase)
                @test getfield(pp[1], f) == getfield(p[1], f)
                @test getfield(ps[1], f) == getfield(p[2], f)
            end
        end
    end

    @testset "Path" begin
        let p = travel_time(100, 60, "ScS")[1]
            @test_throws ErrorException turning_depth(p)
        end

        let p = path(100, 120, "PKiKP")
            @test length(p) == 1
            @test p[1].model == "ak135"
            @test p[1].name == "PKiKP"
            @test p[1].delta ≈ 120.0
            @test p[1].depth ≈ 100.0
            @test p[1].time ≈ 1118.8440838099027 atol=time_atol
            @test p[1].dtdd ≈ 1.9568726794035047 atol=slow_atol
            @test p[1].inc ≈ 5.858483989177137 atol=angle_atol
            @test p[1].takeoff ≈ 8.272751909308088 atol=angle_atol
            @test p[1].pierce ≈ Float64[]
            distance = [0.0, 0.000731725, 0.0266589, 0.029084, 0.0315151, 0.0363955, 0.0462292, 0.0651594, 0.0844533, 0.0861091, 0.0877676, 0.105556, 0.123657, 0.150756, 0.156101, 0.161479, 0.178193, 0.195233, 0.223203, 0.226581, 0.229972, 0.247623, 0.256577, 0.265619, 0.281917, 0.298502, 0.300332, 0.302166, 0.320744, 0.330169, 0.339685, 0.358042, 0.376744, 0.377477, 0.378211, 0.397844, 0.407804, 0.417862, 0.43775, 0.458023, 0.464182, 0.470373, 0.482851, 0.507072, 0.531778, 0.545519, 0.581614, 0.634116, 0.636169, 0.68739, 0.730078, 0.743049, 0.800721, 0.827352, 0.8605, 0.921914, 0.928103, 0.935293, 0.94251, 0.957024, 0.99736, 1.03852, 1.04006, 1.04159, 1.08617, 1.13174, 1.15241, 1.19942, 1.24722, 1.26839, 1.35612, 1.38744, 1.46901, 1.50969, 1.59274, 1.59538, 1.59802, 1.6033, 1.6139, 1.62454, 1.63522, 1.65104, 1.66695, 1.69901, 1.73139, 1.76411, 1.7967, 1.82961, 1.86286, 1.89645, 1.96372, 2.03233, 2.10141, 2.17186, 2.24279, 2.31512, 2.39346, 2.39615, 2.39884, 2.40423, 2.41503, 2.43673, 2.45856, 2.46223, 2.48066, 2.52532, 2.54784, 2.5705, 2.6133, 2.6969, 2.76179, 2.76844, 2.82813, 2.92778, 2.9632, 3.03275, 3.09144, 3.10345, 3.24376, 3.25956, 3.31648, 3.39062, 3.43229, 3.53735, 3.60977, 3.6125, 3.68889, 3.79216, 3.84144, 3.92027, 3.97963, 4.00037, 4.15911, 4.17234, 4.24052, 4.32324, 4.37049, 4.48792, 4.57427, 4.65828, 4.78389, 4.99127, 4.99956, 5.00715, 5.22151, 5.3673, 5.45001, 5.6685, 5.68529, 5.73935, 5.92767, 6.12544, 6.1774, 6.41211, 6.43481, 6.52613, 6.70021, 6.94192, 6.97396, 7.24102, 7.25646, 7.37187, 7.5481, 7.82, 7.84929, 8.16052, 8.1682, 8.28289, 8.4823, 8.76297, 8.80831, 9.15608, 9.20474, 9.26455, 9.51632, 9.60282, 9.68997, 9.86622, 9.88627, 10.0755, 10.2678, 10.5686, 10.6266, 10.682, 10.6852, 10.6885, 10.6951, 10.7082, 10.7345, 10.761, 10.7877, 10.8414, 10.8685, 10.8957, 11.0106, 11.0695, 11.1293, 11.2493, 11.3108, 11.3733, 11.4986, 11.5628, 11.6281, 11.7591, 11.8262, 11.8944, 12.0312, 12.1013, 12.1725, 12.3156, 12.3888, 12.4632, 12.6128, 12.7671, 13.0705, 13.078, 13.0849, 13.2829, 13.4174, 13.4947, 13.6989, 13.7146, 13.7652, 13.9436, 14.1293, 14.1787, 14.4023, 14.4239, 14.5107, 14.6777, 14.9103, 14.9414, 15.2022, 15.2173, 15.3291, 15.5013, 15.7686, 15.7977, 16.1074, 16.1151, 16.2299, 16.4313, 16.7145, 16.7606, 17.1137, 17.1632, 17.2241, 17.4822, 17.5509, 17.6202, 17.7604, 17.7765, 17.9285, 18.0832, 18.3253, 18.3726, 18.4177, 18.433, 18.4483, 18.4791, 18.51, 18.541, 18.6033, 18.666, 18.7291, 18.7926, 18.921, 19.0745, 19.2304, 19.55, 19.7851, 19.9976, 20.2146, 20.5605, 20.918, 21.4383, 21.6636, 22.4552, 23.2971, 23.391, 24.1944, 25.1528, 25.7264, 26.1789, 27.2809, 28.4675, 28.5628, 29.7498, 31.1414, 32.6584, 34.3156, 36.156, 36.5983, 38.1971, 40.4906, 42.7234, 43.1012, 46.1224, 49.7054, 52.2481, 54.1233, 59.9402, 65.7571, 67.6323, 70.175, 73.758, 76.7791, 77.157, 79.3897, 81.6832, 83.282, 83.7243, 85.5647, 87.222, 88.739, 90.1305, 91.3175, 91.4129, 92.5995, 93.7014, 94.1539, 94.7276, 95.686, 96.4894, 96.5833, 97.4252, 98.2168, 98.4421, 98.9623, 99.3199, 99.6657, 99.8828, 100.095, 100.33, 100.65, 100.806, 100.959, 101.088, 101.151, 101.214, 101.277, 101.339, 101.37, 101.401, 101.432, 101.447, 101.463, 101.508, 101.555, 101.797, 101.952, 102.104, 102.12, 102.26, 102.329, 102.398, 102.656, 102.717, 102.767, 103.12, 103.166, 103.449, 103.65, 103.765, 103.773, 104.083, 104.112, 104.379, 104.551, 104.663, 104.678, 104.939, 104.97, 105.203, 105.37, 105.456, 105.478, 105.702, 105.751, 105.937, 106.115, 106.166, 106.181, 106.386, 106.463, 106.597, 106.795, 106.802, 106.81, 107.113, 107.268, 107.417, 107.492, 107.565, 107.708, 107.779, 107.849, 107.986, 108.054, 108.121, 108.252, 108.318, 108.382, 108.507, 108.57, 108.631, 108.751, 108.811, 108.87, 108.985, 109.012, 109.039, 109.093, 109.119, 109.146, 109.172, 109.185, 109.192, 109.195, 109.198, 109.254, 109.312, 109.613, 109.805, 109.994, 110.014, 110.19, 110.278, 110.364, 110.616, 110.676, 110.724, 111.072, 111.117, 111.398, 111.597, 111.712, 111.72, 112.031, 112.06, 112.332, 112.508, 112.624, 112.639, 112.906, 112.938, 113.18, 113.354, 113.446, 113.468, 113.703, 113.755, 113.953, 114.141, 114.195, 114.212, 114.43, 114.513, 114.659, 114.873, 114.881, 114.889, 115.096, 115.222, 115.306, 115.392, 115.51, 115.557, 115.64, 115.708, 115.721, 115.88, 115.901, 115.96, 116.039, 116.088, 116.191, 116.268, 116.271, 116.343, 116.448, 116.49, 116.564, 116.621, 116.637, 116.777, 116.789, 116.848, 116.917, 116.953, 117.052, 117.112, 117.119, 117.183, 117.267, 117.31, 117.333, 117.355, 117.4, 117.418, 117.422, 117.444, 117.465, 117.476, 117.482, 117.484, 117.487, 117.565, 117.638, 117.708, 117.779, 117.848, 117.917, 117.984, 118.017, 118.051, 118.084, 118.116, 118.149, 118.181, 118.213, 118.229, 118.245, 118.256, 118.266, 118.277, 118.282, 118.285, 118.288, 118.371, 118.411, 118.493, 118.524, 118.612, 118.633, 118.681, 118.728, 118.749, 118.794, 118.839, 118.84, 118.842, 118.883, 118.923, 118.938, 118.945, 118.952, 118.958, 119.02, 119.053, 119.08, 119.137, 119.15, 119.193, 119.244, 119.246, 119.299, 119.335, 119.349, 119.373, 119.398, 119.41, 119.416, 119.422, 119.443, 119.462, 119.473, 119.483, 119.502, 119.503, 119.504, 119.522, 119.541, 119.55, 119.56, 119.578, 119.58, 119.582, 119.598, 119.615, 119.624, 119.633, 119.65, 119.654, 119.657, 119.685, 119.702, 119.719, 119.724, 119.73, 119.757, 119.775, 119.793, 119.794, 119.796, 119.815, 119.834, 119.844, 119.849, 119.851, 119.854, 119.88, 119.88, 119.893, 119.905, 119.91, 119.924, 119.938, 119.945, 119.952, 119.959, 119.962, 119.964, 119.966, 119.974, 119.978, 119.979, 119.98, 119.981, 119.989, 119.994, 119.997, 119.999, 120.0]
            @test p[1].distance ≈ distance atol=0.01
            radius = [6271.0, 6270.45, 6251.0, 6249.19, 6247.37, 6243.74, 6236.44, 6222.49, 6208.41, 6207.2, 6206.0, 6193.15, 6180.19, 6161.0, 6157.24, 6153.48, 6141.84, 6130.07, 6111.0, 6108.72, 6106.43, 6094.57, 6088.6, 6082.6, 6071.85, 6061.0, 6059.81, 6058.62, 6046.59, 6040.53, 6034.44, 6022.78, 6011.0, 6010.54, 6010.08, 5997.84, 5991.67, 5985.47, 5973.29, 5961.0, 5957.42, 5953.83, 5946.63, 5932.75, 5918.74, 5911.0, 5890.88, 5862.11, 5861.0, 5833.51, 5811.0, 5804.23, 5774.52, 5761.0, 5744.36, 5714.02, 5711.0, 5707.7, 5704.39, 5697.75, 5679.46, 5661.0, 5660.32, 5659.63, 5639.89, 5619.96, 5611.0, 5590.78, 5570.44, 5561.5, 5524.89, 5512.0, 5478.82, 5462.5, 5429.6, 5428.57, 5427.53, 5425.46, 5421.31, 5417.16, 5413.0, 5406.85, 5400.69, 5388.34, 5375.94, 5363.5, 5351.19, 5338.83, 5326.44, 5314.0, 5289.33, 5264.5, 5239.83, 5215.0, 5190.33, 5165.5, 5138.98, 5138.08, 5137.17, 5135.36, 5131.74, 5124.49, 5117.22, 5116.0, 5109.89, 5095.17, 5087.79, 5080.39, 5066.5, 5039.66, 5019.1, 5017.0, 4998.3, 4967.5, 4956.67, 4935.6, 4918.0, 4914.42, 4873.09, 4868.5, 4852.04, 4830.82, 4819.0, 4789.53, 4769.5, 4768.75, 4747.86, 4720.0, 4706.85, 4686.03, 4670.5, 4665.11, 4624.35, 4621.0, 4603.81, 4583.18, 4571.5, 4542.81, 4522.0, 4501.99, 4472.5, 4424.88, 4423.0, 4421.28, 4373.5, 4341.75, 4324.0, 4277.99, 4274.5, 4263.33, 4225.0, 4185.68, 4175.5, 4130.3, 4126.0, 4108.8, 4076.5, 4032.71, 4027.0, 3980.17, 3977.5, 3957.72, 3928.0, 3883.24, 3878.5, 3829.0, 3827.8, 3809.98, 3779.5, 3737.65, 3731.0, 3681.0, 3674.14, 3665.76, 3631.0, 3619.25, 3607.49, 3583.98, 3581.33, 3556.5, 3531.67, 3493.61, 3486.37, 3479.5, 3478.76, 3478.01, 3476.52, 3473.55, 3467.59, 3461.62, 3455.64, 3443.67, 3437.67, 3431.67, 3406.65, 3394.03, 3381.34, 3356.32, 3343.7, 3331.01, 3305.98, 3293.37, 3280.68, 3255.64, 3243.02, 3230.34, 3205.3, 3192.69, 3180.01, 3154.97, 3142.35, 3129.68, 3104.63, 3079.35, 3031.26, 3030.09, 3029.02, 2998.77, 2978.69, 2967.31, 2937.78, 2935.54, 2928.36, 2903.42, 2878.03, 2871.39, 2841.76, 2838.94, 2827.7, 2806.37, 2777.36, 2773.54, 2742.03, 2740.24, 2727.03, 2707.03, 2676.7, 2673.45, 2639.5, 2638.67, 2626.37, 2605.15, 2576.04, 2571.39, 2536.4, 2531.59, 2525.71, 2501.16, 2494.73, 2488.29, 2475.38, 2473.91, 2460.12, 2446.3, 2425.05, 2420.96, 2417.07, 2415.75, 2414.43, 2411.8, 2409.16, 2406.52, 2401.23, 2395.94, 2390.64, 2385.34, 2374.72, 2362.18, 2349.61, 2324.38, 2306.26, 2290.18, 2274.05, 2248.94, 2223.72, 2188.29, 2173.39, 2123.06, 2072.73, 2067.31, 2022.4, 1972.07, 1943.5, 1921.74, 1871.4, 1821.07, 1817.19, 1770.74, 1720.41, 1670.08, 1619.91, 1569.42, 1558.03, 1519.09, 1468.76, 1425.29, 1418.42, 1368.09, 1317.76, 1287.35, 1267.43, 1217.5, 1267.43, 1287.35, 1317.76, 1368.09, 1418.42, 1425.29, 1468.76, 1519.09, 1558.03, 1569.42, 1619.91, 1670.08, 1720.41, 1770.74, 1817.19, 1821.07, 1871.4, 1921.74, 1943.5, 1972.07, 2022.4, 2067.31, 2072.73, 2123.06, 2173.39, 2188.29, 2223.72, 2248.94, 2274.05, 2290.18, 2306.26, 2324.38, 2349.61, 2362.18, 2374.72, 2385.34, 2390.64, 2395.94, 2401.23, 2406.52, 2409.16, 2411.8, 2414.43, 2415.75, 2417.07, 2420.96, 2425.05, 2446.3, 2460.12, 2473.91, 2475.38, 2488.29, 2494.73, 2501.16, 2525.71, 2531.59, 2536.4, 2571.39, 2576.04, 2605.15, 2626.37, 2638.67, 2639.5, 2673.45, 2676.7, 2707.03, 2727.03, 2740.24, 2742.03, 2773.54, 2777.36, 2806.37, 2827.7, 2838.94, 2841.76, 2871.39, 2878.03, 2903.42, 2928.36, 2935.54, 2937.78, 2967.31, 2978.69, 2998.77, 3029.02, 3030.09, 3031.26, 3079.35, 3104.63, 3129.68, 3142.35, 3154.97, 3180.01, 3192.69, 3205.3, 3230.34, 3243.02, 3255.64, 3280.68, 3293.37, 3305.98, 3331.01, 3343.7, 3356.32, 3381.34, 3394.03, 3406.65, 3431.67, 3437.67, 3443.67, 3455.64, 3461.62, 3467.59, 3473.55, 3476.52, 3478.01, 3478.76, 3479.5, 3486.37, 3493.61, 3531.67, 3556.5, 3581.33, 3583.98, 3607.49, 3619.25, 3631.0, 3665.76, 3674.14, 3681.0, 3731.0, 3737.65, 3779.5, 3809.98, 3827.8, 3829.0, 3878.5, 3883.24, 3928.0, 3957.72, 3977.5, 3980.17, 4027.0, 4032.71, 4076.5, 4108.8, 4126.0, 4130.3, 4175.5, 4185.68, 4225.0, 4263.33, 4274.5, 4277.99, 4324.0, 4341.75, 4373.5, 4421.28, 4423.0, 4424.88, 4472.5, 4501.99, 4522.0, 4542.81, 4571.5, 4583.18, 4603.81, 4621.0, 4624.35, 4665.11, 4670.5, 4686.03, 4706.85, 4720.0, 4747.86, 4768.75, 4769.5, 4789.53, 4819.0, 4830.82, 4852.04, 4868.5, 4873.09, 4914.42, 4918.0, 4935.6, 4956.67, 4967.5, 4998.3, 5017.0, 5019.1, 5039.66, 5066.5, 5080.39, 5087.79, 5095.17, 5109.89, 5116.0, 5117.22, 5124.49, 5131.74, 5135.36, 5137.17, 5138.08, 5138.98, 5165.5, 5190.33, 5215.0, 5239.83, 5264.5, 5289.33, 5314.0, 5326.44, 5338.83, 5351.19, 5363.5, 5375.94, 5388.34, 5400.69, 5406.85, 5413.0, 5417.16, 5421.31, 5425.46, 5427.53, 5428.57, 5429.6, 5462.5, 5478.82, 5512.0, 5524.89, 5561.5, 5570.44, 5590.78, 5611.0, 5619.96, 5639.89, 5659.63, 5660.32, 5661.0, 5679.46, 5697.75, 5704.39, 5707.7, 5711.0, 5714.02, 5744.36, 5761.0, 5774.52, 5804.23, 5811.0, 5833.51, 5861.0, 5862.11, 5890.88, 5911.0, 5918.74, 5932.75, 5946.63, 5953.83, 5957.42, 5961.0, 5973.29, 5985.47, 5991.67, 5997.84, 6010.08, 6010.54, 6011.0, 6022.78, 6034.44, 6040.53, 6046.59, 6058.62, 6059.81, 6061.0, 6071.85, 6082.6, 6088.6, 6094.57, 6106.43, 6108.72, 6111.0, 6130.07, 6141.84, 6153.48, 6157.24, 6161.0, 6180.19, 6193.15, 6206.0, 6207.2, 6208.41, 6222.49, 6236.44, 6243.74, 6247.37, 6249.19, 6251.0, 6270.45, 6271.0, 6280.17, 6289.89, 6293.5, 6304.13, 6314.76, 6320.07, 6325.38, 6330.69, 6333.35, 6334.67, 6336.0, 6343.5, 6347.25, 6349.13, 6350.06, 6351.0, 6359.05, 6365.02, 6368.01, 6369.51, 6371.0]
            @test p[1].radius ≈ radius atol=0.1
            @test turning_depth(p[1]) == TauPy.RADIUS[p[1].model] - minimum(p[1].radius)
        end
    end

    @testset "Operators" begin
        let p = travel_time(100, 60, "ScS"), p′ = travel_time(100, 60, "ScS"),
                q = travel_time(100, 60, "PcP")
            # Vectors of Phases
            @test p == p
            @test p == p′
            @test p == deepcopy(p)
            @test (p == q) == false
            # Individual Phases
            @test p[1] == p[1]
            @test p[1] == p′[1]
            @test p[1] == deepcopy(p[1])
            @test (p[1] == q[1]) == false
        end
    end
end

@testset "PhaseGeog" begin
    @testset "Time" begin
        # Test against taup_time, and assume we're on a spherical Earth
        let p = travel_time(0, 0, 300, 30, 30, "PcS", model="prem")
            @test p isa Vector{<:PhaseGeog}
            @test length(p) == 1
            @test p[1].model == "prem"
            @test p[1].name == "PcS"
            @test p[1].evlon ≈ 0.0
            @test p[1].evlat ≈ 0.0
            @test p[1].stlon ≈ 30.0
            @test p[1].stlat ≈ 30.0
            @test p[1].depth ≈ 300.0
            @test p[1].delta ≈ 41.4096 atol=0.001
            @test p[1].time ≈ 780.67 atol=0.01
            @test p[1].dtdd ≈ 4.000 atol=0.001
            @test p[1].inc ≈ 6.61 atol=0.01
            @test p[1].takeoff ≈ 19.1989 atol=0.01
            @test p[1].pierce ≈ Float64[]
            @test p[1].lon ≈ Float64[]
            @test p[1].lat ≈ Float64[]
            @test p[1].radius ≈ Float64[]
        end
    end

    @testset "Operators" begin
        let p = travel_time(0, 0, 300, 30, 30, "ScS"),
                p′ = travel_time(0, 0, 300, 30, 30, "ScS"),
                q = travel_time(0, 0, 300, 30, 30, "PcP")
            # Vectors of Phases
            @test p == p
            @test p == p′
            @test p == deepcopy(p)
            @test (p == q) == false
            # Individual Phases
            @test p[1] == p[1]
            @test p[1] == p′[1]
            @test p[1] == deepcopy(p[1])
            @test (p[1] == q[1]) == false
        end
    end

    @testset "Path" begin
        let elon = 0, elat = 0, depth = 100, slon = 45, slat = 45, phase = "P", model = "ak135"
            p = path(elon, elat, depth, slon, slat, "P", model=model)
            @test p isa Vector{<:PhaseGeog}
            @test length(p) == 1
            @test p[1].delta ≈ 60.0
            @test p[1].dtdd ≈ 6.835 atol=0.001
            @test p[1].evlon ≈ elon
            @test p[1].evlat ≈ elat
            @test p[1].stlon ≈ slon
            @test p[1].stlat ≈ slat
            @test p[1].inc ≈ 20.888 atol=0.001
            @test p[1].model == model
            @test p[1].takeoff ≈ 30.173 atol=0.001
            @test p[1].time ≈ 595.99 atol=0.01
            @test p[1].radius[1:5] ≈ [6271.00, 6270.44, 6251.00, 6249.18, 6247.37] atol=0.1
            @test length(p[1].lon) == length(p[1].lat) == length(p[1].radius)
        end
    end

    @testset "Cache" begin
        let Δ = rand(1:90), h = rand(0:700), phase = "P", model = "sp6"
            TauPy.clear_cache!()
            @test length(TauPy.RAY_CACHE) == length(TauPy.RAY_NCALLS) == 0
            p = travel_time(h, Δ, phase, model=model)
            @test first(values(TauPy.RAY_NCALLS)) == 1
            p′ = travel_time(h, Δ, phase, model=model)
            @test first(values(TauPy.RAY_NCALLS)) == 2
            @test p == p′
            @test travel_time(h, Δ, phase, model=model, cache=false) == p
            @test first(values(TauPy.RAY_NCALLS)) == 2
        end
    end
end
