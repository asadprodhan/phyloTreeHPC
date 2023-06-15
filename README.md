# **phyloTreeHPC, an automated, reproducible, and scalable workflow for Bayesian phylogenetic analysis using a HPC cluster, Nextflow, and Singularity container** <br />

<br />

### **Asad Prodhan PhD** 


**https://asadprodhan.github.io/**


<br />


## **Step 1: Prepare the input files**


- Log in into your HPC cluster
 

- Transfer the following files to your HPC cluster and keep them in the same directory


	- Alignment file(s) (nexus format, e.g., cox1_alignment.nex). Note that your alignment files must end up with '_alignment.nex'. Make sure that the IDs in the alignment file do not have quotation marks (‘NC095897.2’). MrBayes program cannot read the names that are within quotation marks 



	- The MrBayes parameter file, zzz_mrbayes_parameters.nex. It contains the analysis run parameters (parameters in the “zzz_mrbayes_parameters.nex” file are explained below). You can modify them but must keep the file name same, i.e., “zzz_mrbayes_parameters_ref.nex”



	- The following three scripts (main.nf, nextflow.config, slurm_script.sh). ‘nextflow.config’ and the ‘slurm_script.sh’ can be modified to request more or less computing resources such as cpus, RAM, nodes, time etc



	- Make the scripts executable by running the following command




	```
	chmod +x *
	```

<br />


### **main.nf**


```
#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//data_location

params.in = "$PWD/*_alignment.nex"
params.ref = "$PWD/*_ref.nex"

// results location

params.outdir = './results'


// process mrbayes

process mrbayes {
	tag { file }
	publishDir "${params.outdir}", mode:'copy'

	input:
	path (file)

	output:
	path "${file.simpleName}.mrbayes*"
	
	script:
	"""
	cat $file ${params.ref} > ${file.simpleName}.mrbayes  
	mb ${file.simpleName}.mrbayes 

	"""
}

// workflow
workflow {

	Channel.fromPath(params.in) | mrbayes
}

```

<br />



### **nextflow.config**


```
resume = true

trace {
  fields = 'name,hash,status,exit,realtime,submit'
}

profiles {

setonix {
  workDir = "$PWD/work"
  process {
    cache = 'lenient'
    stageInMode = 'symlink'
  }

process {
    
    withName:mrbayes        { container = 'quay.io/biocontainers/mrbayes:3.2.7--h760cbc2_0' }
   
}

singularity {
 enabled = true
 autoMounts = true
 //runOptions = '-e TERM=xterm-256color'
 envWhitelist = 'TERM'
}

params.slurm_account = 'XXXXXX'
  process {
    executor = 'slurm'
    clusterOptions = "--account=${params.slurm_account}"
    queue = 'work'
    cpus = 1
    time = '1h'
    memory = '10GB'
    
    
    withName: 'mrbayes' {
      cpus = 18
      time = '24h'
      memory = '64GB'
    }
    
      
}
}
}
```

<br />


### **slurm_script.sh**


```
#!/bin/bash --login 
#SBATCH --job-name=nxf-master 
#SBATCH --account=XXXXXXX 
#SBATCH --partition=work
#SBATCH --time=1-00:00:00
#SBATCH --no-requeue 
#SBATCH --export=none 
#SBATCH --nodes=1

unset SBATCH_EXPORT 
module load openjdk/17.0.0_35
module load singularity/3.8.6 
module load nextflow/22.04.3 

nextflow run main.nf -profile setonix -name nxf-${SLURM_JOB_ID} -resume --with-report
```


## **Step 2: Run the analysis as follows**


```
srun ./slurm_script.sh
```


## **MrBayes process is running**


<br />
<p align="center">
  <img 
    src="https://github.com/asadprodhan/phyloTreeHPC/blob/main/mrbayes_process_running.PNG"
  >
</p>
<p align = "center">
Figure 1. MrBayes process is running
</p>



## **MrBayes process is completed**


<br />
<p align="center">
  <img 
    src="https://github.com/asadprodhan/phyloTreeHPC/blob/main/mrbayes_process_completed.PNG"
  >
</p>
<p align = "center">
Figure 2.MrBayes process is completed
</p>




## **Step 3: Collects the ‘results’ directory**


 
 - Visualise the tree 
 
 
    - ‘yourAlignmentName.mrbayes.con.tre’ is the file that contains the tree with the ‘posterior probability’ supports



## **Parameters in the “zzz_mrbayes_parameters.nex” file explained**



- “lset nst=6 rates=invgamma” sets a nucleotide substitution model called “GTR + I + G” 


> The usage of maximum likelihood method in phylogenetic analysis requires a nucleotide substitution model such as “GTR + I + G”. “GTR + I + G” is a widely used General Time Reversible (GTR) nucleotide substitution model with gamma-distributed rate variation across sites (G) and a proportion of invariable sites (I).  The invariable sites account for the static, unchanging sites in a dataset. 



- “ngen” is the number of generations for which the analysis will be run


- “printfreq” controls the frequency with which brief info about the analysis is printed to screen. The default value is 1,000.


- “samplefreq” determines how often the chain is sampled; the default is every 500 generations


- diagnostics calculated every “diagnfreq” generation


- By default, MrBayes uses Metropolis coupling to improve the MCMC sampling of the target distribution. The Swapfreq, Nswaps, Nchains, and Temp settings together control the Metropolis coupling behavior. When Nchains is set to 1, no heating is used. When Nchains is set to a value n larger than 1, then n−1 heated chains are used. By default, Nchains is set to 4, meaning that MrBayes will use 3 heated chains and one “cold” chain.


- “sumt” summarises statistics and creates five additional files


- “sump” summarises the parameter values


- sumt or sump is calculated as  = (number of generations/sample frequency)/4 


> ‘4’ represents 25%


- Every time the diagnostics are calculated, either a fixed number of samples (burnin) or a percentage of samples (burninfrac) from the beginning of the chain is discarded.
