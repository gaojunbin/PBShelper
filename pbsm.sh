pbsm(){
    echo -e 'This is a toolkit for monitoring PBS jobs.'
    echo -e 'Choose the Function [Number] you want:'
    echo -e '[1] qstat              ## list current jobs in simple format'
    echo -e '[2] qstat -aw          ## list current jobs in wider format'
    echo -e '[3] qstat -ans1        ## list current jobs in detailed format'
    echo -e '[4] qstat -q           ## list out queues'
    echo -e '[5] qstat -H           ## list out finished jobs'
    echo -e '[6] qstat -x           ## list out finished and current jobs'
    echo -e '[7] qstat -f <jobid>   ## list out full info of a job'
    echo -e '[8] qjob  <jobid>      ## check job speedup & efficiency status and advice info.'

    echo -e 'input your choose (default:1): \c'
    read mpbs_func_num
    if [ -z "${mpbs_func_num}" ];then
        mpbs_func_num=1
    fi
    if [ "${mpbs_func_num}" = 1 ];then
        watch -n 0.1 qstat
    elif [ "${mpbs_func_num}" = 2 ];then
        qstat -aw
    elif [ "${mpbs_func_num}" = 3 ];then
        qstat -ans1
    elif [ "${mpbs_func_num}" = 4 ];then
        qstat -q
    elif [ "${mpbs_func_num}" = 5 ];then
        qstat -H
    elif [ "${mpbs_func_num}" = 6 ];then
        qstat -x
    elif [ "${mpbs_func_num}" = 7 ];then
        qstat
        echo -e 'input the jobid you want to check: \c'
        read jobid
        qstat -f ${jobid}
    elif [ "${mpbs_func_num}" = 8 ];then
        qstat
        echo -e 'input the jobid you want to check: \c'
        read jobid
        qjob ${jobid}
    else
        echo 'Invalid Input!'
    fi
    unset mpbs_func_num
}