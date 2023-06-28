get_mad1 () { 
while [[ -f runnit ]]; do ./fetch-query.pl mad1;sleep 1; done
}

get_milw () {
    while [[ -f runnit ]]; do ./fetch-query.pl milw;sleep 1; done
}

get_mad2 () {
    while [[ -f runnit ]]; do ./fetch-query.pl mad2;sleep 1; done
}

get_chic () {
    while [[ -f runnit ]]; do ./fetch-query.pl chic;sleep 1; done
}

get_stpl () {
    while [[ -f runnit ]]; do ./fetch-query.pl stpl;sleep 1; done
}

get_lab1 () {
    while [[ -f runnit ]]; do ./fetch-query.pl lab1;sleep 1; done
}

# DO NOT RUN THIS CODE! 
#while [[ -f runnit ]]; do 
   get_mad1  
#   get_milw &
#   get_mad2 &
#   get_chic &
#   get_stpl &
#   get_lab1 
#done;
