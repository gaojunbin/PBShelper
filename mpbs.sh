mpbs(){
    echo -e 'This is a toolkit for monitoring PBS jobs.'
    echo -e 'Choose the Function [Number] you want:'
    echo -e '[1] Job Status'
    echo -e '[2] Job History'
    echo -e '[3] Job status with all information'
    echo -e '[4] Job status with comments and vnode info'
    echo -e 'input your choose (default:1): \c'
    read mpbs_func_num
    if [ -z "${mpbs_func_num}" ];then
        mpbs_func_num=1
    fi
    if [ "${mpbs_func_num}" = 1 ];then
        qstat
    elif [ "${mpbs_func_num}" = 2 ];then
        qstat -x
    elif [ "${mpbs_func_num}" = 3 ];then
        qstat
        echo -e 'input the jobid you want to check: \c'
        read jobid
        qstat -f ${jobid}
    elif [ "${mpbs_func_num}" = 4 ];then
        qstat -ans
    else
        echo 'Invalid Input!'
    fi
    unset mpbs_func_num
}