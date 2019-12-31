#!/usr/bin/env python3

n_A = 25
n_B = 740
rho_total_red = 1.1
sigma = 3.73

rho_total = rho_total_red / sigma ** 3

vol = (1/rho_total) * (n_A + n_B) 
vol = vol ** (1./3.)

print(vol)
