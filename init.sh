PBShelper_root="$HOME/.PBShelper"
source "${PBShelper_root}/pbsh.sh"
source "${PBShelper_root}/pbsm.sh"
source "${PBShelper_root}/pbsd.sh"
source "${PBShelper_root}/pbsc.sh"

ohmypbs(){
    echo -e 'This is a toolkit for using PBS.'
    echo -e '[*] pbs      -   All PBS Functions.'
    echo -e '[*] pbsh     -   PBS helper.'
    echo -e '[*] pbsm     -   Job monitoring.'
    echo -e '[*] pbsd     -   Job deletion.'
    echo -e '[*] pbsc     -   Job script creation.'
}

pbs(){
    echo -e 'This is a toolkit for using PBS.'
    echo -e 'Choose the Function [Number] you want:'
    echo -e '[1] pbsh - PBS helper'
    echo -e '[2] pbsm - Job monitoring'
    echo -e '[3] pbsd - Job deletion'
    echo -e '[4] pbsc - Job script creation'
    echo -e 'input your choose: \c'
    read pbs_func_num
    if [ "${pbs_func_num}" = 1 ];then
        pbsh
    elif [ "${pbs_func_num}" = 2 ];then
        pbsm
    elif [ "${pbs_func_num}" = 3 ];then
        pbsd
    elif [ "${pbs_func_num}" = 4 ];then
        pbsc
    else
        echo 'Invalid Input!'
    fi
}