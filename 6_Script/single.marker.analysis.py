#!/usr/bin/ python
# -*- coding: utf-8 -*-
__author__ = 'shengwei ma'
__author_email__ = 'shengweima@icloud.com'


import argparse
import pandas as pd
import gzip
from statsmodels.stats.diagnostic import lilliefors
from scipy import stats
from statsmodels.stats.multicomp import MultiComparison
import scikit_posthocs as sp

parser = argparse.ArgumentParser(description='输入参数如下:')
parser.add_argument('--phe', '-P', help='phenotype file，必要参数', required=True)
parser.add_argument('--vcf', '-V', help='gene vcf.gz file，必要参数', required=True)
parser.add_argument('--out', '-O', help='output result', required=True)
args = parser.parse_args()

outfile = open(args.out,'w')
outfile.write('Trait\tVatiant_ID\tGene|eff\tGenotye_count\tPvalue\tPairs\n')
nuc = ['A', 'C', 'G', 'T']
samples = []
phe_data = dict()
geno_data = dict()
variants_info = dict()
with open(args.phe, 'r') as f:
    for line in f:
        lin = line.strip().split('\t')
        new = []
        if line.startswith('ID'):
            new.extend(lin[1:])
        else:    
            for li in lin[1:]:
                if li =='NA':
                    new.append('NaN')
                else:
                    new.append(float(li))   
        phe_data[lin[0]] = new

  

with open(args.vcf, 'rt') as vcf:
        
    for num, line in enumerate(vcf):
        if line.startswith('##'):
            pass
        elif line.startswith('#CHROM'):
            lin = line.split('\t')
            for i in lin[9:]:
                samples.append(i)    
            geno_data[lin[2]] =samples    
        else:
            gt = []
            lin = line.strip().split('\t')
            ref_len = len(lin[3].split(','))
            alt_len = len(lin[4].split(','))
            if ref_len == 1 and alt_len == 1:
                if  lin[3] in nuc and lin[4] in nuc:
                    lin[2] = 's' + lin[0].lstrip('chr') + '_' + str(lin[1]).rjust(9, '0')
                else:
                    lin[2] = 'iad' + lin[0].lstrip('chr') + '_' + str(lin[1]).rjust(9, '0')
            else:
                lin[2] = 'mul' + lin[0].lstrip('chr') + '_' + str(lin[1]).rjust(9, '0')
            variants_info[lin[2]] = []    
            if 'ANN=' in lin[7]:
                new = lin[7].split(';')
                for i in new:
                    if 'ANN=' in i:
                        anns = i.split(',')
                        for ann in anns:
                            if len(ann.split('|'))>=6:
                                name = ann.split('|')[6]
                                eff = ann.split('|')[1]
                                if lin[2] in variants_info.keys():
                                    variants_info[lin[2]].append(name + '|' + eff)
                               
            for index, li in enumerate(lin[9:]):
                g = li.split(':')[0]
                gt.append(g)
            geno_data[lin[2]] = gt

for trait,value in phe_data.items():
    if trait == 'ID':
        pass
    else:
        for variant_id, gt in geno_data.items():
            if variant_id == 'ID':
                pass
            else:
                out_list = []
                out_list.append(trait)
                out_list.append(variant_id)
                if variant_id in variants_info.keys():
                    out_list.append(','.join(variants_info[variant_id]))
                phe_geno = dict()
                new_phe_geno = dict()
                for index, i in enumerate(value):
                    if i == 'NaN':
                        pass
                    else:
                        sample = phe_data['ID'][index]
                        if sample in geno_data['ID']:
                            index_gt = geno_data['ID'].index(sample)
                            geno = gt[index_gt]
                            if geno in phe_geno:
                                phe_geno[geno].append(i)
                            else:
                                phe_geno[geno] = [i]
                        else:
                            pass
                            # print(sample + ' not in vcf files')
                for k, v in phe_geno.items():
                    if len(v) <=10:
                        pass
                    else:
                        new_phe_geno[k] = v
                if len(new_phe_geno.keys()) <=1 :
                    pass       
                else:
                    count_gt = []
                    for k,v in new_phe_geno.items():
                        count_gt.append(k + ':' + str(len(v)))
                    out_list.append(','.join(count_gt))    
                    df_phe = pd.DataFrame.from_dict(new_phe_geno,orient='index')
                    df = df_phe.T
                    data_new = df.stack().reset_index().rename(columns={0:'value'}).iloc[:,1:]
                    data_new.columns = ['genotype','value']
                    #print(trait + '    '+ variant_id)
                    norm_pvalue_list = [lilliefors(sample, pvalmethod="table")[1] for sample in list(new_phe_geno.values())]                            
                    norm_results = []
                    for p in norm_pvalue_list:  
                        if p > 0.1:
                            norm_results.append(True)
                        else:
                            norm_results.append(False)
                    if False not in norm_results:
                        #print("正态")
                        if stats.levene(*new_phe_geno.values(), center="mean")[1] > 0.1:
                            # print("正态，方差齐，参检")
                            result_f_oneway = stats.f_oneway(*new_phe_geno.values())
                            #print(result_f_oneway[1])
                            out_list.append(str(result_f_oneway[1]))
                            #print("事后多重比较：turkey")
                            result_turkey = MultiComparison(data_new['value'], data_new['genotype']).tukeyhsd()
                            df = pd.DataFrame(data=result_turkey._results_table.data[1:], columns=result_turkey._results_table.data[0])
                            dict_list = []
                            for index,v in df.iterrows():
                                if v[0] + 'vs' + v[1] + '=' + str(v[3]) in dict_list:
                                    pass
                                else:
                                    dict_list.append(v[0] + 'vs' + v[1] + '=' + str(v[3]))
                            out_list.append(','.join(dict_list))
                            outfile.write('\t'.join(out_list) + '\n')
                        else:
                            #print("正态，方差不齐，非参")
                            result_kruskalwallis = stats.mstats.kruskalwallis(*new_phe_geno.values())
                            out_list.append(str(result_kruskalwallis[1]))
                            #print("事后多重比较：Dunn's")
                            result_Dunn = sp.posthoc_dunn(data_new, val_col="value", group_col="genotype", p_adjust='holm')
                            dict0 = result_Dunn.to_dict()
                            dict_list = []
                            for k,v in dict0.items():
                                for m, n in v.items():
                                    if k == m:
                                        pass
                                    else:
                                        if m + 'vs' + k + '=' + str(n) in dict_list:
                                            pass
                                        else:
                                            dict_list.append(k + 'vs' + m + '=' + str(n))
                            out_list.append(','.join(dict_list))
                            outfile.write('\t'.join(out_list) + '\n')
                    else:
                        #print("非正态")
                        result_kruskalwallis = stats.mstats.kruskalwallis(*new_phe_geno.values())
                        out_list.append(str(result_kruskalwallis[1]))
                        result_Dunn = sp.posthoc_dunn(data_new, val_col="value", group_col="genotype", p_adjust='holm')
                        dict0 = result_Dunn.to_dict()
                        dict_list = []
                        for k,v in dict0.items():
                            for m, n in v.items():
                                if k == m:
                                    pass
                                else:
                                    if m + 'vs' + k + '=' + str(n) in dict_list:
                                        pass
                                    else:
                                        dict_list.append(k + 'vs' + m + '=' + str(n))
                        out_list.append(','.join(dict_list))
                        outfile.write('\t'.join(out_list) + '\n')
                
outfile.close()                        
