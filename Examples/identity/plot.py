#!/usr/bin/env python3
import matplotlib.pyplot as plt
import pandas
import click

@click.command()
@click.option('--species', default=1, help='System pressure.')
@click.option('--epsilon', default=148.0, help='System pressure.')
@click.option('--sigma', default=3.73, help='System pressure.')
@click.option('--box1', default='gemc.out.box1.prp', help='System pressure.')
@click.option('--box2', default='gemc.out.box2.prp', help='System pressure.')
@click.option('--prp', default='Mol_Fraction', help='System pressure.')
def plot(species, epsilon, sigma, box1, box2, prp):

    bar_to_Pa = 100000
    k_boltz = 1.380649E-23 # in J/K
    m_to_ang = 1E10
    avogadro = 6.023E23
    
    colnames = ['Energy_Total', 'Density_1', 'Density_2', 'Nmols_1', 'Nmols_2', 'Volume', 'Pressure']
    ref_box1 = pandas.read_table(box1, names=colnames, skiprows=3, sep='\s+')
    ref_box2 = pandas.read_table(box2, names=colnames, skiprows=3, sep='\s+')
   
    if prp == 'Density':
        ref_box1['Density_'+str(species)+'_red_b1'] = ref_box1['Density_'+str(species)] * sigma ** 3
        ref_box2['Density_'+str(species)+'_red_b2'] = ref_box2['Density_'+str(species)] * sigma ** 3

    elif prp == 'Total_Density':
        ref_box1['Total_Density_red_b1'] = (ref_box1['Density_1'] + ref_box1['Density_2']) * sigma ** 3
        ref_box2['Total_Density_red_b2'] = (ref_box2['Density_1'] + ref_box2['Density_2']) * sigma ** 3
   
    elif prp == 'Mol_Fraction':
        ref_box1['Mol_Fraction_'+str(species)+'_b1'] = ref_box1['Nmols_'+str(species)] / (ref_box1['Nmols_1'] + ref_box1['Nmols_2'])
        ref_box2['Mol_Fraction_'+str(species)+'_b2'] = ref_box2['Nmols_'+str(species)] / (ref_box2['Nmols_1'] + ref_box2['Nmols_2'])

    elif prp == 'Pressure':
    
        bar_to_reduced = bar_to_Pa * (1/m_to_ang)**3 / k_boltz
        ref_box1['Pressure_red_b1'] = ref_box1['Pressure'] * sigma ** 3 / epsilon * bar_to_reduced 
        ref_box2['Pressure_red_b2'] = ref_box2['Pressure'] * sigma ** 3 / epsilon * bar_to_reduced 
    
    df_plot = pandas.concat([ref_box1[prp + '_'+str(species)+'_b1'], ref_box2[prp +'_'+str(species)+'_b2']], axis=1)
    df_plot.plot(y=[prp + '_'+str(species)+'_b1', prp + '_'+str(species)+'_b2'], figsize=(10,5), grid=True)
    plt.show()
    
if __name__ == '__main__':
    plot()
