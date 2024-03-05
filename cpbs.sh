cpbs(){
    echo -e 'This is a toolkit for creating PBS jobs.'
    echo -e 'Choose the Function [Number] you want:'
    echo -e '[1] Generated directly with default parameters'
    echo -e '[2] Customized generation'
    echo -e 'input your choose (default:1): \c'
    read cpbs_func_num
    if [ -z "${cpbs_func_num}" ];then
        cpbs_func_num=1
    fi
    if [ "${cpbs_func_num}" = 1 ];then
        cpbs_default
    elif [ "${cpbs_func_num}" = 2 ];then
        cpbs_custom
    else
        echo 'Invalid Input!'
    fi
    unset cpbs_func_num
}

cpbs_default(){

    job_name=$(date +%Y%m%d%H%M%S)
    queue=normal
    nodes=1
    cpus=32
    gpus=8
    memory=100
    walltime=24:00:00
    project_number=11003054

    output_file=$(pwd)/${job_name}.o
    error_file=$(pwd)/${job_name}.e

    # generate the PBS script
    cat << EOF > ${job_name}.pbs
#PBS -q ${queue}
#PBS -l select=${nodes}:ncpus=${cpus}:ngpus=${gpus}:mem=${memory}G
#PBS -l walltime=${walltime}
#PBS -P ${project_number}
#PBS -N ${job_name}
#PBS -o ${output_file}
#PBS -e ${error_file}

module load miniforge3/23.10
module load cuda/12.2.2
EOF

    echo "The PBS script has been generated successfully!"
}

cpbs_custom(){
    echo -e 'Specifying a job name (default:$date): \c'
    read job_name
    if [ -z "${job_name}" ];then
        job_name=$(date +%Y%m%d%H%M%S)
    fi
    echo -e 'Specifying queue and/or server (default:normal): \c'
    read queue
    if [ -z "${queue}" ];then
        queue=normal
    fi
    echo -e 'Specifying the number of nodes (default:1): \c'
    read nodes
    if [ -z "${nodes}" ];then
        nodes=1
    fi
    echo -e 'Specifying the number of cpus (default:32): \c'
    read cpus
    if [ -z "${cpus}" ];then
        cpus=32
    fi
    echo -e 'Specifying the number of gpus (default:8): \c'
    read gpus
    if [ -z "${gpus}" ];then
        gpus=8
    fi
    echo -e 'Specifying the memory - unit GB (default:100): \c'
    read memory
    if [ -z "${memory}" ];then
        memory=100
    fi
    echo -e 'Specifying the walltime - unit hour (default:24): \c'
    read walltime
    if [ -z "${walltime}" ];then
        walltime=24
    fi
    walltime=${walltime}:00:00
    echo -e 'Specifying the project number (default:11003054): \c'
    read project_number
    if [ -z "${project_number}" ];then
        project_number=11003054
    fi
    echo -e 'Specifying the output file (default:$(pwd)/${job_name}.o): \c'
    read output_file
    if [ -z "${output_file}" ];then
        output_file=$(pwd)/${job_name}.o
    fi
    echo -e 'Specifying the error file (default:$(pwd)/${job_name}.e): \c'
    read error_file
    if [ -z "${error_file}" ];then
        error_file=$(pwd)/${job_name}.e
    fi
    # generate the PBS script
    cat << EOF > ${job_name}.pbs
#PBS -q ${queue}
#PBS -l select=${nodes}:ncpus=${cpus}:ngpus=${gpus}:mem=${memory}G
#PBS -l walltime=${walltime}
#PBS -P ${project_number}
#PBS -N ${job_name}
#PBS -o ${output_file}
#PBS -e ${error_file}
EOF
    echo -e 'Specifying the command: \c'
    read command
    echo "${command}" >> ${job_name}.pbs
    echo "The PBS script has been generated successfully!"
}
