#!/bin/sh
DATE_WEEK="2021-01-18T00:00:00-07:00"
DATE_MONTH="2021-01-01T00:00:00-07:00"

function process {
    echo $1
    printf "Commits (week):"
    git log --oneline --author=$2 --since="$DATE_WEEK" | wc -l
    printf "Commits (month):"
    git log --oneline --author=$2 --since="$DATE_MONTH" | wc -l
    printf "loc (week):"
    git log  --pretty=tformat: --numstat --author=$2 --since="$DATE_WEEK" \
    | gawk '{ add += $1; subs += $2; loc += $1 + $2 } END { printf "added lines: %s removed lines: %s total lines: %s\n", add, subs, loc }' -
    printf "loc (month):"
    git log  --pretty=tformat: --numstat --author=$2 --since="$DATE_MONTH" \
    | gawk '{ add += $1; subs += $2; loc += $1 + $2 } END { printf "added lines: %s removed lines: %s total lines: %s\n", add, subs, loc }' -
    echo "-------"
}

process 'Romaric Mourgues' 'rmourgues@linagora.com'
process 'Benoit Tallandier' 'benoit@twakeapp.com'
process 'Stéphane Vieira' '36481167+stephanevieira75@users.noreply.github.com'
process 'Christohpe Hamerling' 'christophe.hamerling@gmail.com'
process "Aiman R'Kyek" 'RkAiman'
process "Titouan Issarni" 'tissarni'
process 'Roman Bykovsky' '8026787@gmail.com'
process 'Babur Makhmudov' 'bobs4462'
process 'Pavel Zarudnev' 'rockinpaulz@gmail.com'
