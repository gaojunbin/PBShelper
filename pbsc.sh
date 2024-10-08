pbsc(){
    echo -e 'This is a toolkit for creating PBS jobs config file.'
    echo -e 'Choose the Function [Number] you want:'
    echo -e '[1] Customized generation'
    echo -e '[2] Template - HPC'
    echo -e '[3] Template - NSCC CPU'
    echo -e '[4] Template - NSCC GPU'
    echo -e '[5] Occupy   - NSCC GPU'
    echo -e 'input your choose (default:1): \c'
    read cpbs_func_num
    if [ -z "${cpbs_func_num}" ];then
        cpbs_func_num=1
    fi
    if [ "${cpbs_func_num}" = 1 ];then
        cpbs_custom
    elif [ "${cpbs_func_num}" = 2 ];then
        cpbs_default_hpc
    elif [ "${cpbs_func_num}" = 3 ];then
        cpbs_default_nscc_cpu
    elif [ "${cpbs_func_num}" = 4 ];then
        cpbs_default_nscc_gpu
    elif [ "${cpbs_func_num}" = 5 ];then
        cpbs_occupy_nscc_gpu
    else
        echo 'Invalid Input!'
    fi
    unset cpbs_func_num
}

cpbs_custom(){
    echo -e 'Specifying a job name (default:$date): \c'
    read job_name
    if [ -z "${job_name}" ];then
        job_name=$(date +%Y%m%d%H%M%S)
    fi
    mkdir -p ${job_name}
    cd ${job_name}
    echo -e 'Specifying queue and/or server (default:normal, option: normal, ai, colo-bliu): \c'
    read queue
    if [ -z "${queue}" ];then
        queue=normal
    fi
    echo -e 'Specifying the number of nodes (default:1): \c'
    read nodes
    if [ -z "${nodes}" ];then
        nodes=1
    fi
    echo -e 'Specifying the number of cpus (default:16): \c'
    read cpus
    if [ -z "${cpus}" ];then
        cpus=16
    fi
    echo -e 'Specifying the number of gpus (default:1): \c'
    read gpus
    if [ -z "${gpus}" ];then
        gpus=1
    fi
    echo -e 'Specifying the memory - unit GB (default:120): \c'
    read memory
    if [ -z "${memory}" ];then
        memory=120
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

    INFO=$(pwd)/${job_name}.info
    ssh_node=$(pwd)/ssh_node
    delete_all=$(pwd)/delete_all

    ports=("RmatePort" "-R" "JupyterPort" "-L" "TensorboardPort" "-L")
    local ssh_info="ssh \$(hostname)"

    if [ -n "$ZSH_VERSION" ]; then
        index_offset=1  # Zsh 从 1 开始
    else
        index_offset=0  # Bash 从 0 开始
    fi

    # 遍历数组，根据不同的 shell 调整索引
    for ((i=$index_offset; i<${#ports[@]}; i+=2)); do
        port_name="${ports[$i]}"
        port_flag="${ports[$((i+1))]}"
        
        # 使用 eval 获取环境变量的值
        port_value=$(eval echo \$$port_name)

        if [ -n "$port_value" ]; then
            # 拼接 ssh_info，确保每个部分之间有空格，并使用正确的端口转发格式
            ssh_info="$ssh_info $port_flag ${port_value}:localhost:${port_value}"
        fi
    done


    # generate the PBS script
    cat << EOF > ${job_name}.pbs
#PBS -q ${queue}
#PBS -l select=${nodes}:ncpus=${cpus}:ngpus=${gpus}:mem=${memory}G
#PBS -l walltime=${walltime}
#PBS -P ${project_number}
#PBS -N ${job_name}
#PBS -o ${output_file}
#PBS -e ${error_file}

echo "PBS_JOBID: \$PBS_JOBID" > ${INFO}
echo "hostname: \$(hostname)" >> ${INFO}

echo "export PBS_JOBID=\$PBS_JOBID" > ${ssh_node}
echo "${ssh_info}" >> ${ssh_node}

echo "rm *.e *.o *.info ssh_node delete_all" > ${delete_all}

chmod +x ${ssh_node}
chmod +x ${delete_all}

EOF
    echo -e 'Add infinite loop ([y]/n) : \c'
    read infinite_loop
    infinite_loop=${infinite_loop:-y}
    if [ "${infinite_loop}" = 'y' ];then
        echo "while true
do
    sleep 1
done" >> ${job_name}.pbs
    fi
    echo -e 'Specifying the command: \c'
    read command
    echo "${command}" >> ${job_name}.pbs
    echo "The PBS script has been generated successfully!"
}


cpbs_default_hpc(){
    echo -e 'Specifying a job name (default:$date): \c'
    read job_name
    job_name=${job_name:-$(date +%Y%m%d%H%M%S)}
    mkdir -p ${job_name}
    cd ${job_name}
    queue=colo-bliu
    nodes=1
    cpus=8
    memory=32
    walltime=20:00:00

    output_file=$(pwd)/${job_name}.o
    error_file=$(pwd)/${job_name}.e

    INFO=$(pwd)/${job_name}.info
    ssh_node=$(pwd)/ssh_node
    delete_all=$(pwd)/delete_all

    if [ -z "$RmatePort" ]; then
        local ssh_info="ssh \$(hostname)"
    else
        local ssh_info="ssh -R ${RmatePort}:localhost:${RmatePort} \$(hostname)"
    fi

    # generate the PBS script
    cat << EOF > ${job_name}.pbs
#PBS -q ${queue}
#PBS -l select=${nodes}:ncpus=${cpus}:mem=${memory}G
#PBS -l walltime=${walltime}
#PBS -N ${job_name}
#PBS -o ${output_file}
#PBS -e ${error_file}

echo "PBS_JOBID: \$PBS_JOBID" > ${INFO}
echo "hostname: \$(hostname)" >> ${INFO}

echo "export PBS_JOBID=\$PBS_JOBID" > ${ssh_node}
echo "${ssh_info}" >> ${ssh_node}

echo "rm *.e *.o *.info ssh_node delete_all" > ${delete_all}

chmod +x ${ssh_node}
chmod +x ${delete_all}

while true
do
    sleep 1
done
EOF

    echo "The PBS script has been generated successfully!"
}

cpbs_default_nscc_cpu(){
    echo -e 'Specifying a job name (default:$date): \c'
    read job_name
    job_name=${job_name:-$(date +%Y%m%d%H%M%S)}
    mkdir -p ${job_name}
    cd ${job_name}
    queue=normal
    nodes=1
    cpus=32
    memory=100
    walltime=20:00:00
    project_number=11003054

    output_file=$(pwd)/${job_name}.o
    error_file=$(pwd)/${job_name}.e

    INFO=$(pwd)/${job_name}.info
    ssh_node=$(pwd)/ssh_node
    delete_all=$(pwd)/delete_all

    if [ -z "$RmatePort" ]; then
        local ssh_info="ssh \$(hostname)"
    else
        local ssh_info="ssh -R ${RmatePort}:localhost:${RmatePort} \$(hostname)"
    fi

    # generate the PBS script
    cat << EOF > ${job_name}.pbs
#PBS -q ${queue}
#PBS -l select=${nodes}:ncpus=${cpus}:mem=${memory}G
#PBS -l walltime=${walltime}
#PBS -P ${project_number}
#PBS -N ${job_name}
#PBS -o ${output_file}
#PBS -e ${error_file}

module load miniforge3/23.10

echo "PBS_JOBID: \$PBS_JOBID" > ${INFO}
echo "hostname: \$(hostname)" >> ${INFO}

echo "export PBS_JOBID=\$PBS_JOBID" > ${ssh_node}
echo "${ssh_info}" >> ${ssh_node}

echo "rm *.e *.o *.info ssh_node delete_all" > ${delete_all}

chmod +x ${ssh_node}
chmod +x ${delete_all}

while true
do
    sleep 1
done

EOF

    echo "The PBS script has been generated successfully!"
}

cpbs_default_nscc_gpu(){

    echo -e 'Specifying a job name (default:$date): \c'
    read job_name
    job_name=${job_name:-$(date +%Y%m%d%H%M%S)}
    mkdir -p ${job_name}
    cd ${job_name}
    queue=normal
    nodes=1
    gpus=4
    walltime=20:00:00
    project_number=11003054

    output_file=$(pwd)/${job_name}.o
    error_file=$(pwd)/${job_name}.e

    INFO=$(pwd)/${job_name}.info
    ssh_node=$(pwd)/ssh_node
    delete_all=$(pwd)/delete_all

    if [ -z "$RmatePort" ]; then
        local ssh_info="ssh \$(hostname)"
    else
        local ssh_info="ssh -R ${RmatePort}:localhost:${RmatePort} \$(hostname)"
    fi

    # generate the PBS script
    cat << EOF > ${job_name}.pbs
#PBS -q ${queue}
#PBS -l select=${nodes}:ngpus=${gpus}
#PBS -l walltime=${walltime}
#PBS -P ${project_number}
#PBS -N ${job_name}
#PBS -o ${output_file}
#PBS -e ${error_file}

module load miniforge3/23.10
module load cuda/12.2.2

echo "PBS_JOBID: \$PBS_JOBID" > ${INFO}
echo "hostname: \$(hostname)" >> ${INFO}
echo "GPU: \$(nvidia-smi)" >> ${INFO}

echo "export PBS_JOBID=\$PBS_JOBID" > ${ssh_node}
echo "${ssh_info}" >> ${ssh_node}

echo "rm *.e *.o *.info ssh_node delete_all" > ${delete_all}

chmod +x ${ssh_node}
chmod +x ${delete_all}

while true
do
    sleep 1
done

EOF

    echo "The PBS script has been generated successfully!"
}

cpbs_occupy_nscc_gpu(){
    echo -e 'Specifying number of gpus (default:1): \c'
    read gpus
    if [ -z "${gpus}" ];then
        gpus=1
    fi
    job_name="OCCUPY_GPU_x${gpus}"
    mkdir -p ${job_name}
    cd ${job_name}
    queue=normal
    nodes=1
    walltime=20:00:00
    project_number=11003054

    output_file=$(pwd)/${job_name}.o
    error_file=$(pwd)/${job_name}.e

    INFO=$(pwd)/${job_name}.info
    ssh_node=$(pwd)/ssh_node
    delete_all=$(pwd)/delete_all

    if [ -z "$RmatePort" ]; then
        local ssh_info="ssh \$(hostname)"
    else
        local ssh_info="ssh -R ${RmatePort}:localhost:${RmatePort} \$(hostname)"
    fi

    # generate the PBS script
    cat << EOF > ${job_name}.pbs
#PBS -q ${queue}
#PBS -l select=${nodes}:ngpus=${gpus}
#PBS -l walltime=${walltime}
#PBS -P ${project_number}
#PBS -N ${job_name}
#PBS -o ${output_file}
#PBS -e ${error_file}

echo "PBS_JOBID: \$PBS_JOBID" > ${INFO}
echo "hostname: \$(hostname)" >> ${INFO}
echo "GPU: \$(nvidia-smi)" >> ${INFO}

echo "export PBS_JOBID=\$PBS_JOBID" > ${ssh_node}
echo "${ssh_info}" >> ${ssh_node}

echo "rm *.e *.o *.info ssh_node delete_all" > ${delete_all}

chmod +x ${ssh_node}
chmod +x ${delete_all}

while true
do
    sleep 1
done

EOF

    cat << EOF > ${job_name}.crontab
#!/bin/bash
qsub $(pwd)/${job_name}.pbs
EOF
    
    chmod +x ${job_name}.crontab

    echo "The PBS script has been generated successfully!"
    echo "The GPU info will be saved in $(pwd)/${job_name}.info"
    echo "You can add crontab to run the task every day before your work."
    echo "The command is: crontab -e"
    echo "Add the following line to the end of the file:"
    echo "0 8 * * * $(pwd)/${job_name}.crontab"
    
}