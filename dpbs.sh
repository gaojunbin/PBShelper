dpbs(){
    echo -e 'This is a toolkit for deleting PBS jobs.'
    echo -e 'Choose the Function [Number] you want:'
    echo -e '[1] kill a job'
    echo -e '[2] Force kill a job'
    echo -e 'input your choose (default:1): \c'
    read dpbs_func_num
    if [ -z "${dpbs_func_num}" ];then
        dpbs_func_num=1
    fi
    if [ "${dpbs_func_num}" = 1 ];then
        qstat
        echo -e 'input the jobid you want to delete: \c'
        read jobid
        qdel ${jobid}
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