#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  top_topics.py
#  
#  @author: Ulrike Henny-Krahmer
#  
#  This program calculates the relative number of different top topics
#  in a corpus of texts in two periods, which are compared. It has been
#  tested with Python 3.10.6 on Ubuntu 22.04 LTS.
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  

from os.path import join
import pandas as pd
import math

def main(args):
    
    ########################
    # SETTINGS:
    # change these if you need to adapt paths to the data or the criteria to differentiate the groups
    wdir = "/home/ulrike/Documents"
    data_file = join(wdir, "topicsexplorer-data/document-topic-distribution.csv")
    md_file = join(wdir, "2022_HD-en-el-aula-de-literatura/metadata.csv")
    # at which value to divide the group (here: before (1810-1879) and after 1800 (1880-1900)):
    group_div = 1880
    # for which category to divide the group:
    group_cat = "decade"
    ########################
    
    data = pd.read_csv(data_file, index_col=0, header=0, sep=";")
    md = pd.read_csv(md_file, index_col=0, header=0, sep=",")

    md_pre = md.loc[md[group_cat] < group_div]
    md_post = md.loc[md[group_cat] >= group_div]
    
    # look up which data rows are in the pre and post groups
    data_pre = pd.DataFrame()
    
    for index_entry in md_pre.index:
        data_entry_pre = data[data.index.str.contains(index_entry)]
        data_pre = pd.concat([data_pre, data_entry_pre], ignore_index=True)
        
        
    data_post = pd.DataFrame()
    
    for index_entry in md_post.index:
        data_entry_post = data[data.index.str.contains(index_entry)]
        data_post = pd.concat([data_post, data_entry_post], ignore_index=True)
    
    # count how many different top topics we have in the two groups:
    data_pre_max = len(set(list(data_pre.idxmax(axis=1))))
    data_post_max = len(set(list(data_post.idxmax(axis=1))))
    
    num_pre = len(data_pre)
    num_post = len(data_post)
    
    pre_max_rel = data_pre_max / num_pre
    post_max_rel = data_post_max / num_post
    
    print("pre_max: " + str(data_pre_max))
    print("num_pre: " + str(num_pre))
    print("pre_max_rel: " + str(pre_max_rel))
    
    print("post_max: " + str(data_post_max))
    print("num_post: " + str(num_post))
    print("post_max_rel: " + str(post_max_rel))
    
    # make significance test (z-test for two proportions)
    # formula: z \= (p1-p2) / √p(1-p)(1/n1+1/n2)
    # where p is p = (p1n1 + p2n2)/(n1+n2)
    
    p = (pre_max_rel * num_pre + post_max_rel * num_post) / (num_pre + num_post)
    
    z = (pre_max_rel - post_max_rel) / math.sqrt(p * (1-p) * (1/num_pre + 1/num_post))
    
    print("z: " + str(z))
    
    
    
    
    
    

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))
