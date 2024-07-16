pbsd(){
    echo -e 'This is a toolkit for deleting PBS jobs.'
    echo -e 'Choose the Function [Number] you want:'
    echo -e '[1] qdel <jobid>           ## to terminate a job gracefully.'
    echo -e '[2] qdel -W force <jobid>  ## to force terminate a job from PBS.'
    echo -e 'input your choose (default:1): \c'
    read dpbs_func_num
    if [ -z "${dpbs_func_num}" ];then
        dpbs_func_num=1
    fi
    if [ "${dpbs_func_num}" = 1 ]; then
        # 获取作业列表并添加序号列
        job_list=$(qstat | awk 'NR > 2 { print NR-2, $0 }')
        qstat | awk 'NR > 0 { if (NR-2 > 0) print NR-2, " ", $0; else if (NR-1 > 0) print "---", $0; else print "No.", $0 }'
        if [ -z "${job_list}" ]; then
            return
        fi
        # 提示用户输入要删除的作业序号
        echo -e 'Input the Job No. you want to delete: \c'
        read index

        # 获取用户选择的作业 ID
        jobid=$(echo "${job_list}" | awk -v idx=$index '$1 == idx { print $2 }')

        # 删除选定的作业
        if [ -n "${jobid}" ]; then
            qdel "${jobid}"
            print_text "green" "Job ${jobid} has been deleted." "false"
        else
            echo "Invalid job index or job ID."
        fi
    elif [ "${dpbs_func_num}" = 2 ];then
        qstat
        echo -e 'input the jobid you want to force delete: \c'
        read jobid
        qdel -W force ${jobid}
    else
        echo 'Invalid Input!'
    fi
    unset dpbs_func_num
}