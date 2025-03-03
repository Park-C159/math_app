import os

def write_files_content_to_txt(folder_path, output_txt):
    with open(output_txt, 'w', encoding='utf-8') as output_file:
        # 递归遍历文件夹
        for root, _, files in os.walk(folder_path):
            for file in files:
                file_path = os.path.join(root, file)
                try:
                    # 打开文件并将内容写入输出文本文件
                    with open(file_path, 'r', encoding='utf-8') as f:
                        output_file.write(f"\n\n{file_path}\n")
                        output_file.write(f.read())  # 写入文件内容

                except Exception as e:
                    output_file.write(f"\n\n--- Error reading file: {file_path} ---\n")
                    output_file.write(str(e))

# 调用函数
folder_path = "router"  # 指定你的文件夹路径
output_txt = "output.txt"  # 输出的 txt 文件名
write_files_content_to_txt(folder_path, output_txt)

print("文件内容已成功写入 output.txt")
