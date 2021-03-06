import os
from datetime import datetime
import unicodedata
from terminaltables import SingleTable
from colorclass import Color


TABLE_WIDTH = 30
NO_DESCRIPTION = ''
CAN_NOT_GET = ''


def get_file_comments(file):
    with open(file, 'r') as f:
        content = f.readline()
        if len(content.strip()) > 3 and (content.strip().endswith("'''") or content.endswith('"""')):   #注释在一行时
            return content[3:-4].strip()
        elif content.startswith('#'):   #以井号注释时
            return content[1:].strip()
        elif content.startswith("'''") or content.startswith('"""'):   #注释在多行时
            content = f.readline()
            return content.strip()
        else:
            return NO_DESCRIPTION


def get_file_lines(file):
    try:
        with open(file, 'r') as f:
            return len(f.readlines())
    except Exception:
        return 0


def get_dir_lines(directory, depth=0):
    lines = 0
    if os.path.isdir(directory) and depth < 3:
        for d in os.listdir(directory):
            if os.path.isfile(directory+'/'+d):
                lines += get_file_lines(directory+'/'+d)
            else:
                current_line = get_dir_lines(directory+'/'+d, depth + 1)
                lines += current_line if isinstance(current_line, int) else 0
    return lines if depth < 3 else '>'+str(lines)


def lines_and_description(directory):
    if os.path.isfile(directory):
        return get_file_lines(directory), get_file_comments(directory)
    elif os.path.isdir(directory):
        path = directory + '/__init__.py'
        comments = get_file_comments(path) if os.path.exists(path) else NO_DESCRIPTION
        return CAN_NOT_GET, comments
    else:
        raise Exception


def wide_chars(s):
    # 使中英文字符在控制台所占宽度相同
    res = 0
    for c in s:
        if(unicodedata.east_asian_width(c) in ('F', 'W', 'A')):
            res += 2
        else:
            res += 1
    return res


def main():

    dirs = os.listdir('.')
    table_data = [['filename', 'last modify time', 'lines', 'description']]
    table = SingleTable(table_data)
    for directory in dirs:
        dirname = directory[:20]+'...' if len(directory) > 20 else directory
        if os.path.isfile(directory):
            dirname = Color('{autogreen}'+dirname+'{/autogreen}')
        try:
            last_modify_time = str(datetime.fromtimestamp(os.path.getmtime(directory)))[:19]
        except Exception:
            last_modify_time = CAN_NOT_GET
        try:
            lines, description = lines_and_description(directory)
            description = description[:37]+'...' if len(description) > 40 else description
        except:
            lines, description = CAN_NOT_GET, NO_DESCRIPTION
        table_data.append([dirname, last_modify_time, lines, description])

    table.title = Color('{autogreen}Path:' + os.getcwd()+'{/autogreen}')
    table.justify_columns[1] = 'center'
    table.justify_columns[2] = 'center'

    print(table.table)


if __name__ == '__main__':
    main()
    import cnfaker
    print(cnfaker.name())
