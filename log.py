import subprocess
import sys

import datetime
import calendar
my_date = datetime.date.today()
if my_date.weekday() == 0:
    fday = datetime.datetime.today()  - datetime.timedelta(days=1) 
else:
    fday = datetime.datetime.today()

first_weekday =  str((fday - datetime.timedelta(days=fday.weekday() % 7)).date())

print(first_weekday)

# root_dir = '/Users/romka/linagora/'
root_dir = ''

projects = [
    'TwakeMobileProxy', 
    'Twake', 
    'Linagora-Twake-Mobile',
    'Twake-Mobile.wiki'
    ]

users = [
    ['Roman Bykovsky', '8026787@gmail.com', 0, (0,0,0)],
    ['Babur Makhmudov', 'bobs4462', 0, (0,0,0)],
    ['Pavel Zarudnev', 'rockinpaulz@gmail.com', 0, (0,0,0)],
    ['Nguyễn Mạnh Đức', 'manhducnguyen.it@gmail.com', 0, (0,0,0)],
    ['Evgenii Sharanov', 'sharanov_evgenii@mail.ru', 0, (0,0,0)]
]


def exec(cmd, dir):
    # print(cmd)
    return subprocess.check_output(cmd, shell=True, cwd=root_dir + dir).decode(sys.stdout.encoding).strip()

# for project in projects:
#     exec('git pull', project)


for user in users:
    print(user[0]+':')
    for project in projects:
        print('  {:<24}'.format(project), end='')
        commits_week = int(exec(f'git log --oneline --author={user[1]} --since={first_weekday}  | wc -l', project))
        print('| commits: {:<2}'.format(commits_week), end=' ')
        if commits_week:
            user[2] = user[2] + commits_week
            commits_stat = exec('''git log  --pretty=tformat: --numstat --author=$$AUTHOR$$ --since="$$DATEWEEK$$" | gawk '{ add += $1; subs += $2; loc += $1 + $2 } END { printf "%s,%s,%s", add, subs, loc }' -'''.replace('$$AUTHOR$$', user[1]).replace('$$DATEWEEK$$', first_weekday), project)
            stat = tuple([int(c) for c in commits_stat.split(',')])
            print('[ +{} -{} ={} ]'.format(*stat))
            user[3] = map(sum, zip(user[3], stat))
        else:
            print('')
    print('  ------------------------------------')
    print('  = {} commits (added lines: {}, removed lines: {}, total lines: {})'.format(user[2],*user[3]))
    print()


