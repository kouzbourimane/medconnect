import os

replacements = {
    'Color.fromARGB(255, 86, 121, 145)': 'Color(0xFF388E3C)',
    'Color.fromARGB(255, 224, 234, 240)': 'Color(0xFFE8F5E9)',
    'Color.fromARGB(255, 213, 231, 243)': 'Color(0xFFC8E6C9)',
    '0xFF2C3E50': '0xFF1B5E20',
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
