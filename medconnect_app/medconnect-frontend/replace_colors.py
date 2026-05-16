import os

replacements = {
    '0xFF567991': '0xFF388E3C',
    '0xFF86B7D7': '0xFF81C784',
    '0xFFC3E2F6': '0xFFC8E6C9',
    '0xFFF5F9FC': '0xFFF1F8E9',
    'Colors.blue': 'Colors.green',
    'Colors.blueAccent': 'Colors.greenAccent',
    'Medical Blue': 'Medical Green',
    'light blue': 'light green',
    'Very light blue/grey': 'Very light green/grey',
    '0xFFC3E2F6': '0xFFC8E6C9'
}

def replace_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    for old, new in replacements.items():
        new_content = new_content.replace(old, new)
        
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f'Updated {filepath}')

def main():
    lib_dir = os.path.join(os.getcwd(), 'lib')
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                replace_in_file(os.path.join(root, file))

if __name__ == '__main__':
    main()
