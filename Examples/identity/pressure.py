P = 9.53
sigma = 3.607
epsilon = 161.0

bar_to_Pa = 100000
k_boltz = 1.380649E-23 # in J/K
m_to_ang = 1E10
avogadro = 6.023E23

P_r = P * sigma ** 3 / epsilon * bar_to_Pa * (1/m_to_ang) ** 3 / k_boltz
   
# [bar] * [ang]^3        J             1m^3              K
#------------------- * ----------- * ----------  * ------------
#         K            m^3  bar         1E10 a^3   1.38064E-23 J
# 

print(P_r)



###########
###########
###########

P_r = 0.5

bar_to_Pa = 100000
k_boltz = 1.380649E-23 # in J/K
m_to_ang = 1E10
avogadro = 6.023E23

P = P_r * epsilon / ( sigma ** 3) * k_boltz * m_to_ang **3 / bar_to_Pa
  
print(P)
