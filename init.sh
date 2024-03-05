pbs(){
    echo -e 'This is a toolkit for using PBS.'
    echo -e '[*] mpbs   -   Job monitoring'
    echo -e '[*] dpbs   -   Job deletion'
    echo -e '[*] cpbs   -   Job creation'
    # echo -e '[*] spbs   -   Job submission'
}

# PBShelper_root="$HOME/.PBShelper"
PBShelper_root="/Users/junbingao/Documents/GitHub/PBShelper"
source "${PBShelper_root}/mpbs.sh"
source "${PBShelper_root}/dpbs.sh"
source "${PBShelper_root}/cpbs.sh"
# source "${PBShelper_root}/spbs.sh"